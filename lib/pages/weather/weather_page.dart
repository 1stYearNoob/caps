import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/weather_bloc/weather_bloc_bloc.dart';
import '../../theme/colors/light_colors.dart';
import '../../data/my_data.dart';
import '../../services/translation_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: _determinePosition(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BlocProvider<WeatherBlocBloc>(
            create: (context) => WeatherBlocBloc()..add(FetchWeather(snapshot.data!)),
            child: const WeatherContent(),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
             backgroundColor: LightColors.kLightYellow,
             body: Center(child: Text(snapshot.error.toString(), style: const TextStyle(color: LightColors.kDarkBlue))),
          );
        } else {
          return const Scaffold(
            backgroundColor: LightColors.kLightYellow,
            body: Center(
              child: CircularProgressIndicator(color: LightColors.kDarkBlue),
            ),
          );
        }
      },
    );
  }
}

class WeatherContent extends StatefulWidget {
  const WeatherContent({super.key});

  @override
  State<WeatherContent> createState() => _WeatherContentState();
}

class _WeatherContentState extends State<WeatherContent> {
  SharedPreferences? _prefs;
  String? _savedAdvice;
  int? _savedAdviceTime;
  bool _isOnCooldown = false;
  String _cooldownRemaining = "";
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _savedAdvice = _prefs?.getString('saved_crop_advice');
        _savedAdviceTime = _prefs?.getInt('saved_crop_advice_time');
      });
    }
    _checkCooldown();
    
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkCooldown();
    });
  }

  void _checkCooldown() {
    if (_savedAdviceTime == null) {
      if (mounted && _isOnCooldown) {
        setState(() {
          _isOnCooldown = false;
        });
      }
      return;
    }

    final lastTime = DateTime.fromMillisecondsSinceEpoch(_savedAdviceTime!);
    final now = DateTime.now();
    final difference = now.difference(lastTime);
    const cooldownDuration = Duration(hours: 5);

    if (difference < cooldownDuration) {
      final remaining = cooldownDuration - difference;
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);
      final seconds = remaining.inSeconds.remainder(60);
      
      final timeStr = "${hours}h ${minutes}m ${seconds}s";
      if (mounted) {
        setState(() {
          _isOnCooldown = true;
          _cooldownRemaining = timeStr;
        });
      }
    } else {
      if (mounted && _isOnCooldown) {
        setState(() {
          _isOnCooldown = false;
        });
      }
    }
  }

  Widget getWeatherIcon(int code) {
    switch (code) {
      case >= 200 && < 300:
        return const Icon(Icons.thunderstorm, color: Colors.amber, size: 80);
      case >= 300 && < 400:
        return const Icon(Icons.water_drop, color: Colors.lightBlue, size: 80);
      case >= 500 && < 600:
        return const Icon(Icons.cloudy_snowing, color: Colors.blue, size: 80);
      case >= 600 && < 700:
        return const Icon(Icons.ac_unit, color: LightColors.kDarkBlue, size: 80);
      case >= 700 && < 800:
        return const Icon(Icons.foggy, color: Colors.grey, size: 80);
      case == 800:
        return const Icon(Icons.wb_sunny, color: Colors.orange, size: 80);
      case > 800 && <= 804:
        return const Icon(Icons.cloud, color: Colors.grey, size: 80);
      default:
        return const Icon(Icons.wb_sunny, color: Colors.orange, size: 80);
    }
  }

  String getGreeting() {  
    int hours = DateTime.now().hour;
    if (hours >= 1 && hours <= 12) {
      return "Good Morning".tr;
    } else if (hours > 12 && hours <= 16) {
      return "Good Afternoon".tr;
    } else if (hours > 16 && hours <= 21) {
      return "Good Evening".tr;
    } else if (hours > 21 && hours <= 24) {
      return "Good Night".tr;
    } else {
      return "Good Day".tr;
    }
  }

  void _showAgriculturalAdvice(BuildContext context, dynamic weather, {String? preloadedAdvice}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AiAdviceDialog(
          weather: weather,
          preloadedAdvice: preloadedAdvice,
          onAdviceGenerated: () {
            _loadPrefs();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: BlocBuilder<WeatherBlocBloc, WeatherBlocState>(
            builder: (context, state) {
              if (state is WeatherBlocSuccess) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📍 ${state.weather.areaName}',
                          style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getGreeting(),
                          style: const TextStyle(fontSize: 28, color: LightColors.kDarkBlue, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 25),
                        Center(
                          child: getWeatherIcon(state.weather.weatherConditionCode),
                        ),
                        Center(
                          child: Text(
                            '${state.weather.temperature.round()}℃',
                            style: const TextStyle(color: LightColors.kDarkBlue, fontSize: 60, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Center(
                          child: Text(
                            state.weather.weatherMain.toUpperCase(),
                            style: const TextStyle(color: LightColors.kDarkBlue, fontSize: 25, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Center(
                          child: Text(
                            DateFormat('EEEE dd - ').add_jm().format(state.weather.date),
                            style: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(25.0),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.05),
                                 blurRadius: 10,
                                 offset: const Offset(0, 5),
                               )
                             ]
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.wb_twilight, color: LightColors.kDarkYellow, size: 30),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Sunrise'.tr, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          Text(
                                            DateFormat().add_jm().format(state.weather.sunrise),
                                            style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.nights_stay, color: LightColors.kBlue, size: 30),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Sunset'.tr, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          Text(
                                            DateFormat().add_jm().format(state.weather.sunset),
                                            style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.0),
                                child: Divider(color: Colors.black12),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.thermostat, color: LightColors.kRed, size: 30),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Temp Max'.tr, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          Text(
                                            "${state.weather.tempMax.round()}℃",
                                            style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.thermostat, color: LightColors.kBlue, size: 30),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Temp Min'.tr, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          Text(
                                            "${state.weather.tempMin.round()}℃",
                                            style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.0),
                                child: Divider(color: Colors.black12),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.water_drop, color: Colors.lightBlue, size: 30),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Humidity'.tr, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          Text(
                                            "${state.weather.humidity}%",
                                            style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.air, color: Colors.blueGrey, size: 30),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Wind Speed'.tr, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          Text(
                                            "${state.weather.windSpeed.toStringAsFixed(1)} km/h",
                                            style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _isOnCooldown
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: LightColors.kDarkBlue,
                                        content: Text(
                                          "${'Warning'.tr}: ${'You are on cooldown. Please try again in'.tr} $_cooldownRemaining",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  }
                                : () => _showAgriculturalAdvice(context, state.weather),
                            icon: const Icon(Icons.analytics, color: Colors.white),
                            label: Text(
                              _isOnCooldown
                                  ? '${'Analyze (Cooldown:'.tr} $_cooldownRemaining)'
                                  : 'Analyze for Rice Field'.tr,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isOnCooldown ? Colors.grey : LightColors.kGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        if (_savedAdvice != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              onPressed: () => _showAgriculturalAdvice(context, state.weather, preloadedAdvice: _savedAdvice),
                              icon: const Icon(Icons.receipt_long, color: Colors.white),
                              label: Text(
                                'Currently Report'.tr,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LightColors.kDarkBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 50), // bottom spacing for safe area / scrolling
                      ],
                    ),
                  ),
                );
              } else if (state is WeatherBlocLoading) {
                 return const Center(child: CircularProgressIndicator(color: LightColors.kDarkBlue));
              } else if (state is WeatherBlocFailure) {
                 return const Center(child: Text("Failed to load weather data.\nPlease check your connection.", textAlign: TextAlign.center, style: TextStyle(color: LightColors.kDarkBlue)));
              } else {
                 return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}

