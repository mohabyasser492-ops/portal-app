import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/dialogs/portal_dialog.dart';

void main() {
  group('PortalDialog', () {
    testWidgets('renders its title', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalDialog(title: 'Employee information')));

      expect(find.byType(PortalDialog), findsOneWidget);

      expect(find.text('Employee information'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders its description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDialog(
            title: 'Employee information',
            description: 'Review the available employee information.',
          ),
        ),
      );

      expect(find.text('Employee information'), findsOneWidget);

      expect(find.text('Review the available employee information.'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles an empty description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalDialog(title: 'Employee information', description: '')),
      );

      expect(find.text('Employee information'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles a whitespace-only description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalDialog(title: 'Employee information', description: '   ')),
      );

      expect(find.text('Employee information'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders custom body content', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDialog(
            title: 'Request details',
            content: Text('Synthetic request preview content'),
          ),
        ),
      );

      expect(find.text('Request details'), findsOneWidget);

      expect(find.text('Synthetic request preview content'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders description and content together', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDialog(
            title: 'Request details',
            description: 'Review the request before continuing.',
            content: Text('Synthetic request preview content'),
          ),
        ),
      );

      expect(find.text('Review the request before continuing.'), findsOneWidget);

      expect(find.text('Synthetic request preview content'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the information icon by default', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalDialog(title: 'Information')));

      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the confirmation icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDialog(title: 'Submit request?', type: PortalDialogType.confirmation),
        ),
      );

      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the warning icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalDialog(title: 'Warning', type: PortalDialogType.warning)),
      );

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the destructive icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDialog(title: 'Delete draft?', type: PortalDialogType.destructive),
        ),
      );

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the success icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDialog(title: 'Request submitted', type: PortalDialogType.success),
        ),
      );

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a custom icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalDialog(title: 'Offline', icon: Icons.cloud_off_outlined)),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      expect(find.byIcon(Icons.info_outline), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a close button by default', (tester) async {
      await tester.pumpWidget(_buildTestApp(const PortalDialog(title: 'Information')));

      expect(find.byIcon(Icons.close), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('hides the close button when not dismissible', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalDialog(title: 'Required confirmation', dismissible: false)),
      );

      expect(find.byIcon(Icons.close), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('close button dismisses a dialog route', (tester) async {
      await tester.pumpWidget(_buildLauncherApp());

      await tester.tap(find.text('Open dialog'));

      await tester.pumpAndSettle();

      expect(find.byType(PortalDialog), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));

      await tester.pumpAndSettle();

      expect(find.byType(PortalDialog), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders and calls the primary action', (tester) async {
      var primaryActionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalDialog(
            title: 'Submit request?',
            primaryActionLabel: 'Submit',
            onPrimaryAction: () {
              primaryActionCount++;
            },
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);

      await tester.tap(find.text('Submit'));

      await tester.pump();

      expect(primaryActionCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders and calls the secondary action', (tester) async {
      var secondaryActionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalDialog(
            title: 'Submit request?',
            secondaryActionLabel: 'Cancel',
            onSecondaryAction: () {
              secondaryActionCount++;
            },
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));

      await tester.pump();

      expect(secondaryActionCount, 1);

      expect(tester.takeException(), isNull);
    });
  });
}

/// Builds a simple Material app containing the widget directly.
Widget _buildTestApp(Widget child) {
  return MaterialApp(
    theme: PortalTheme.light,
    home: Scaffold(body: child),
  );
}

/// Builds an app that opens PortalDialog through a route.
///
/// This is used to verify that the close button properly pops
/// the dialog route.
Widget _buildLauncherApp() {
  return MaterialApp(
    theme: PortalTheme.light,
    home: Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog<void>(
              context: navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (context) {
                return const PortalDialog(title: 'Information');
              },
            );
          },
          child: const Text('Open dialog'),
        ),
      ),
    ),
    navigatorKey: navigatorKey,
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
