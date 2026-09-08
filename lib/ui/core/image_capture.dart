import 'package:image_picker/image_picker.dart';

/// Shared camera/gallery capture helper used by both the receipt scanner
/// and the snap-a-meal flow, so picker setup isn't duplicated.
class ImageCapture {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage({required ImageSource source}) {
    return _picker.pickImage(source: source, imageQuality: 90);
  }
}
