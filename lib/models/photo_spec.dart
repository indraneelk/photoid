class PhotoSpec {
  final String country;
  final String countryCode;
  final String documentType;
  final double widthMm;
  final double heightMm;
  final int widthPx;
  final int heightPx;
  final int dpi;
  final String backgroundColor;
  final double headSizeMinPercent;
  final double headSizeMaxPercent;

  const PhotoSpec({
    required this.country,
    required this.countryCode,
    required this.documentType,
    required this.widthMm,
    required this.heightMm,
    required this.widthPx,
    required this.heightPx,
    required this.dpi,
    this.backgroundColor = '#FFFFFF',
    this.headSizeMinPercent = 50,
    this.headSizeMaxPercent = 69,
  });

  String get dimensionLabel =>
      '${widthMm.toStringAsFixed(0)}x${heightMm.toStringAsFixed(0)}mm';

  static const List<PhotoSpec> popular = [
    PhotoSpec(
      country: 'United States',
      countryCode: 'US',
      documentType: 'Passport',
      widthMm: 51,
      heightMm: 51,
      widthPx: 600,
      heightPx: 600,
      dpi: 300,
    ),
    PhotoSpec(
      country: 'United States',
      countryCode: 'US',
      documentType: 'Visa',
      widthMm: 51,
      heightMm: 51,
      widthPx: 600,
      heightPx: 600,
      dpi: 300,
    ),
    PhotoSpec(
      country: 'United Kingdom',
      countryCode: 'GB',
      documentType: 'Passport',
      widthMm: 35,
      heightMm: 45,
      widthPx: 413,
      heightPx: 531,
      dpi: 300,
    ),
    PhotoSpec(
      country: 'Schengen',
      countryCode: 'EU',
      documentType: 'Visa',
      widthMm: 35,
      heightMm: 45,
      widthPx: 413,
      heightPx: 531,
      dpi: 300,
    ),
    PhotoSpec(
      country: 'India',
      countryCode: 'IN',
      documentType: 'Passport',
      widthMm: 51,
      heightMm: 51,
      widthPx: 600,
      heightPx: 600,
      dpi: 300,
    ),
    PhotoSpec(
      country: 'China',
      countryCode: 'CN',
      documentType: 'Visa',
      widthMm: 33,
      heightMm: 48,
      widthPx: 390,
      heightPx: 567,
      dpi: 300,
    ),
    PhotoSpec(
      country: 'Canada',
      countryCode: 'CA',
      documentType: 'Passport',
      widthMm: 50,
      heightMm: 70,
      widthPx: 591,
      heightPx: 827,
      dpi: 300,
    ),
    PhotoSpec(
      country: 'Australia',
      countryCode: 'AU',
      documentType: 'Passport',
      widthMm: 35,
      heightMm: 45,
      widthPx: 413,
      heightPx: 531,
      dpi: 300,
    ),
  ];
}
