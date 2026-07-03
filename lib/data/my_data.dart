// my_data.dart
import 'package:shared_preferences/shared_preferences.dart';

const String API_KEY = "672d9e6eb196f7c4dbdecb677114b036"; // OpenWeather API Key
const String GEMINI_API_KEY = "AIzaSyC69xiDS1iUQehCDRq3f2z-2odl7QjtfJk"; // Gemini API Key

String getSgtDateString() {
  final sgtDateTime = DateTime.now().toUtc().add(const Duration(hours: 8));
  return "${sgtDateTime.year}-${sgtDateTime.month.toString().padLeft(2, '0')}-${sgtDateTime.day.toString().padLeft(2, '0')}";
}

Future<void> recordScanEvent() async {
  final prefs = await SharedPreferences.getInstance();
  final currentDate = getSgtDateString();
  final lastDate = prefs.getString('last_scan_date_sgt');

  int currentCount = 0;
  if (lastDate == currentDate) {
    currentCount = prefs.getInt('daily_scan_count') ?? 0;
  }
  currentCount++;

  await prefs.setString('last_scan_date_sgt', currentDate);
  await prefs.setInt('daily_scan_count', currentCount);
}
