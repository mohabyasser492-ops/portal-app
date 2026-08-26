import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/feedback/portal_error_state.dart';

void main() {
  group('PortalErrorState', () {
    testWidgets('renders the provided title', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalErrorState(title: 'Something went wrong')));

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

    testWidgets('does not render additional text when description is omitted', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalErrorState(title: 'Something went wrong')));

      final textFinder = find.descendant(
        of: find.byType(PortalErrorState),
        matching: find.byType(Text),
      );

      expect(textFinder, findsOneWidget);

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('handles an empty description without errors', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong', description: '')),
      );

      expect(find.text('Something went wrong'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles a whitespace-only description without errors', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalErrorState(title: 'Something went wrong', description: '   ')),
      );

      expect(find.text('Something went wrong'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the default error icon', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalErrorState(title: 'Something went wrong')));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders a custom error icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(title: 'No internet connection', icon: Icons.cloud_off_outlined),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('does not render actions when they are omitted', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalErrorState(title: 'Something went wrong')));

      expect(find.byType(ElevatedButton), findsNothing);

      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('renders a primary retry action', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load employee information',
            retryLabel: 'Try again',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Try again'), findsOneWidget);

      expect(find.byType(ElevatedButton), findsOneWidget);

      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('calls the retry action', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load employee information',
            retryLabel: 'Try again',
            onRetry: () {
              retryCount++;
            },
          ),
        ),
      );

      await tester.tap(find.text('Try again'));

      await tester.pump();

      expect(retryCount, 1);
    });

    testWidgets('renders a secondary action', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load employee information',
            secondaryActionLabel: 'Go back',
            onSecondaryAction: () {},
          ),
        ),
      );

      expect(find.text('Go back'), findsOneWidget);

      expect(find.byType(OutlinedButton), findsOneWidget);

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('calls the secondary action', (tester) async {
      var secondaryActionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to load employee information',
            secondaryActionLabel: 'Go back',
            onSecondaryAction: () {
              secondaryActionCount++;
            },
          ),
        ),
      );

      await tester.tap(find.text('Go back'));

      await tester.pump();

      expect(secondaryActionCount, 1);
    });

    testWidgets('renders both recovery actions', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to submit request',
            description: 'Try again or return to drafts.',
            retryLabel: 'Try again',
            onRetry: () {},
            secondaryActionLabel: 'Return to drafts',
            onSecondaryAction: () {},
          ),
        ),
      );

      expect(find.text('Try again'), findsOneWidget);

      expect(find.text('Return to drafts'), findsOneWidget);

      expect(find.byType(ElevatedButton), findsOneWidget);

      expect(find.byType(OutlinedButton), findsOneWidget);

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('calls both actions independently', (tester) async {
      var retryCount = 0;
      var secondaryActionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalErrorState(
            title: 'Unable to submit request',
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

      await tester.tap(find.text('Try again'));

      await tester.pump();

      expect(retryCount, 1);

      expect(secondaryActionCount, 0);

      await tester.tap(find.text('Return to drafts'));

      await tester.pump();

      expect(retryCount, 1);

      expect(secondaryActionCount, 1);
    });

    testWidgets('uses the title as the default semantic label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(_buildTestApp(const PortalErrorState(title: 'Something went wrong')));

      expect(find.bySemanticsLabel('Something went wrong'), findsAtLeastNWidgets(1));

      semanticsHandle.dispose();
    });

    testWidgets('combines title and description for semantics', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Unable to load employee information',
            description: 'Check your connection and try again.',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
          'Unable to load employee information. '
          'Check your connection and try again.',
        ),
        findsAtLeastNWidgets(1),
      );

      semanticsHandle.dispose();
    });

    testWidgets('uses a custom semantic label when provided', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalErrorState(
            title: 'Something went wrong',
            description: 'Please try again.',
            semanticLabel: 'Employee data failed to load',
          ),
        ),
      );

      expect(find.bySemanticsLabel('Employee data failed to load'), findsAtLeastNWidgets(1));

      semanticsHandle.dispose();
    });
  });
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    theme: PortalTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}
