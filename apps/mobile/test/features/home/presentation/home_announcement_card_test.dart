import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/home/domain/announcement_summary.dart';
import 'package:portal_app/features/home/presentation/widgets/home_announcement_card.dart';

void main() {
  group('HomeAnnouncementCard', () {
    testWidgets('displays announcement information', (tester) async {
      final announcement = _createAnnouncement();

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      expect(find.byType(HomeAnnouncementCard), findsOneWidget);

      expect(find.text('Synthetic portal announcement'), findsOneWidget);

      expect(
        find.text(
          'This is synthetic announcement content '
          'for frontend development.',
        ),
        findsOneWidget,
      );

      expect(find.text('2026-08-30'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays a pinned announcement', (tester) async {
      final announcement = _createAnnouncement(isPinned: true);

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      expect(find.text('Pinned'), findsOneWidget);

      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);

      expect(find.byIcon(Icons.campaign_outlined), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays an unpinned announcement', (tester) async {
      final announcement = _createAnnouncement(isPinned: false);

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      expect(find.text('Pinned'), findsNothing);

      expect(find.byIcon(Icons.push_pin_outlined), findsNothing);

      expect(find.byIcon(Icons.campaign_outlined), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not display a navigation icon without a callback', (
      tester,
    ) async {
      final announcement = _createAnnouncement();

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays a navigation icon when interactive', (tester) async {
      final announcement = _createAnnouncement();

      await tester.pumpWidget(
        _buildTestApp(
          HomeAnnouncementCard(announcement: announcement, onTap: () {}),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('calls the supplied callback', (tester) async {
      var tapCount = 0;

      final announcement = _createAnnouncement();

      await tester.pumpWidget(
        _buildTestApp(
          HomeAnnouncementCard(
            announcement: announcement,
            onTap: () {
              tapCount++;
            },
          ),
        ),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(HomeAnnouncementCard),
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
      final announcement = _createAnnouncement();

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(HomeAnnouncementCard),
        matching: find.byType(InkWell),
      );

      expect(inkWellFinder, findsOneWidget);

      await tester.tap(inkWellFinder);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('provides pinned announcement semantics', (tester) async {
      final announcement = _createAnnouncement(isPinned: true);

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      const expectedLabel =
          'Pinned announcement. '
          'Synthetic portal announcement. '
          'This is synthetic announcement content '
          'for frontend development. '
          'Published 2026-08-30.';

      final semantics = _findAnnouncementSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.container, isTrue);

      expect(semantics.properties.button, isFalse);

      expect(semantics.properties.label, expectedLabel);

      expect(tester.takeException(), isNull);
    });

    testWidgets('provides unpinned announcement semantics', (tester) async {
      final announcement = _createAnnouncement(isPinned: false);

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      const expectedLabel =
          'Synthetic portal announcement. '
          'This is synthetic announcement content '
          'for frontend development. '
          'Published 2026-08-30.';

      final semantics = _findAnnouncementSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.container, isTrue);

      expect(semantics.properties.button, isFalse);

      expect(semantics.properties.label, expectedLabel);

      expect(tester.takeException(), isNull);
    });

    testWidgets('marks an interactive announcement as a button', (
      tester,
    ) async {
      final announcement = _createAnnouncement(isPinned: true);

      await tester.pumpWidget(
        _buildTestApp(
          HomeAnnouncementCard(announcement: announcement, onTap: () {}),
        ),
      );

      const expectedLabel =
          'Pinned announcement. '
          'Synthetic portal announcement. '
          'This is synthetic announcement content '
          'for frontend development. '
          'Published 2026-08-30.';

      final semantics = _findAnnouncementSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.container, isTrue);

      expect(semantics.properties.button, isTrue);

      expect(semantics.properties.label, expectedLabel);

      expect(tester.takeException(), isNull);
    });

    testWidgets('formats single-digit month and day values', (tester) async {
      final announcement = AnnouncementSummary(
        id: 'announcement-date-test',
        title: 'Synthetic date announcement',
        summary: 'Synthetic date formatting content.',
        publishedAt: DateTime.utc(2026, 1, 5),
      );

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      expect(find.text('2026-01-05'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('includes the formatted date in semantics', (tester) async {
      final announcement = AnnouncementSummary(
        id: 'announcement-date-semantics',
        title: 'Synthetic date announcement',
        summary: 'Synthetic date formatting content.',
        publishedAt: DateTime.utc(2026, 1, 5),
      );

      await tester.pumpWidget(
        _buildTestApp(HomeAnnouncementCard(announcement: announcement)),
      );

      const expectedLabel =
          'Synthetic date announcement. '
          'Synthetic date formatting content. '
          'Published 2026-01-05.';

      final semantics = _findAnnouncementSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.properties.label, expectedLabel);

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports increased text scaling', (tester) async {
      final announcement = AnnouncementSummary(
        id: 'announcement-text-scaling',
        title: 'Synthetic announcement with a long descriptive title',
        summary:
            'This is a longer synthetic announcement summary used '
            'to verify increased text scaling without layout overflow.',
        publishedAt: DateTime.utc(2026, 8, 30),
        isPinned: true,
      );

      await tester.pumpWidget(
        _buildTestApp(
          HomeAnnouncementCard(announcement: announcement, onTap: () {}),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(HomeAnnouncementCard), findsOneWidget);

      expect(
        find.text('Synthetic announcement with a long descriptive title'),
        findsOneWidget,
      );

      expect(
        find.text(
          'This is a longer synthetic announcement summary used '
          'to verify increased text scaling without layout overflow.',
        ),
        findsOneWidget,
      );

      expect(find.text('Pinned'), findsOneWidget);

      expect(find.text('2026-08-30'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses directional layout in RTL', (tester) async {
      final announcement = AnnouncementSummary(
        id: 'announcement-rtl',
        title: 'إعلان تجريبي',
        summary:
            'هذا محتوى تجريبي لاختبار اتجاه العرض '
            'من اليمين إلى اليسار.',
        publishedAt: DateTime.utc(2026, 8, 30),
        isPinned: true,
      );

      await tester.pumpWidget(
        _buildTestApp(
          HomeAnnouncementCard(announcement: announcement, onTap: () {}),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.byType(HomeAnnouncementCard), findsOneWidget);

      expect(find.text('إعلان تجريبي'), findsOneWidget);

      expect(
        find.text(
          'هذا محتوى تجريبي لاختبار اتجاه العرض '
          'من اليمين إلى اليسار.',
        ),
        findsOneWidget,
      );

      expect(find.text('Pinned'), findsOneWidget);

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      final directionalityFinder = find.ancestor(
        of: find.byType(HomeAnnouncementCard),
        matching: find.byType(Directionality),
      );

      expect(directionalityFinder, findsWidgets);

      final directionality = tester.widget<Directionality>(
        directionalityFinder.first,
      );

      expect(directionality.textDirection, TextDirection.rtl);

      expect(tester.takeException(), isNull);
    });
  });
}

AnnouncementSummary _createAnnouncement({bool isPinned = true}) {
  return AnnouncementSummary(
    id: 'announcement-1',
    title: 'Synthetic portal announcement',
    summary:
        'This is synthetic announcement content '
        'for frontend development.',
    publishedAt: DateTime.utc(2026, 8, 30),
    isPinned: isPinned,
  );
}

Semantics _findAnnouncementSemantics(
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
        'HomeAnnouncementCard semantics with label '
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
