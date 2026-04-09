import 'package:flutter_test/flutter_test.dart';
import 'package:photoid/models/photo_spec.dart';

void main() {
  group('PhotoSpec', () {
    test('dimensionLabel formats correctly', () {
      const spec = PhotoSpec(
        country: 'United States',
        countryCode: 'US',
        documentType: 'Passport',
        widthMm: 51,
        heightMm: 51,
        widthPx: 600,
        heightPx: 600,
        dpi: 300,
      );
      expect(spec.dimensionLabel, '51x51mm');
    });

    test('dimensionLabel handles non-square specs', () {
      const spec = PhotoSpec(
        country: 'United Kingdom',
        countryCode: 'GB',
        documentType: 'Passport',
        widthMm: 35,
        heightMm: 45,
        widthPx: 413,
        heightPx: 531,
        dpi: 300,
      );
      expect(spec.dimensionLabel, '35x45mm');
    });

    test('popular list is not empty', () {
      expect(PhotoSpec.popular.isNotEmpty, true);
    });

    test('popular list contains US Passport', () {
      final usPassport = PhotoSpec.popular.where(
        (s) => s.countryCode == 'US' && s.documentType == 'Passport',
      );
      expect(usPassport.length, 1);
      expect(usPassport.first.widthMm, 51);
      expect(usPassport.first.heightMm, 51);
    });

    test('all popular specs have valid DPI', () {
      for (final spec in PhotoSpec.popular) {
        expect(spec.dpi, greaterThan(0));
      }
    });

    test('all popular specs have valid pixel dimensions', () {
      for (final spec in PhotoSpec.popular) {
        expect(spec.widthPx, greaterThan(0));
        expect(spec.heightPx, greaterThan(0));
      }
    });

    test('all popular specs have country code', () {
      for (final spec in PhotoSpec.popular) {
        expect(spec.countryCode.length, greaterThanOrEqualTo(2));
      }
    });

    test('default head size range is 50-69%', () {
      const spec = PhotoSpec(
        country: 'Test',
        countryCode: 'XX',
        documentType: 'Test',
        widthMm: 35,
        heightMm: 45,
        widthPx: 413,
        heightPx: 531,
        dpi: 300,
      );
      expect(spec.headSizeMinPercent, 50);
      expect(spec.headSizeMaxPercent, 69);
    });

    test('default background is white', () {
      const spec = PhotoSpec(
        country: 'Test',
        countryCode: 'XX',
        documentType: 'Test',
        widthMm: 35,
        heightMm: 45,
        widthPx: 413,
        heightPx: 531,
        dpi: 300,
      );
      expect(spec.backgroundColor, '#FFFFFF');
    });
  });
}
