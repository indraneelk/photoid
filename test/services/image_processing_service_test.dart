import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:photoid/models/photo_spec.dart';
import 'package:photoid/services/image_processing_service.dart';

void main() {
  late ImageProcessingService service;

  setUp(() {
    service = ImageProcessingService();
  });

  group('cropToSpec', () {
    test('crops square image to square spec', () {
      final source = img.Image(width: 1000, height: 1000);
      const spec = PhotoSpec(
        country: 'US',
        countryCode: 'US',
        documentType: 'Passport',
        widthMm: 51,
        heightMm: 51,
        widthPx: 600,
        heightPx: 600,
        dpi: 300,
      );

      final result = service.cropToSpec(source, spec);
      expect(result.width, 600);
      expect(result.height, 600);
    });

    test('crops wide image to portrait spec', () {
      final source = img.Image(width: 1600, height: 900);
      const spec = PhotoSpec(
        country: 'GB',
        countryCode: 'GB',
        documentType: 'Passport',
        widthMm: 35,
        heightMm: 45,
        widthPx: 413,
        heightPx: 531,
        dpi: 300,
      );

      final result = service.cropToSpec(source, spec);
      expect(result.width, 413);
      expect(result.height, 531);
    });

    test('crops tall image to square spec', () {
      final source = img.Image(width: 800, height: 1200);
      const spec = PhotoSpec(
        country: 'US',
        countryCode: 'US',
        documentType: 'Passport',
        widthMm: 51,
        heightMm: 51,
        widthPx: 600,
        heightPx: 600,
        dpi: 300,
      );

      final result = service.cropToSpec(source, spec);
      expect(result.width, 600);
      expect(result.height, 600);
    });

    test('preserves aspect ratio of spec', () {
      final source = img.Image(width: 2000, height: 3000);
      const spec = PhotoSpec(
        country: 'CA',
        countryCode: 'CA',
        documentType: 'Passport',
        widthMm: 50,
        heightMm: 70,
        widthPx: 591,
        heightPx: 827,
        dpi: 300,
      );

      final result = service.cropToSpec(source, spec);
      expect(result.width, 591);
      expect(result.height, 827);

      final resultAspect = result.width / result.height;
      final specAspect = spec.widthPx / spec.heightPx;
      expect(resultAspect, closeTo(specAspect, 0.01));
    });

    test('handles small source image', () {
      final source = img.Image(width: 100, height: 100);
      const spec = PhotoSpec(
        country: 'US',
        countryCode: 'US',
        documentType: 'Passport',
        widthMm: 51,
        heightMm: 51,
        widthPx: 600,
        heightPx: 600,
        dpi: 300,
      );

      // Should still produce correct dimensions (upscaled)
      final result = service.cropToSpec(source, spec);
      expect(result.width, 600);
      expect(result.height, 600);
    });
  });

  group('generatePrintLayout', () {
    test('generates 4x6 layout with 4 copies', () {
      final photo = img.Image(width: 600, height: 600);
      const spec = PhotoSpec(
        country: 'US',
        countryCode: 'US',
        documentType: 'Passport',
        widthMm: 51,
        heightMm: 51,
        widthPx: 600,
        heightPx: 600,
        dpi: 300,
      );

      final layout = service.generatePrintLayout(photo, spec, copies: 4);
      // 4x6" at 300 DPI = 1200x1800
      expect(layout.width, 1800);
      expect(layout.height, 1200);
    });

    test('generates layout with 6 copies', () {
      final photo = img.Image(width: 600, height: 600);
      const spec = PhotoSpec(
        country: 'US',
        countryCode: 'US',
        documentType: 'Passport',
        widthMm: 51,
        heightMm: 51,
        widthPx: 600,
        heightPx: 600,
        dpi: 300,
      );

      final layout = service.generatePrintLayout(photo, spec, copies: 6);
      expect(layout.width, 1800);
      expect(layout.height, 1200);
    });

    test('generates layout with 2 copies', () {
      final photo = img.Image(width: 600, height: 600);
      const spec = PhotoSpec(
        country: 'US',
        countryCode: 'US',
        documentType: 'Passport',
        widthMm: 51,
        heightMm: 51,
        widthPx: 600,
        heightPx: 600,
        dpi: 300,
      );

      final layout = service.generatePrintLayout(photo, spec, copies: 2);
      expect(layout.width, 1800);
      expect(layout.height, 1200);
    });

    test('layout background is white', () {
      final photo = img.Image(width: 100, height: 100);
      // Fill photo with red so we can distinguish from background
      img.fill(photo, color: img.ColorRgb8(255, 0, 0));

      const spec = PhotoSpec(
        country: 'US',
        countryCode: 'US',
        documentType: 'Passport',
        widthMm: 51,
        heightMm: 51,
        widthPx: 600,
        heightPx: 600,
        dpi: 300,
      );

      final layout = service.generatePrintLayout(photo, spec, copies: 1);
      // Check corner pixel is white (background)
      final corner = layout.getPixel(0, 0);
      expect(corner.r, 255);
      expect(corner.g, 255);
      expect(corner.b, 255);
    });
  });
}
