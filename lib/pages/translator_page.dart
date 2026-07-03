import 'package:flutter/material.dart';
import '../theme/colors/light_colors.dart';
import '../services/translation_service.dart';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  @override
  Widget build(BuildContext context) {
    final currentAppLang = TranslationService.currentLanguage;

    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: LightColors.kDarkBlue),
        title: Text(
          'Translator'.tr,
          style: const TextStyle(
            color: LightColors.kDarkBlue,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION 1: GLOBAL APP LANGUAGE SETTING
              Text(
                'APP LANGUAGE'.tr,
                style: const TextStyle(
                  color: LightColors.kDarkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentAppLang == 'English'
                          ? 'Select default language for AgriScan UI & content:'
                          : 'Piliin ang default na wika para sa AgriScan UI at nilalaman:',
                      style: TextStyle(
                        color: LightColors.kDarkBlue.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentAppLang == 'English'
                                  ? LightColors.kDarkBlue
                                  : Colors.grey.shade100,
                              foregroundColor: currentAppLang == 'English'
                                  ? Colors.white
                                  : LightColors.kDarkBlue,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: currentAppLang == 'English'
                                    ? BorderSide.none
                                    : BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                TranslationService.currentLanguage = 'English';
                              });
                            },
                            child: const Text(
                              'English',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentAppLang == 'Filipino'
                                  ? LightColors.kDarkBlue
                                  : Colors.grey.shade100,
                              foregroundColor: currentAppLang == 'Filipino'
                                  ? Colors.white
                                  : LightColors.kDarkBlue,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: currentAppLang == 'Filipino'
                                    ? BorderSide.none
                                    : BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                TranslationService.currentLanguage = 'Filipino';
                              });
                            },
                            child: const Text(
                              'Filipino',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
