import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoid/screens/home_screen.dart';
import 'package:photoid/theme/app_theme.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders app title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );

      expect(find.text('PhotoID'), findsOneWidget);
    });

    testWidgets('renders privacy message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );

      expect(
        find.textContaining('Never uploaded'),
        findsOneWidget,
      );
    });

    testWidgets('renders Take New Photo button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );

      expect(find.text('Take New Photo'), findsOneWidget);
    });

    testWidgets('renders Upload Existing Photo button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );

      expect(find.text('Upload Existing Photo'), findsOneWidget);
    });

    testWidgets('renders trust badges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );

      expect(find.text('100% on-device'), findsOneWidget);
      expect(find.text('30-second process'), findsOneWidget);
      expect(find.text('Government compliant'), findsOneWidget);
    });

    testWidgets('tapping Take New Photo navigates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );

      await tester.tap(find.text('Take New Photo'));
      await tester.pumpAndSettle();

      // Should navigate to DocumentTypeScreen
      expect(find.text('Select Document Type'), findsOneWidget);
    });

    testWidgets('renders shield icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );

      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });
  });
}
