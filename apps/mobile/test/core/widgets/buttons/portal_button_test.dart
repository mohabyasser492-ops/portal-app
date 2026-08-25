import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/buttons/portal_button.dart';

void main() {
  group('PortalButton', () {
    testWidgets('renders the provided label', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(PortalButton(label: 'Continue', onPressed: () {})),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls the callback when pressed', (tester) async {
      var pressCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(
            label: 'Continue',
            onPressed: () {
              pressCount++;
            },
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(pressCount, 1);
    });

    testWidgets('does not call the callback when disabled', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalButton(label: 'Continue', onPressed: null)),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('shows a progress indicator while loading', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(label: 'Submitting', isLoading: true, onPressed: () {}),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submitting'), findsNothing);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('renders the secondary variant', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(
            label: 'Cancel',
            variant: PortalButtonVariant.secondary,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders the text variant', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(
            label: 'Learn more',
            variant: PortalButtonVariant.text,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders the destructive variant', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(
            label: 'Delete',
            variant: PortalButtonVariant.destructive,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders leading and trailing icons', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(
            label: 'Continue',
            leadingIcon: Icons.person,
            trailingIcon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('expands to the available width', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(label: 'Continue', expand: true, onPressed: () {}),
        ),
      );

      final matchingBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((box) => box.width == double.infinity);

      expect(matchingBoxes, isNotEmpty);
    });

    testWidgets('exposes an accessible semantic label', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(
            label: 'Continue',
            semanticLabel: 'Continue to employee profile',
            onPressed: () {},
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Continue to employee profile'),
        findsOneWidget,
      );

      semantics.dispose();
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(
            label: 'متابعة',
            leadingIcon: Icons.person,
            trailingIcon: Icons.arrow_forward,
            onPressed: () {},
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('متابعة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalButton(
            label: 'Continue to employee profile',
            expand: true,
            onPressed: () {},
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildTestApp(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    theme: PortalTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: Center(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    ),
  );
}
