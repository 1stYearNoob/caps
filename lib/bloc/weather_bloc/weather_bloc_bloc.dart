import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'weather_model.dart';

part 'weather_bloc_event.dart';
part 'weather_bloc_state.dart';

class WeatherBlocBloc extends Bloc<WeatherBlocEvent, WeatherBlocState> {
  WeatherBlocBloc() : super(WeatherBlocInitial()) {
    on<FetchWeather>((event, emit) async {
      emit(WeatherBlocLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        
        // 1. Check Cache
        try {
          final lastFetchStr = prefs.getString('last_weather_fetch_time');
          final cachedWeatherStr = prefs.getString('cached_weather_data');

          if (lastFetchStr != null && cachedWeatherStr != null) {
            final lastFetchTime = DateTime.parse(lastFetchStr);
            final difference = DateTime.now().difference(lastFetchTime);

            if (difference.inHours < 5) {
              final cachedData = json.decode(cachedWeatherStr);
              final weatherModel = WeatherModel.fromJson(cachedData);
              emit(WeatherBlocSuccess(weatherModel));
              return; 
            }
          }
        } catch (e) {
          print("Cache parsing failed (likely due to model updates). Fetching fresh data: $e");
        }

        // 2. Fetch Fresh Data (Cache is older than 5 hours, or doesn't exist)
        final double lat = event.position.latitude;
        final double lon = event.position.longitude;

        final String url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto';
        
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          String areaName = "Unknown Location";
          try {
             List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
             if (placemarks.isNotEmpty) {
                areaName = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? "Your Location";
             }
          } catch (e) {
             print("Geocoding failed: $e");
          }

          final current = data['current'];
          final daily = data['daily'];

          final weatherModel = WeatherModel(
            areaName: areaName,
            weatherConditionCode: _mapOpenMeteoCode(current['weather_code']),
            temperature: current['temperature_2m'].toDouble(),
            weatherMain: _getMainWeatherDescription(current['weather_code']),
            date: DateTime.parse(current['time']),
            sunrise: DateTime.parse(daily['sunrise'][0]),
            sunset: DateTime.parse(daily['sunset'][0]),
            tempMax: daily['temperature_2m_max'][0].toDouble(),
            tempMin: daily['temperature_2m_min'][0].toDouble(),
            humidity: current['relative_humidity_2m'],
            windSpeed: current['wind_speed_10m'].toDouble(),
          );

          // 3. Save new data to Cache
          await prefs.setString('last_weather_fetch_time', DateTime.now().toIso8601String());
          await prefs.setString('cached_weather_data', json.encode(weatherModel.toJson()));

          emit(WeatherBlocSuccess(weatherModel));
        } else {
          print("Weather API HTTP Error: ${response.statusCode}");
          emit(WeatherBlocFailure());
        }

      } catch (e) {
        print("Weather Bloc Error: $e");
        emit(WeatherBlocFailure());
      }
    });
  }

  // Helper function to map Open-Meteo WMO generic codes back to a simpler "Main Weather"
  String _getMainWeatherDescription(int code) {
    if (code == 0) return "Clear Sky";
    if (code == 1 || code == 2 || code == 3) return "Cloudy";
    if (code >= 45 && code <= 48) return "Fog";
    if (code >= 51 && code <= 67) return "Rain";
    if (code >= 71 && code <= 86) return "Snow";
    if (code >= 95) return "Thunderstorm";
    return "Unknown";
  }

  // To reduce impact on the existing View layer switch case, try to translate OpenMeteo WMO codes
  // to closely match the integer brackets you previously set up in getWeatherIcon.
  int _mapOpenMeteoCode(int code) {
     if (code == 0) return 800; // Clear
     if (code == 1 || code == 2 || code == 3) return 802; // Cloudy
     if (code >= 45 && code <= 48) return 701; // Fog
     if (code >= 51 && code <= 67) return 500; // Rain
     if (code >= 71 && code <= 86) return 600; // Snow
     if (code >= 95) return 200; // Thunderstorm
     return 800;
  }
}
