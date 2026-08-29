import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/feedback/portal_error_state.dart';

void main() {
  group('PortalErrorState', () {
    testWidgets('renders the title', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      expect(find.byType(PortalErrorState), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Unable to load data',
            description: 'Check your connection and try again.',
          ),
        ),
      );

      expect(find.text('Unable to load data'), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
    });

    testWidgets('renders the default icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders a custom icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Connection unavailable',
            icon: Icons.cloud_off_outlined,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('does not render recovery actions when omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      expect(find.text('Try again'), findsNothing);
      expect(find.text('Go back'), findsNothing);
    });

    testWidgets('renders and calls the retry action', (tester) async {
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

    testWidgets('renders and calls the secondary action', (tester) async {
      var actionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load data',
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
            description: 'Choose a recovery action.',
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

    testWidgets('uses the title as the semantic label', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong')),
      );

      final semantics = _findErrorSemantics(tester);

      expect(semantics.properties.label, 'Something went wrong');
      expect(semantics.properties.liveRegion, isTrue);
    });

    testWidgets('combines title and description for semantics', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Unable to load data',
            description: 'Check your connection.',
          ),
        ),
      );

      final semantics = _findErrorSemantics(tester);

      expect(
        semantics.properties.label,
        'Unable to load data. Check your connection.',
      );
    });

    testWidgets('uses a custom semantic label', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Unable to load data',
            semanticLabel: 'Employee data failed to load',
          ),
        ),
      );

      final semantics = _findErrorSemantics(tester);

      expect(semantics.properties.label, 'Employee data failed to load');
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
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      expect(find.text('رجوع'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports increased text scaling', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load the latest employee information',
            description:
                'Check the connection and try loading the information again.',
            retryLabel: 'Try loading again',
            onRetry: () {},
            secondaryActionLabel: 'Return to previous page',
            onSecondaryAction: () {},
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(PortalErrorState), findsOneWidget);
      expect(find.text('Try loading again'), findsOneWidget);
      expect(find.text('Return to previous page'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports compact mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to refresh',
            description: 'Try again in a moment.',
            retryLabel: 'Retry',
            onRetry: () {},
            compact: true,
          ),
        ),
      );

      expect(find.byType(PortalErrorState), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Semantics _findErrorSemantics(WidgetTester tester) {
  final finder = find.byWidgetPredicate((widget) {
    return widget is Semantics &&
        widget.properties.liveRegion == true &&
        widget.properties.label != null;
  }, description: 'PortalErrorState semantics');

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
