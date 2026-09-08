import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// On-device ("native") food-photo labeling: identifies broad labels for a
/// snapped meal photo (e.g. "rice", "salad", "bread") so the UI can suggest
/// matching entries from the food database for the user to confirm. This is
/// deliberately not a specific-dish classifier — ML Kit's bundled model is
/// general-purpose object/scene labeling, not a food-specific one.
class FoodRecognitionService {
  // Lazily created: ML Kit only ships native (Android/iOS) plugin
  // implementations, so constructing it on web would throw — this way that
  // only happens if food recognition is actually used.
  ImageLabeler? _labeler;

  /// Returns candidate labels sorted by confidence, highest first.
  /// Throws on web — callers should fall back to manual food search there.
  Future<List<String>> labelImage(String imagePath) async {
    if (kIsWeb) {
      throw UnsupportedError('On-device food recognition requires the mobile app (Android/iOS).');
    }
    _labeler ??= ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.6));
    final inputImage = InputImage.fromFilePath(imagePath);
    final labels = await _labeler!.processImage(inputImage);
    labels.sort((a, b) => b.confidence.compareTo(a.confidence));
    return labels.map((l) => l.label).toList();
  }

  void dispose() {
    _labeler?.close();
  }
}
