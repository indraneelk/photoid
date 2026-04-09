import 'dart:io';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;

class BackgroundRemovalService {
  late final SelfieSegmenter _segmenter;

  BackgroundRemovalService() {
    _segmenter = SelfieSegmenter(
      mode: SegmenterMode.single,
      enableRawSizeMask: true,
    );
  }

  /// Remove background from image file and replace with solid color
  Future<img.Image?> removeBackground(
    String imagePath, {
    int bgRed = 255,
    int bgGreen = 255,
    int bgBlue = 255,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final mask = await _segmenter.processImage(inputImage);

    if (mask == null) return null;

    // Load original image
    final originalBytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(originalBytes);
    if (original == null) return null;

    // Apply mask
    final result = img.Image(
      width: original.width,
      height: original.height,
    );

    final maskWidth = mask.width;
    final maskHeight = mask.height;

    for (int y = 0; y < original.height; y++) {
      for (int x = 0; x < original.width; x++) {
        // Map image coordinates to mask coordinates
        final mx = (x * maskWidth / original.width).floor().clamp(0, maskWidth - 1);
        final my = (y * maskHeight / original.height).floor().clamp(0, maskHeight - 1);

        final confidence = mask.confidences[my * maskWidth + mx];
        final origPixel = original.getPixel(x, y);

        if (confidence > 0.5) {
          // Foreground (person) — keep original
          result.setPixel(x, y, origPixel);
        } else if (confidence > 0.2) {
          // Edge — blend
          final alpha = confidence;
          final r = (origPixel.r * alpha + bgRed * (1 - alpha)).round();
          final g = (origPixel.g * alpha + bgGreen * (1 - alpha)).round();
          final b = (origPixel.b * alpha + bgBlue * (1 - alpha)).round();
          result.setPixelRgb(x, y, r, g, b);
        } else {
          // Background — solid color
          result.setPixelRgb(x, y, bgRed, bgGreen, bgBlue);
        }
      }
    }

    return result;
  }

  void dispose() {
    _segmenter.close();
  }
}
