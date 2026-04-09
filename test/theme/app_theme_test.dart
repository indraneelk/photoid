import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoid/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('primary is trust green', () {
      expect(AppColors.primary, const Color(0xFF1E6B4F));
    });

    test('success is green', () {
      expect(AppColors.success, const Color(0xFF22C55E));
    });

    test('error is red', () {
      expect(AppColors.error, const Color(0xFFEF4444));
    });

    test('text colors have sufficient contrast (not too light)', () {
      // textPrimary should be dark
      expect(AppColors.textPrimary.computeLuminance(), lessThan(0.1));
      // background should be light
      expect(AppColors.background.computeLuminance(), greaterThan(0.9));
    });
  });

  group('AppTheme', () {
    test('light theme uses correct primary color', () {
      final theme = AppTheme.light;
      expect(theme.colorScheme.primary, AppColors.primary);
    });

    test('light theme uses Material 3', () {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, true);
    });

    test('elevated button has full-width minimum size', () {
      final theme = AppTheme.light;
      final buttonStyle = theme.elevatedButtonTheme.style!;
      final minSize = buttonStyle.minimumSize!.resolve({});
      expect(minSize!.width, double.infinity);
      expect(minSize.height, 52);
    });

    test('scaffold background is warm white', () {
      final theme = AppTheme.light;
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('app bar is flat (no elevation)', () {
      final theme = AppTheme.light;
      expect(theme.appBarTheme.elevation, 0);
    });

    test('card has no elevation', () {
      final theme = AppTheme.light;
      expect(theme.cardTheme.elevation, 0);
    });
  });

  group('AppSpacing', () {
    test('follows 4/8 point scale', () {
      expect(AppSpacing.xs, 4);
      expect(AppSpacing.sm, 8);
      expect(AppSpacing.md, 16);
      expect(AppSpacing.lg, 24);
      expect(AppSpacing.xl, 32);
      expect(AppSpacing.xxl, 48);
    });
  });

  group('AppRadius', () {
    test('has sensible values', () {
      expect(AppRadius.sm, lessThan(AppRadius.md));
      expect(AppRadius.md, lessThan(AppRadius.lg));
      expect(AppRadius.lg, lessThan(AppRadius.xl));
      expect(AppRadius.full, 999);
    });
  });
}
