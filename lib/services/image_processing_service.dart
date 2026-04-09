import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/photo_spec.dart';

class ImageProcessingService {
  /// Crop and resize image to match photo spec dimensions
  img.Image cropToSpec(img.Image source, PhotoSpec spec) {
    final targetAspect = spec.widthPx / spec.heightPx;
    final sourceAspect = source.width / source.height;

    int cropWidth, cropHeight, offsetX, offsetY;

    if (sourceAspect > targetAspect) {
      // Source is wider — crop sides
      cropHeight = source.height;
      cropWidth = (cropHeight * targetAspect).round();
      offsetX = ((source.width - cropWidth) / 2).round();
      offsetY = 0;
    } else {
      // Source is taller — crop top/bottom
      cropWidth = source.width;
      cropHeight = (cropWidth / targetAspect).round();
      offsetX = 0;
      offsetY = ((source.height - cropHeight) / 3).round(); // Bias toward top (face is usually upper)
    }

    final cropped = img.copyCrop(
      source,
      x: offsetX,
      y: offsetY,
      width: cropWidth,
      height: cropHeight,
    );

    return img.copyResize(
      cropped,
      width: spec.widthPx,
      height: spec.heightPx,
      interpolation: img.Interpolation.cubic,
    );
  }

  /// Generate a 4x6" print layout with multiple copies
  img.Image generatePrintLayout(img.Image photo, PhotoSpec spec, {int copies = 4}) {
    // 4x6" at 300 DPI = 1200x1800 pixels
    const layoutWidth = 1800; // 6 inches (landscape)
    const layoutHeight = 1200; // 4 inches

    final layout = img.Image(
      width: layoutWidth,
      height: layoutHeight,
    );

    // Fill with white
    img.fill(layout, color: img.ColorRgb8(255, 255, 255));

    // Calculate grid
    int cols, rows;
    if (copies <= 2) {
      cols = 2;
      rows = 1;
    } else if (copies <= 4) {
      cols = 2;
      rows = 2;
    } else {
      cols = 3;
      rows = 2;
    }

    final cellWidth = layoutWidth ~/ cols;
    final cellHeight = layoutHeight ~/ rows;

    // Scale photo to fit cells with padding
    final padding = 20;
    final maxPhotoWidth = cellWidth - padding * 2;
    final maxPhotoHeight = cellHeight - padding * 2;

    final scale = (maxPhotoWidth / photo.width).clamp(0.0, maxPhotoHeight / photo.height);
    final scaledPhoto = img.copyResize(
      photo,
      width: (photo.width * scale).round(),
      height: (photo.height * scale).round(),
      interpolation: img.Interpolation.cubic,
    );

    // Place photos in grid
    int placed = 0;
    for (int row = 0; row < rows && placed < copies; row++) {
      for (int col = 0; col < cols && placed < copies; col++) {
        final x = col * cellWidth + (cellWidth - scaledPhoto.width) ~/ 2;
        final y = row * cellHeight + (cellHeight - scaledPhoto.height) ~/ 2;

        img.compositeImage(layout, scaledPhoto, dstX: x, dstY: y);

        // Draw cut guides (light gray dashed lines)
        if (col < cols - 1) {
          final lineX = (col + 1) * cellWidth;
          for (int ly = 0; ly < layoutHeight; ly += 6) {
            if (ly + 3 < layoutHeight) {
              layout.setPixelRgb(lineX, ly, 200, 200, 200);
              layout.setPixelRgb(lineX, ly + 1, 200, 200, 200);
              layout.setPixelRgb(lineX, ly + 2, 200, 200, 200);
            }
          }
        }
        if (row < rows - 1) {
          final lineY = (row + 1) * cellHeight;
          for (int lx = 0; lx < layoutWidth; lx += 6) {
            if (lx + 3 < layoutWidth) {
              layout.setPixelRgb(lx, lineY, 200, 200, 200);
              layout.setPixelRgb(lx + 1, lineY, 200, 200, 200);
              layout.setPixelRgb(lx + 2, lineY, 200, 200, 200);
            }
          }
        }

        placed++;
      }
    }

    return layout;
  }

  /// Save image to temporary file and return path
  Future<String> saveToTemp(img.Image image, String filename) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$filename';
    final bytes = img.encodeJpg(image, quality: 95);
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// Save image to app documents directory
  Future<String> saveToDocuments(img.Image image, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$filename';
    final bytes = img.encodeJpg(image, quality: 95);
    await File(path).writeAsBytes(bytes);
    return path;
  }
}
