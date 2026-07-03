import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../services/roboflow_service.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final List<Detection> detections;
  
  const ImagePainter({required this.image, required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    // draw image
    final paint = Paint();
    
    canvas.drawImage(image, Offset.zero, paint);

    // overlay boxes
    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // Thicker line for better visibility

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final d in detections) {
      final left = d.x - d.width / 2;
      final top = d.y - d.height / 2;
      final rect = Rect.fromLTWH(left, top, d.width, d.height);

      // color based on confidence
      double c = d.confidence;
      final color = Color.fromARGB(
          255,
          (255 * (1 - c)).toInt().clamp(0, 255),
          (255 * c).toInt().clamp(0, 255),
          0);
      boxPaint.color = color;
      canvas.drawRect(rect, boxPaint);

      // draw label background
      final label = "${d.label} ${(d.confidence * 100).toStringAsFixed(0)}%";
      textPainter.text = TextSpan(
          text: label,
          style: const TextStyle(color: Colors.white, fontSize: 16));
      textPainter.layout();
      final bgRect = Rect.fromLTWH(rect.left,
          rect.top - textPainter.height - 4, textPainter.width + 8, textPainter.height + 4);
      final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
      canvas.drawRect(bgRect, bgPaint);
      textPainter.paint(
          canvas, Offset(rect.left + 4, rect.top - textPainter.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
