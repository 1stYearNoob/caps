import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ----- CONFIGURE THESE -----
const String roboflowProject = "agri-scan-2-vrp1u";
const String roboflowVersion = "4"; // or "latest"
const String roboflowApiKey = "4PkpN6jz1KxfZPY4jwew";
// ---------------------------

class Detection {
  final double x, y, width, height, confidence;
  final String label;

  Detection(
      this.x, this.y, this.width, this.height, this.confidence, this.label);

  factory Detection.fromMap(Map<String, dynamic> m) {
    return Detection(
      (m['x'] as num?)?.toDouble() ?? 0.0,
      (m['y'] as num?)?.toDouble() ?? 0.0,
      (m['width'] as num?)?.toDouble() ?? 0.0,
      (m['height'] as num?)?.toDouble() ?? 0.0,
      (m['confidence'] as num?)?.toDouble() ?? 0.0,
      m['class']?.toString() ?? 'Unknown',
    );
  }
}

class RoboflowService {
  Future<List<Detection>> detectDisease(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Img = base64Encode(bytes);

    final url = Uri.parse(
        "https://detect.roboflow.com/$roboflowProject/$roboflowVersion");
    final uri = url.replace(queryParameters: {
      "api_key": roboflowApiKey,
    });

    final resp = await http
        .post(
          uri,
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: base64Img,
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode == 200) {
      final Map<String, dynamic> jsonResp = jsonDecode(resp.body);
      final List<dynamic> preds = jsonResp['predictions'] ?? [];
      return preds.map((p) => Detection.fromMap(p)).toList();
    } else {
      throw Exception("Server error ${resp.statusCode}: ${resp.body}");
    }
  }
}
