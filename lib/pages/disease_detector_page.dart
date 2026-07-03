import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/translation_service.dart';
import '../data/my_data.dart';
import '../functions/main_function.dart';
import '../services/roboflow_service.dart';
import '../widgets/image_painter.dart';
import 'scan_result_page.dart';

class DiseaseDetectorPage extends StatefulWidget {
  const DiseaseDetectorPage({super.key});

  @override
  State<DiseaseDetectorPage> createState() => _DiseaseDetectorPageState();
}

class _DiseaseDetectorPageState extends State<DiseaseDetectorPage> {
  File? _selectedImage;
  ui.Image? _uiImage;
  List<Detection> _detections = [];
  bool _loading = false;
  bool _saveToGallery = false;
  final MainFunction _mainFunction = MainFunction();
  final RoboflowService _roboflowService = RoboflowService();

  Future<void> _pickImage(ImageSource source) async {
    File? image = await _mainFunction.pickImage(source);
    if (image != null) {
      await _loadUiImage(image);
      setState(() {
        _selectedImage = image;
        _detections = [];
      });
      await _callRoboflow();
    }
  }

  Future<void> _loadUiImage(File f) async {
    final bytes = await f.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1024);
    final frame = await codec.getNextFrame();
    setState(() {
      _uiImage = frame.image;
    });
  }

  Future<void> _callRoboflow() async {
    if (_selectedImage == null) return;
    setState(() => _loading = true);
    try {
      final dets = await _roboflowService.detectDisease(_selectedImage!);
      
      await recordScanEvent();
      
      setState(() {
        _detections = dets;
      });
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultPage(
            image: _selectedImage,
            detections: _detections,
          ),
        ),
      );
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMessage(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = _uiImage == null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 10),
              Text(
                'No image selected'.tr,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          )
        : FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _uiImage!.width.toDouble(),
              height: _uiImage!.height.toDouble(),
              child: CustomPaint(
                painter:
                    ImagePainter(image: _uiImage!, detections: _detections),
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Disease Detector'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: const Icon(Icons.person, color: Colors.green),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Select a photo to analyze'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            // Image Placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: imageWidget,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Save to Gallery Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Save to Gallery'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: _saveToGallery,
                  onChanged: (value) {
                    setState(() {
                      _saveToGallery = value;
                    });
                  },
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text('Gallery'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text('Camera'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


