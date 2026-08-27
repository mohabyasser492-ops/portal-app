import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/feedback/portal_error_state.dart';

void main() {
  group('PortalErrorState', () {
    testWidgets('renders the provided title', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      expect(find.byType(PortalErrorState), findsOneWidget);

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders the provided description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Unable to load employee information',
            description: 'Check your connection and try again.',
          ),
        ),
      );

      expect(find.text('Unable to load employee information'), findsOneWidget);

      expect(find.text('Check your connection and try again.'), findsOneWidget);
    });

    testWidgets('does not render additional text when description is omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      final textFinder = find.descendant(
        of: find.byType(PortalErrorState),
        matching: find.byType(Text),
      );

      expect(textFinder, findsOneWidget);

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('handles an empty description without errors', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Something went wrong',
            description: '',
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles a whitespace-only description without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Something went wrong',
            description: '   ',
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the default error icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders a custom error icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'No internet connection',
            icon: Icons.cloud_off_outlined,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('does not render actions when they are omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      expect(find.text('Try again'), findsNothing);

      expect(find.text('Go back'), findsNothing);
    });

    testWidgets('renders and calls a retry action', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load data',
            retryLabel: 'Try again',
            onRetry: () {
              retryCount++;
            },
          ),
        ),
      );

      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));

      await tester.pump();

      expect(retryCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders and calls a secondary action', (tester) async {
      var actionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load employee information',
            secondaryActionLabel: 'Go back',
            onSecondaryAction: () {
              actionCount++;
            },
          ),
        ),
      );

      expect(find.text('Go back'), findsOneWidget);

      await tester.tap(find.text('Go back'));

      await tester.pump();

      expect(actionCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders and calls both recovery actions', (tester) async {
      var retryCount = 0;
      var secondaryActionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to submit request',
            description: 'Try again or return to drafts.',
            retryLabel: 'Try again',
            onRetry: () {
              retryCount++;
            },
            secondaryActionLabel: 'Return to drafts',
            onSecondaryAction: () {
              secondaryActionCount++;
            },
          ),
        ),
      );

      expect(find.text('Try again'), findsOneWidget);

      expect(find.text('Return to drafts'), findsOneWidget);

      expect(
        find.descendant(
          of: find.byType(PortalErrorState),
          matching: find.byType(Wrap),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Try again'));

      await tester.pump();

      expect(retryCount, 1);
      expect(secondaryActionCount, 0);

      await tester.tap(find.text('Return to drafts'));

      await tester.pump();

      expect(retryCount, 1);
      expect(secondaryActionCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the title as the default semantic label', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      final semanticsWidget = _findErrorStateSemantics(tester);

      expect(semanticsWidget.properties.label, 'Something went wrong');

      expect(semanticsWidget.properties.liveRegion, isTrue);
    });

    testWidgets('combines title and description for semantics', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Unable to load employee information',
            description: 'Check your connection and try again.',
          ),
        ),
      );

      final semanticsWidget = _findErrorStateSemantics(tester);

      expect(
        semanticsWidget.properties.label,
        'Unable to load employee information. '
        'Check your connection and try again.',
      );

      expect(semanticsWidget.properties.liveRegion, isTrue);
    });

    testWidgets('uses a custom semantic label when provided', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Unable to load employee information',
            description: 'Check your connection and try again.',
            semanticLabel: 'Employee data failed to load',
          ),
        ),
      );

      final semanticsWidget = _findErrorStateSemantics(tester);

      expect(semanticsWidget.properties.label, 'Employee data failed to load');
    });

    testWidgets('falls back to title for a blank semantic label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Something went wrong',
            semanticLabel: '   ',
          ),
        ),
      );

      final semanticsWidget = _findErrorStateSemantics(tester);

      expect(semanticsWidget.properties.label, 'Something went wrong');
    });

    testWidgets('uses the supplied padding', (tester) async {
      const customPadding = EdgeInsetsDirectional.all(8);

      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Something went wrong',
            padding: customPadding,
          ),
        ),
      );

      final matchingPaddingWidgets = tester
          .widgetList<Padding>(
            find.descendant(
              of: find.byType(PortalErrorState),
              matching: find.byType(Padding),
            ),
          )
          .where((paddingWidget) {
            return paddingWidget.padding == customPadding;
          });

      expect(matchingPaddingWidgets, isNotEmpty);
    });

    testWidgets('limits the content width', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      final constrainedBoxFinder = find.descendant(
        of: find.byType(PortalErrorState),
        matching: find.byType(ConstrainedBox),
      );

      expect(constrainedBoxFinder, findsOneWidget);

      final constrainedBox = tester.widget<ConstrainedBox>(
        constrainedBoxFinder,
      );

      expect(constrainedBox.constraints.maxWidth, 480);
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'تعذر تحميل البيانات',
            description: 'تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى.',
            retryLabel: 'إعادة المحاولة',
            onRetry: () {},
            secondaryActionLabel: 'رجوع',
            onSecondaryAction: () {},
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('تعذر تحميل البيانات'), findsOneWidget);

      expect(
        find.text('تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى.'),
        findsOneWidget,
      );

      expect(find.text('إعادة المحاولة'), findsOneWidget);

      expect(find.text('رجوع'), findsOneWidget);

      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports mixed Arabic and English content', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'تعذر تحميل Employee Profile',
            description: 'Check the connection ثم حاول مرة أخرى.',
            retryLabel: 'Retry إعادة المحاولة',
            onRetry: () {},
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('تعذر تحميل Employee Profile'), findsOneWidget);

      expect(
        find.text('Check the connection ثم حاول مرة أخرى.'),
        findsOneWidget,
      );

      expect(find.text('Retry إعادة المحاولة'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load the latest employee information',
            description:
                'Check your internet connection and try loading the employee information again.',
            retryLabel: 'Try loading again',
            onRetry: () {},
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(PortalErrorState), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('wraps long action labels without overflow', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to submit the request',
            description: 'Choose one of the available recovery actions.',
            retryLabel: 'Try submitting the request again',
            onRetry: () {},
            secondaryActionLabel: 'Return to the saved request drafts',
            onSecondaryAction: () {},
          ),
          textScaler: const TextScaler.linear(1.5),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(PortalErrorState),
          matching: find.byType(Wrap),
        ),
        findsOneWidget,
      );

      expect(find.text('Try submitting the request again'), findsOneWidget);

      expect(find.text('Return to the saved request drafts'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow in compact mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to refresh',
            description: 'Try again in a moment.',
            retryLabel: 'Retry',
            onRetry: () {},
            compact: true,
          ),
          textScaler: const TextScaler.linear(1.5),
        ),
      );

      expect(find.byType(PortalErrorState), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}

Semantics _findErrorStateSemantics(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PortalErrorState),
    matching: find.byWidgetPredicate((widget) {
      return widget is Semantics &&
          widget.container == true &&
          widget.properties.liveRegion == true &&
          widget.properties.label != null;
    }, description: 'PortalErrorState semantics widget'),
  );

  expect(finder, findsOneWidget);

  return tester.widget<Semantics>(finder);
}

Widget _buildTestApp(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    theme: PortalTheme.light,
    home: MediaQuery(
      data: MediaQueryData(size: const Size(390, 844), textScaler: textScaler),
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}
