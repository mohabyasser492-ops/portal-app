import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/home/domain/request_summary.dart';
import 'package:portal_app/features/home/presentation/widgets/home_recent_request_card.dart';

void main() {
  group('HomeRecentRequestCard', () {
    testWidgets('displays request information', (tester) async {
      final request = _createRequest();

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      expect(find.byType(HomeRecentRequestCard), findsOneWidget);

      expect(find.text('Synthetic leave request'), findsOneWidget);

      expect(find.text('REQ-00001'), findsOneWidget);

      expect(find.text('Pending'), findsOneWidget);

      expect(find.text('2026-08-30'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays the draft status', (tester) async {
      final request = _createRequest(status: RequestSummaryStatus.draft);

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      expect(find.text('Draft'), findsOneWidget);

      expect(find.byIcon(Icons.edit_note_outlined), findsWidgets);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays the pending status', (tester) async {
      final request = _createRequest(status: RequestSummaryStatus.pending);

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      expect(find.text('Pending'), findsOneWidget);

      expect(find.byIcon(Icons.schedule_outlined), findsWidgets);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays the approved status', (tester) async {
      final request = _createRequest(status: RequestSummaryStatus.approved);

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      expect(find.text('Approved'), findsOneWidget);

      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays the rejected status', (tester) async {
      final request = _createRequest(status: RequestSummaryStatus.rejected);

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      expect(find.text('Rejected'), findsOneWidget);

      expect(find.byIcon(Icons.cancel_outlined), findsWidgets);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not show the navigation icon without a callback', (
      tester,
    ) async {
      final request = _createRequest();

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the navigation icon when interactive', (tester) async {
      final request = _createRequest();

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request, onTap: () {})),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('calls the supplied callback', (tester) async {
      var tapCount = 0;

      final request = _createRequest();

      await tester.pumpWidget(
        _buildTestApp(
          HomeRecentRequestCard(
            request: request,
            onTap: () {
              tapCount++;
            },
          ),
        ),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(HomeRecentRequestCard),
        matching: find.byType(InkWell),
      );

      expect(inkWellFinder, findsOneWidget);

      await tester.tap(inkWellFinder);
      await tester.pump();

      expect(tapCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not throw when a non-interactive card is tapped', (
      tester,
    ) async {
      final request = _createRequest();

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(HomeRecentRequestCard),
        matching: find.byType(InkWell),
      );

      expect(inkWellFinder, findsOneWidget);

      await tester.tap(inkWellFinder);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('provides request accessibility semantics', (tester) async {
      final request = _createRequest();

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      const expectedLabel =
          'Synthetic leave request. '
          'Reference REQ-00001. '
          'Status Pending. '
          'Updated 2026-08-30.';

      final semantics = _findRequestSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.container, isTrue);

      expect(semantics.properties.button, isFalse);

      expect(semantics.properties.label, expectedLabel);

      expect(tester.takeException(), isNull);
    });

    testWidgets('marks an interactive request as a button', (tester) async {
      final request = _createRequest();

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request, onTap: () {})),
      );

      const expectedLabel =
          'Synthetic leave request. '
          'Reference REQ-00001. '
          'Status Pending. '
          'Updated 2026-08-30.';

      final semantics = _findRequestSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.properties.button, isTrue);

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses directional layout in RTL', (tester) async {
      final request = _createRequest();

      await tester.pumpWidget(
        _buildTestApp(
          HomeRecentRequestCard(request: request, onTap: () {}),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.byType(HomeRecentRequestCard), findsOneWidget);

      expect(find.text('Synthetic leave request'), findsOneWidget);

      expect(find.text('REQ-00001'), findsOneWidget);

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      final directionalityFinder = find.ancestor(
        of: find.byType(HomeRecentRequestCard),
        matching: find.byType(Directionality),
      );

      expect(directionalityFinder, findsWidgets);

      final directionality = tester.widget<Directionality>(
        directionalityFinder.first,
      );

      expect(directionality.textDirection, TextDirection.rtl);

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports increased text scaling', (tester) async {
      final request = _createRequest(
        title: 'Synthetic request with a long descriptive title',
      );

      await tester.pumpWidget(
        _buildTestApp(
          HomeRecentRequestCard(request: request, onTap: () {}),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(HomeRecentRequestCard), findsOneWidget);

      expect(
        find.text('Synthetic request with a long descriptive title'),
        findsOneWidget,
      );

      expect(find.text('REQ-00001'), findsOneWidget);

      expect(find.text('Pending'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('formats single-digit month and day values', (tester) async {
      final request = RequestSummary(
        id: 'request-date-test',
        title: 'Synthetic date test request',
        referenceNumber: 'REQ-00002',
        status: RequestSummaryStatus.approved,
        updatedAt: DateTime.utc(2026, 1, 5),
      );

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      expect(find.text('2026-01-05'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('includes the formatted date in semantics', (tester) async {
      final request = RequestSummary(
        id: 'request-date-semantics',
        title: 'Synthetic date test request',
        referenceNumber: 'REQ-00002',
        status: RequestSummaryStatus.approved,
        updatedAt: DateTime.utc(2026, 1, 5),
      );

      await tester.pumpWidget(
        _buildTestApp(HomeRecentRequestCard(request: request)),
      );

      const expectedLabel =
          'Synthetic date test request. '
          'Reference REQ-00002. '
          'Status Approved. '
          'Updated 2026-01-05.';

      final semantics = _findRequestSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.properties.label, expectedLabel);

      expect(tester.takeException(), isNull);
    });
  });
}

RequestSummary _createRequest({
  String title = 'Synthetic leave request',
  RequestSummaryStatus status = RequestSummaryStatus.pending,
}) {
  return RequestSummary(
    id: 'request-1',
    title: title,
    referenceNumber: 'REQ-00001',
    status: status,
    updatedAt: DateTime.utc(2026, 8, 30),
  );
}

Semantics _findRequestSemantics(
  WidgetTester tester, {
  required String expectedLabel,
}) {
  final finder = find.byWidgetPredicate(
    (widget) {
      return widget is Semantics &&
          widget.container == true &&
          widget.properties.label == expectedLabel;
    },
    description:
        'HomeRecentRequestCard semantics with label '
        '"$expectedLabel"',
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
            padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
            child: child,
          ),
        ),
      ),
    ),
  );
}
