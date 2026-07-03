class WeatherModel {
  final String areaName;
  final int weatherConditionCode;
  final double temperature;
  final String weatherMain;
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final double tempMax;
  final double tempMin;
  final int humidity;
  final double windSpeed;

  WeatherModel({
    required this.areaName,
    required this.weatherConditionCode,
    required this.temperature,
    required this.weatherMain,
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.tempMax,
    required this.tempMin,
    required this.humidity,
    required this.windSpeed,
  });

  Map<String, dynamic> toJson() {
    return {
      'areaName': areaName,
      'weatherConditionCode': weatherConditionCode,
      'temperature': temperature,
      'weatherMain': weatherMain,
      'date': date.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'tempMax': tempMax,
      'tempMin': tempMin,
      'humidity': humidity,
      'windSpeed': windSpeed,
    };
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      areaName: json['areaName'],
      weatherConditionCode: json['weatherConditionCode'],
      temperature: json['temperature'],
      weatherMain: json['weatherMain'],
      date: DateTime.parse(json['date']),
      sunrise: DateTime.parse(json['sunrise']),
      sunset: DateTime.parse(json['sunset']),
      tempMax: json['tempMax'],
      tempMin: json['tempMin'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'],
    );
  }
}