class AiAdviceDialog extends StatefulWidget {
  final dynamic weather;
  final String? preloadedAdvice;
  final VoidCallback? onAdviceGenerated;
  const AiAdviceDialog({super.key, required this.weather, this.preloadedAdvice, this.onAdviceGenerated});

  @override
  State<AiAdviceDialog> createState() => _AiAdviceDialogState();
}

class _AiAdviceDialogState extends State<AiAdviceDialog> {
  bool _isLoading = true;
  String _response = "";
  String _error = "";

  @override
  void initState() {
    super.initState();
    if (widget.preloadedAdvice != null) {
      _isLoading = false;
      _response = widget.preloadedAdvice!;
    } else {
      _fetchAdvice();
    }
  }

  Future<void> _fetchAdvice() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: GEMINI_API_KEY,
      );
      
      final lang = TranslationService.currentLanguage;
      final langInstruction = lang == 'Filipino'
          ? 'Please provide the advice in the Filipino language (Tagalog).'
          : 'Please provide the advice in the English language.';

      final prompt = '''
You are an expert agronomist specializing in rice farming. 
I have a rice field. The current weather conditions are:
- Temperature: ${widget.weather.temperature.round()}°C
- Weather: ${widget.weather.weatherMain}
- Humidity: ${widget.weather.humidity}%
- Wind Speed: ${widget.weather.windSpeed.toStringAsFixed(1)} km/h

Please provide a brief, actionable advice (around 3 to 4 points) on how to care for the rice field given these specific conditions. Use emojis. Keep it concise. And the weather is based in the philippines and their agricultural practices.
$langInstruction
''';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final textResult = response.text ?? "No advice generated.";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_crop_advice', textResult);
      await prefs.setInt('saved_crop_advice_time', DateTime.now().millisecondsSinceEpoch);
      await prefs.setString('weather_analyzed_date_sgt', getSgtDateString());

      if (mounted) {
        setState(() {
          _isLoading = false;
          _response = textResult;
        });
        widget.onAdviceGenerated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Failed to analyze weather: $e";
        });
      }
    }
  }

  Widget _buildDialogWeatherMeta(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: LightColors.kGreen, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: LightColors.kDarkBlue, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.black45, fontSize: 10)),
      ],
    );
  }

  List<Widget> _buildFormattedResponse(String responseText) {
    final lines = responseText.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      bool isBullet = trimmed.startsWith('*') || trimmed.startsWith('-') || trimmed.startsWith('•');
      bool isNumbered = RegExp(r'^\d+\.').hasMatch(trimmed);

      if (isBullet || isNumbered) {
        String content = trimmed;
        if (isBullet) {
          content = trimmed.substring(1).trim();
        } else if (isNumbered) {
          final firstDot = trimmed.indexOf('.');
          content = trimmed.substring(firstDot + 1).trim();
        }

        content = content.replaceAll('**', '');

        IconData leadingIcon = Icons.eco;
        Color iconColor = LightColors.kGreen;

        final lowerContent = content.toLowerCase();
        if (lowerContent.contains('water') || lowerContent.contains('irrigate') || lowerContent.contains('flood') || lowerContent.contains('rain')) {
          leadingIcon = Icons.water_drop;
          iconColor = Colors.blue;
        } else if (lowerContent.contains('pest') || lowerContent.contains('insect') || lowerContent.contains('disease') || lowerContent.contains('spray') || lowerContent.contains('bug') || lowerContent.contains('weed')) {
          leadingIcon = Icons.bug_report;
          iconColor = Colors.orange;
        } else if (lowerContent.contains('fertilizer') || lowerContent.contains('nitrogen') || lowerContent.contains('soil') || lowerContent.contains('nutrient') || lowerContent.contains('fertilize')) {
          leadingIcon = Icons.grass;
          iconColor = Colors.brown;
        } else if (lowerContent.contains('harvest') || lowerContent.contains('cut') || lowerContent.contains('yield') || lowerContent.contains('dry')) {
          leadingIcon = Icons.agriculture;
          iconColor = Colors.amber;
        } else if (lowerContent.contains('temperature') || lowerContent.contains('heat') || lowerContent.contains('sun') || lowerContent.contains('weather')) {
          leadingIcon = Icons.wb_sunny;
          iconColor = Colors.orangeAccent;
        } else if (lowerContent.contains('wind') || lowerContent.contains('typhoon') || lowerContent.contains('storm') || lowerContent.contains('monsoon')) {
          leadingIcon = Icons.air;
          iconColor = Colors.blueGrey;
        }

        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(leadingIcon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AiTranslatedText(
                    content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: LightColors.kDarkBlue,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        final cleaned = trimmed.replaceAll('**', '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            child: AiTranslatedText(
              cleaned,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: LightColors.kDarkBlue,
              ),
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) {
      widgets.add(AiTranslatedText(responseText, style: const TextStyle(color: LightColors.kDarkBlue)));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: LightColors.kLightYellow,
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: LightColors.kGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.agriculture, color: LightColors.kGreen, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              ' Rice Field Advice Anaylzer',
              style: TextStyle(
                color: LightColors.kDarkBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDialogWeatherMeta(Icons.thermostat, "${widget.weather.temperature.round()}°C", "Temp"),
                    _buildDialogWeatherMeta(Icons.water_drop, "${widget.weather.humidity}%", "Humidity"),
                    _buildDialogWeatherMeta(Icons.air, "${widget.weather.windSpeed.toStringAsFixed(1)} km/h", "Wind"),
                  ],
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: LightColors.kGreen),
                        const SizedBox(height: 16),
                        Text(
                          'Analyzing weather data...'.tr,
                          style: const TextStyle(color: LightColors.kDarkBlue, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 13))),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildFormattedResponse(_response),
                ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(10, 0, 20, 15),
      actions: [
        if (!_isLoading) ...[
          if (_error.isEmpty)
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _response));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Advice copied to clipboard!'.tr),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16, color: LightColors.kGreen),
              label: Text('Copy'.tr, style: const TextStyle(color: LightColors.kGreen, fontWeight: FontWeight.bold)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: LightColors.kDarkBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Close'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}
