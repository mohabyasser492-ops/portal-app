import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/main.dart';

void main() {
  testWidgets('Portal App renders the design system preview', (tester) async {
    await tester.pumpWidget(const PortalApp());

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    expect(find.byType(PortalDesignSystemPreviewPage), findsOneWidget);

    expect(find.text('Design system preview'), findsOneWidget);
  });
}
