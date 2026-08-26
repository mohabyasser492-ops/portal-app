import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_icon_sizes.dart';
import 'package:portal_app/core/widgets/feedback/portal_loading_state.dart';

void main() {
  group('PortalLoadingState', () {
    testWidgets('renders a progress indicator', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalLoadingState()));

      expect(find.byType(PortalLoadingState), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders the provided message', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalLoadingState(message: 'Loading employee profile')),
      );

      expect(find.text('Loading employee profile'), findsOneWidget);
    });

    testWidgets('does not render a message when none is provided', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalLoadingState()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final textWidgets = find.descendant(
        of: find.byType(PortalLoadingState),
        matching: find.byType(Text),
      );

      expect(textWidgets, findsNothing);
    });

    testWidgets('uses the centered layout by default', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalLoadingState(message: 'Loading')));

      expect(
        find.descendant(of: find.byType(PortalLoadingState), matching: find.byType(Column)),
        findsOneWidget,
      );
    });

    testWidgets('uses a row for the inline layout', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalLoadingState(message: 'Refreshing', layout: PortalLoadingStateLayout.inline),
        ),
      );

      expect(
        find.descendant(of: find.byType(PortalLoadingState), matching: find.byType(Row)),
        findsOneWidget,
      );

      expect(find.text('Refreshing'), findsOneWidget);
    });

    testWidgets('uses the display indicator size by default', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalLoadingState()));

      final indicatorBox = _findIndicatorSizedBox(tester);

      expect(indicatorBox.width, PortalIconSizes.display);
      expect(indicatorBox.height, PortalIconSizes.display);
    });

    testWidgets('uses a smaller indicator in compact mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalLoadingState(
            message: 'Refreshing',
            compact: true,
            layout: PortalLoadingStateLayout.inline,
          ),
        ),
      );

      final indicatorBox = _findIndicatorSizedBox(tester);

      expect(indicatorBox.width, PortalIconSizes.lg);
      expect(indicatorBox.height, PortalIconSizes.lg);
    });

    testWidgets('uses the message as the default semantic label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(const PortalLoadingState(message: 'Loading employee profile')),
      );

      expect(find.bySemanticsLabel('Loading employee profile'), findsAtLeastNWidgets(1));

      semanticsHandle.dispose();
    });

    testWidgets('uses a custom semantic label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalLoadingState(
            message: 'Loading',
            semanticLabel: 'Loading the latest employee information',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Loading the latest employee information'),
        findsAtLeastNWidgets(1),
      );

      semanticsHandle.dispose();
    });

    testWidgets('uses a fallback semantic label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(_buildTestApp(const PortalLoadingState()));

      expect(find.bySemanticsLabel('Loading'), findsAtLeastNWidgets(1));

      semanticsHandle.dispose();
    });

    testWidgets('renders Arabic content in RTL', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalLoadingState(
            message: 'جاري تحميل بيانات الموظف',
            semanticLabel: 'جارٍ تحميل بيانات الموظف',
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      // Verify the rendered Arabic text
      expect(find.text('جاري تحميل بيانات الموظف'), findsOneWidget);

      // Verify the Arabic semantic label
      expect(find.bySemanticsLabel('جارٍ تحميل بيانات الموظف'), findsAtLeastNWidgets(1));

      semanticsHandle.dispose();
    });
  });
}

/// Helper method to build a testable widget environment
Widget _buildTestApp(Widget child, {TextDirection textDirection = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(body: child),
    ),
  );
}

/// Helper method to extract the SizedBox wrapping the CircularProgressIndicator
SizedBox _findIndicatorSizedBox(WidgetTester tester) {
  return tester.widget<SizedBox>(
    find
        .ancestor(of: find.byType(CircularProgressIndicator), matching: find.byType(SizedBox))
        .first,
  );
}
