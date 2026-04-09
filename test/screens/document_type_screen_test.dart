import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoid/screens/document_type_screen.dart';
import 'package:photoid/theme/app_theme.dart';

void main() {
  group('DocumentTypeScreen', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DocumentTypeScreen(useCamera: true),
        ),
      );

      expect(find.text('Select Document Type'), findsOneWidget);
    });

    testWidgets('renders search field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DocumentTypeScreen(useCamera: true),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders popular countries', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DocumentTypeScreen(useCamera: true),
        ),
      );

      expect(find.textContaining('United States'), findsWidgets);
      expect(find.textContaining('United Kingdom'), findsWidgets);
    });

    testWidgets('search filters results', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DocumentTypeScreen(useCamera: true),
        ),
      );

      // Type "india" in search
      await tester.enterText(find.byType(TextField), 'india');
      await tester.pump();

      // India should be visible
      expect(find.textContaining('India'), findsWidgets);
      // US should not be visible
      expect(find.textContaining('United States'), findsNothing);
    });

    testWidgets('search is case insensitive', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DocumentTypeScreen(useCamera: true),
        ),
      );

      await tester.enterText(find.byType(TextField), 'CHINA');
      await tester.pump();

      expect(find.textContaining('China'), findsWidgets);
    });

    testWidgets('renders custom dimensions option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DocumentTypeScreen(useCamera: true),
        ),
      );

      expect(find.text('Enter custom dimensions'), findsOneWidget);
    });

    testWidgets('shows country codes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DocumentTypeScreen(useCamera: true),
        ),
      );

      expect(find.text('US'), findsWidgets);
      expect(find.text('GB'), findsOneWidget);
    });
  });
}
