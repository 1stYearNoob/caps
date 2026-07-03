import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MainFunction {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 80,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
