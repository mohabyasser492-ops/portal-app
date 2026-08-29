import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/portal_app.dart';

void main() {
  testWidgets('Portal App starts on the Home route', (tester) async {
    await tester.pumpWidget(const PortalApp());

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);

    expect(find.text('Home'), findsWidgets);

    expect(find.text('Feature coming soon'), findsOneWidget);

    expect(find.text('/'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
