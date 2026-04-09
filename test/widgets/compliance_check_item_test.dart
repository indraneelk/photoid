import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoid/widgets/compliance_check_item.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ComplianceCheckItem', () {
    testWidgets('shows passing icon and label', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const ComplianceCheckItem(
          label: 'Face detected',
          status: CheckStatus.passing,
        ),
      ));

      expect(find.text('Face detected'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows warning icon', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const ComplianceCheckItem(
          label: 'Move closer',
          status: CheckStatus.warning,
        ),
      ));

      expect(find.text('Move closer'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows failing icon', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const ComplianceCheckItem(
          label: 'No face',
          status: CheckStatus.failing,
        ),
      ));

      expect(find.text('No face'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('shows pending icon', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const ComplianceCheckItem(
          label: 'Waiting',
          status: CheckStatus.pending,
        ),
      ));

      expect(find.text('Waiting'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });
  });
}
