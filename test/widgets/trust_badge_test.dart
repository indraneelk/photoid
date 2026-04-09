import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoid/widgets/trust_badge.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('TrustBadge', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const TrustBadge(
          icon: Icons.lock_outline,
          label: '100% on-device',
        ),
      ));

      expect(find.text('100% on-device'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('renders different icon', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const TrustBadge(
          icon: Icons.bolt_outlined,
          label: '30-second process',
        ),
      ));

      expect(find.text('30-second process'), findsOneWidget);
      expect(find.byIcon(Icons.bolt_outlined), findsOneWidget);
    });
  });
}
