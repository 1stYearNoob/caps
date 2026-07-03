import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/my_data.dart'; // Defines GEMINI_API_KEY

class TranslationService {
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('English');

  // Memory cache to prevent redundant SharedPreferences lookups
  static final Map<String, String> _translationCache = {};

  static String get currentLanguage => languageNotifier.value;

  static set currentLanguage(String lang) {
    languageNotifier.value = lang;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('app_language', lang);
    });
  }

  // Initialize the language setting on app launch
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? 'English';
    languageNotifier.value = lang;
  }

  // 1. Static Dictionary for immediate translation of UI elements
  static final Map<String, Map<String, String>> _staticDict = {
    'English': {
      'My Location': 'My Location',
      'Open in Google Maps': 'Open in Google Maps',
      'Log Position': 'Log Position',
      'Save Location': 'Save Location',
      'Save Rice Field Location': 'Save Rice Field Location',
      'Rice Field Saved': 'Rice Field Saved',
      'Translator': 'Translator',
      'Terms and Conditions': 'Terms and Conditions',
      'Welcome!': 'Welcome!',
      'Your Name': 'Your Name',
      'Save': 'Save',
      'Disease Dictionary': 'Disease Dictionary',
      'Rice Field Weather': 'Rice Field Weather',
      'Scan History': 'Scan History',
      'Daily Task Tracker': 'Daily Task Tracker',
      'Analyze Weather': 'Analyze Weather',
      'Upload to Admin': 'Upload to Admin',
      'Scan': 'Scan',
      'Completed': 'Completed',
      'Not Started': 'Not Started',
      'scans completed': 'scans completed',
      'Analyze for Rice Field': 'Analyze for Rice Field',
      'Currently Report': 'Currently Report',
      'Report to Admin': 'Report to Admin',
      'Let\'s Get Started': 'Let\'s Get Started',
      'Log In': 'Log In',
      'Sign Up': 'Sign Up',
      'Welcome Back': 'Welcome Back',
      'Login': 'Login',
      'Username': 'Username',
      'Password': 'Password',
      'Failed to log in': 'Failed to log in',
      'Camera': 'Camera',
      'Gallery': 'Gallery',
      'Scan Crop': 'Scan Crop',
      'Result': 'Result',
      'Confidence': 'Confidence',
      'Save Result': 'Save Result',
      'Go to Home': 'Go to Home',
      'Terms of Service': 'Terms of Service',
      'disease_detail': 'Disease Detail',
      'Overview': 'Overview',
      'Symptoms': 'Symptoms',
      'Management': 'Management',
      'Farmer': 'Farmer',
      'Tasks To Do': 'Tasks To Do',
      'Crop Disease Detector': 'Crop Disease Detector',
      'Scan Disease': 'Scan Disease',
      'Analyze Weather Report': 'Analyze Weather Report',
      'Upload Report to Admin': 'Upload Report to Admin',
      'Log Out': 'Log Out',
      'Are you sure you want to log out?': 'Are you sure you want to log out?',
      'Cancel': 'Cancel',
      'Search diseases...': 'Search diseases...',
      'No scan history found.': 'No scan history found.',
      'Analysis Result': 'Analysis Result',
      'Rice Field Location Marker': 'Rice Field Location Marker',
      'Tap anywhere on the map to mark your rice field.': 'Tap anywhere on the map to mark your rice field.',
      'Clear': 'Clear',
      'Marked at:': 'Marked at:',
      'Save Rice Field Location *': 'Save Rice Field Location *',
      'Location logged successfully in history!': 'Location logged successfully in history!',
      'Rice field location saved successfully! 🌾': 'Rice field location saved successfully! 🌾',
      'Please enter your name to continue.': 'Please enter your name to continue.',
      'Report to Admin (UI only)': 'Report to Admin (UI only)',
      'Reported to Admin!': 'Reported to Admin!',
      'Currently Report 📋': 'Currently Report 📋',
      'Tutorial': 'Tutorial',
      'How to use the app': 'How to use the app',
      'How to Plant Rice': 'How to Plant Rice',
      'Guidance': 'Guidance',
      'Others': 'Others',
      'HI!': 'HI!',
      'Failed to save name.': 'Failed to save name.',
      'Good Morning': 'Good Morning',
      'Good Afternoon': 'Good Afternoon',
      'Good Evening': 'Good Evening',
      'Good Night': 'Good Night',
      'Good Day': 'Good Day',
      'Sunrise': 'Sunrise',
      'Sunset': 'Sunset',
      'Temp Max': 'Temp Max',
      'Temp Min': 'Temp Min',
      'Humidity': 'Humidity',
      'Wind Speed': 'Wind Speed',
      'Failed to load weather data.\nPlease check your connection.': 'Failed to load weather data.\nPlease check your connection.',
      'Advice copied to clipboard!': 'Advice copied to clipboard!',
      'Copy': 'Copy',
      'Close': 'Close',
      'Warning': 'Warning',
      'You are on cooldown. Please try again in': 'You are on cooldown. Please try again in',
      'hours': 'hours',
      'minutes': 'minutes',
      'Categories': 'Categories',
      'All': 'All',
      'Pests': 'Pests',
      'Nutrient': 'Nutrient',
      'Disease Detector': 'Disease Detector',
      'Select a photo to analyze': 'Select a photo to analyze',
      'No image selected': 'No image selected',
      'Save to Gallery': 'Save to Gallery',
      'Scan Again': 'Scan Again',
      'Saved to History!': 'Saved to History!',
      'Failed to save: ': 'Failed to save: ',
      'Please log in to save result.': 'Please log in to save result.',
      'General Recommendations': 'General Recommendations',
      'Disease Management': 'Disease Management',
      'Nutrient Deficiency Considerations': 'Nutrient Deficiency Considerations',
      'Apply nutrients based on soil test results': 'Apply nutrients based on soil test results',
      'Fungal': 'Fungal',
      'Bacterial': 'Bacterial',
      'Viral': 'Viral',
      'Healthy': 'Healthy',
      'Disease': 'Disease',
      'Unknown': 'Unknown',
      'No pathogens detected': 'No pathogens detected',
      'None': 'None',
      'Bacterial Blight': 'Bacterial Blight',
      'Bacterial Sheath Blight': 'Bacterial Sheath Blight',
      'Causes:': 'Causes:',
      'Pointers in Soil Sampling:': 'Pointers in Soil Sampling:',
      'Materials:': 'Materials:',
      'Steps in Sampling:': 'Steps in Sampling:',
      'blast': 'Rice Blast',
      'brown spot': 'Brown Spot',
      'bacterial-leaf-blight': 'Bacterial Blight',
      'bacterial leaf blight': 'Bacterial Blight',
      'sheath blight': 'Bacterial Sheath Blight',
      'healthy': 'Healthy',
      'Not Detected': 'Not Detected',
      'Pathogen': 'Pathogen',
      'Description': 'Description',
      'Severity': 'Severity',
      'High': 'High',
      'Medium': 'Medium',
      'Low': 'Low',
      'Rice Blast': 'Rice Blast',
      'Brown Spot': 'Brown Spot',
      'Magnaporthe oryzae': 'Magnaporthe oryzae',
      'Bipolaris oryzae': 'Bipolaris oryzae',
      'Xanthomonas oryzae': 'Xanthomonas oryzae',
      'Rhizoctonia solani': 'Rhizoctonia solani',
      'Summary': 'Summary',
      'Back': 'Back',
      'Next': 'Next',
      'Done': 'Done',
      'Home Screen': 'Home Screen',
      'Weather Monitor': 'Weather Monitor',
      'Location Mapping': 'Location Mapping',
    },
    'Filipino': {
      'My Location': 'Aking Lokasyon',
      'Open in Google Maps': 'Buksan sa Google Maps',
      'Log Position': 'Itala ang Lokasyon',
      'Save Location': 'I-save ang Lokasyon',
      'Save Rice Field Location': 'I-save ang Lokasyon ng Bukid',
      'Rice Field Saved': 'Nai-save na ang Bukid',
      'Translator': 'Tagasalin',
      'Terms and Conditions': 'Mga Tuntunin at Kundisyon',
      'Welcome!': 'Maligayang Pagdating!',
      'Your Name': 'Iyong Pangalan',
      'Save': 'I-save',
      'Disease Dictionary': 'Diksiyonaryo ng Sakit',
      'Rice Field Weather': 'Panahon sa Bukid',
      'Scan History': 'Kasaysayan ng Pagsusuri',
      'Daily Task Tracker': 'Pang-araw-araw na Gawaing Bukid',
      'Analyze Weather': 'Suriin ang Panahon',
      'Upload to Admin': 'I-upload sa Admin',
      'Scan': 'Suriin ang Pananim',
      'Completed': 'Tapos Na',
      'Not Started': 'Hindi pa Nagsisimula',
      'scans completed': 'pagsusuri ang natapos',
      'Analyze for Rice Field': 'Suriin para sa Bukid',
      'Currently Report': 'Kasalukuyang Ulat',
      'Report to Admin': 'Iulat sa Admin',
      'Let\'s Get Started': 'Magsimula Na',
      'Log In': 'Mag-login',
      'Sign Up': 'Mag-sign Up',
      'Welcome Back': 'Maligayang Pagbabalik',
      'Login': 'Login',
      'Username': 'Username',
      'Password': 'Password',
      'Failed to log in': 'Bigo ang pag-login',
      'Camera': 'Kamera',
      'Gallery': 'Galerya',
      'Scan Crop': 'Suriin ang Pananim',
      'Result': 'Resulta',
      'Confidence': 'Kumpiyansa',
      'Save Result': 'I-save ang Resulta',
      'Go to Home': 'Pumunta sa Home',
      'Terms of Service': 'Mga Tuntunin ng Serbisyo',
      'disease_detail': 'Detalye ng Sakit',
      'Overview': 'Pangkalahatang-ideya',
      'Symptoms': 'Mga Sintomas',
      'Management': 'Pamamahala',
      'Farmer': 'Magsasaka',
      'Tasks To Do': 'Mga Dapat Gawin',
      'Crop Disease Detector': 'Tagasuri ng Sakit ng Pananim',
      'Scan Disease': 'Suriin ang Sakit',
      'Analyze Weather Report': 'Suriin ang Ulat Panahon',
      'Upload Report to Admin': 'I-upload ang Ulat sa Admin',
      'Log Out': 'Mag-logout',
      'Are you sure you want to log out?': 'Sigurado ka bang gusto mong mag-logout?',
      'Cancel': 'Kanselahin',
      'Search diseases...': 'Maghanap ng sakit...',
      'No scan history found.': 'Walang nahanap na kasaysayan ng pagsusuri.',
      'Analysis Result': 'Resulta ng Pagsusuri',
      'Rice Field Location Marker': 'Palatandaan ng Lokasyon ng Bukid',
      'Tap anywhere on the map to mark your rice field.': 'I-tap ang mapa upang markahan ang iyong bukid.',
      'Clear': 'Alisin',
      'Marked at:': 'Minarkahan sa:',
      'Save Rice Field Location *': 'I-save ang Lokasyon ng Bukid *',
      'Location logged successfully in history!': 'Matagumpay na naitala ang lokasyon sa kasaysayan!',
      'Rice field location saved successfully! 🌾': 'Matagumpay na nai-save ang lokasyon ng bukid! 🌾',
      'Please enter your name to continue.': 'Mangyaring ilagay ang iyong pangalan upang magpatuloy.',
      'Report to Admin (UI only)': 'Iulat sa Admin (UI lamang)',
      'Reported to Admin!': 'Naiulat na sa Admin!',
      'Currently Report 📋': 'Kasalukuyang Ulat 📋',
      'Tutorial': 'Gabay sa Paggamit',
      'How to use the app': 'Paano gamitin ang app',
      'How to Plant Rice': 'Paano Magtanim ng Palay',
      'Guidance': 'Gabay',
      'Others': 'Iba pa',
      'HI!': 'Kumusta!',
      'Failed to save name.': 'Bigo sa pag-save ng pangalan.',
      'Good Morning': 'Magandang Umaga',
      'Good Afternoon': 'Magandang Hapon',
      'Good Evening': 'Magandang Gabi',
      'Good Night': 'Magandang Gabi',
      'Good Day': 'Magandang Araw',
      'Sunrise': 'Pagsikat ng Araw',
      'Sunset': 'Paglubog ng Araw',
      'Temp Max': 'Pinakamataas na Temp',
      'Temp Min': 'Pinakamababang Temp',
      'Humidity': 'Kahalumigmigan',
      'Wind Speed': 'Bilis ng Hangin',
      'Failed to load weather data.\nPlease check your connection.': 'Bigo sa pag-load ng ulat panahon.\nMangyaring suriin ang iyong koneksyon.',
      'Advice copied to clipboard!': 'Nai-copy na ang payo sa clipboard!',
      'Copy': 'Kopyahin',
      'Close': 'Isara',
      'Warning': 'Babala',
      'You are on cooldown. Please try again in': 'Ikaw ay nasa cooldown. Mangyaring subukan muli pagkatapos ng',
      'hours': 'oras',
      'minutes': 'minuto',
      'Categories': 'Mga Kategorya',
      'All': 'Lahat',
      'Pests': 'Mga Peste',
      'Nutrient': 'Nutrisyon',
      'Disease Detector': 'Tagasuri ng Sakit',
      'Select a photo to analyze': 'Pumili ng larawan upang suriin',
      'No image selected': 'Walang napiling larawan',
      'Save to Gallery': 'I-save sa Galerya',
      'Scan Again': 'Suriin Muli',
      'Saved to History!': 'Nai-save sa Kasaysayan!',
      'Failed to save: ': 'Bigo sa pag-save: ',
      'Please log in to save result.': 'Mangyaring mag-login upang i-save ang resulta.',
      'General Recommendations': 'Pangkalahatang Rekomendasyon',
      'Disease Management': 'Pamamahala ng Sakit',
      'Nutrient Deficiency Considerations': 'Mga Konsiderasyon sa Kakulangan ng Nutrisyon',
      'Apply nutrients based on soil test results': 'Maglagay ng nutrisyon batay sa resulta ng pagsusuri ng lupa',
      'Fungal': 'Fungal',
      'Bacterial': 'Bacterial',
      'Viral': 'Viral',
      'Healthy': 'Malusog',
      'Disease': 'Sakit',
      'Unknown': 'Hindi Matukoy',
      'No pathogens detected': 'Walang nakitang pathogen',
      'None': 'Wala',
      'Bacterial Blight': 'Bacterial Blight',
      'Bacterial Sheath Blight': 'Bacterial Sheath Blight',
      'Causes:': 'Mga Sanhi:',
      'Pointers in Soil Sampling:': 'Mga Paalala sa Pagkuha ng Sampol ng Lupa:',
      'Materials:': 'Mga Kagamitan:',
      'Steps in Sampling:': 'Mga Hakbang sa Pagkuha ng Sampol ng Lupa:',
      'blast': 'Rice Blast',
      'brown spot': 'Brown Spot',
      'bacterial-leaf-blight': 'Bacterial Blight',
      'bacterial leaf blight': 'Bacterial Blight',
      'sheath blight': 'Bacterial Sheath Blight',
      'healthy': 'Malusog',
      'Not Detected': 'Hindi Natukoy',
      'Pathogen': 'Pathogen',
      'Description': 'Deskripsyon',
      'Severity': 'Kalubhaan',
      'High': 'Mataas',
      'Medium': 'Katamtaman',
      'Low': 'Mababa',
      'Rice Blast': 'Rice Blast',
      'Brown Spot': 'Brown Spot',
      'Magnaporthe oryzae': 'Magnaporthe oryzae',
      'Bipolaris oryzae': 'Bipolaris oryzae',
      'Xanthomonas oryzae': 'Xanthomonas oryzae',
      'Rhizoctonia solani': 'Rhizoctonia solani',
      'Summary': 'Buod',
      'Back': 'Bumalik',
      'Next': 'Susunod',
      'Done': 'Tapos',
      'Home Screen': 'Home Screen',
      'Weather Monitor': 'Monitor ng Panahon',
      'Location Mapping': 'Mapa ng Lokasyon',
    }
  };

  // Static translator extension getter helper
  static String translateStatic(String text) {
    final lang = languageNotifier.value;
    return _staticDict[lang]?[text] ?? text;
  }

  // 2. Dynamic AI Translation for descriptions, advices, recommendations
  static Future<String> translateWithAI(String text) async {
    final lang = languageNotifier.value;
    if (lang == 'English' || text.trim().isEmpty) {
      return text;
    }

    final cacheKey = '${lang}_$text';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    // Try retrieving from persistent SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(cacheKey);
    if (stored != null) {
      _translationCache[cacheKey] = stored;
      return stored;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: GEMINI_API_KEY,
      );

      final prompt = '''
You are a professional, accurate translator fluent in both English and Filipino (Tagalog).
Translate the following agricultural/farming text into natural Filipino (Tagalog).
Provide ONLY the translated text in your response, with absolutely no intro, explanations, notes, or surrounding quotes.

Text to translate:
"$text"
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      String translated = response.text?.trim() ?? text;

      // Clean up wrapping quotes
      if (translated.startsWith('"') && translated.endsWith('"')) {
        translated = translated.substring(1, translated.length - 1);
      }

      // Cache the result
      _translationCache[cacheKey] = translated;
      await prefs.setString(cacheKey, translated);
      return translated;
    } catch (e) {
      debugPrint('AI Translation error: $e');
      return text; // Graceful fallback to English if API fails
    }
  }
}

// Extension to allow easy standard translations like: 'Text'.tr
extension TranslationExtension on String {
  String get tr => TranslationService.translateStatic(this);
}

// Widget to render text translated dynamically via Gemini AI
class AiTranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AiTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<AiTranslatedText> createState() => _AiTranslatedTextState();
}

class _AiTranslatedTextState extends State<AiTranslatedText> {
  String? _translatedText;
  bool _isLoading = false;
  String? _loadedForLanguage;

  @override
  void initState() {
    super.initState();
    TranslationService.languageNotifier.addListener(_onLanguageChanged);
    _checkTranslation();
  }

  @override
  void dispose() {
    TranslationService.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(AiTranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _checkTranslation();
    }
  }

  void _onLanguageChanged() {
    _checkTranslation();
  }

  Future<void> _checkTranslation() async {
    final currentLang = TranslationService.currentLanguage;
    if (currentLang == 'English') {
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
          _isLoading = false;
          _loadedForLanguage = 'English';
        });
      }
      return;
    }

    if (_loadedForLanguage == currentLang && _translatedText != null) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await TranslationService.translateWithAI(widget.text);

    if (mounted) {
      setState(() {
        _translatedText = result;
        _isLoading = false;
        _loadedForLanguage = currentLang;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Opacity(
        opacity: 0.5,
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
        ),
      );
    }

    return Text(
      _translatedText ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
