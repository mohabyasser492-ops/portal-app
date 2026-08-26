import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_icon_sizes.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/buttons/portal_button.dart';
import 'package:portal_app/core/widgets/feedback/portal_empty_state.dart';

void main() {
  group('PortalEmptyState', () {
    testWidgets('renders the provided title', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalEmptyState(title: 'No announcements')),
      );

      expect(find.byType(PortalEmptyState), findsOneWidget);
      expect(find.text('No announcements'), findsOneWidget);
    });

    testWidgets('renders the provided description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(
            title: 'No announcements',
            description: 'New announcements will appear here.',
          ),
        ),
      );

      expect(find.text('No announcements'), findsOneWidget);
      expect(find.text('New announcements will appear here.'), findsOneWidget);
    });

    testWidgets('does not render a description when omitted', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalEmptyState(title: 'No announcements')),
      );

      final textWidgets = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(PortalEmptyState),
          matching: find.byType(Text),
        ),
      );

      expect(textWidgets.length, 1);
      expect(textWidgets.first.data, 'No announcements');
    });

    testWidgets('renders the default empty-state icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalEmptyState(title: 'No announcements')),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders a custom icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(
            title: 'No search results',
            icon: Icons.search_off_outlined,
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('uses the display icon size by default', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalEmptyState(title: 'No announcements')),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_outlined));

      expect(icon.size, PortalIconSizes.display);
    });

    testWidgets('uses a smaller icon in compact mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(title: 'No announcements', compact: true),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_outlined));

      expect(icon.size, PortalIconSizes.xl);
    });

    testWidgets('does not render an action when omitted', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalEmptyState(title: 'No announcements')),
      );

      expect(find.byType(PortalButton), findsNothing);
    });

    testWidgets('renders an optional action', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalEmptyState(
            title: 'No search results',
            description: 'Try a different search term.',
            icon: Icons.search_off_outlined,
            actionLabel: 'Clear search',
            onAction: () {},
          ),
        ),
      );

      expect(find.byType(PortalButton), findsOneWidget);
      expect(find.text('Clear search'), findsOneWidget);
    });

    testWidgets('calls the optional action', (tester) async {
      var actionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalEmptyState(
            title: 'No search results',
            actionLabel: 'Clear search',
            onAction: () {
              actionCount++;
            },
          ),
        ),
      );

      await tester.tap(find.text('Clear search'));
      await tester.pump();

      expect(actionCount, 1);
    });

    testWidgets('uses title as semantic label without description', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(const PortalEmptyState(title: 'No announcements')),
      );

      expect(
        find.bySemanticsLabel('No announcements'),
        findsAtLeastNWidgets(1),
      );

      semanticsHandle.dispose();
    });

    testWidgets('combines title and description for semantics', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(
            title: 'No announcements',
            description: 'New announcements will appear here.',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
          'No announcements. '
          'New announcements will appear here.',
        ),
        findsAtLeastNWidgets(1),
      );

      semanticsHandle.dispose();
    });

    testWidgets('uses a custom semantic label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(
            title: 'No announcements',
            description: 'New announcements will appear here.',
            semanticLabel: 'The announcement list is currently empty',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('The announcement list is currently empty'),
        findsAtLeastNWidgets(1),
      );

      semanticsHandle.dispose();
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalEmptyState(
            title: 'لا توجد طلبات',
            description: 'ستظهر الطلبات المقدمة في هذه الصفحة.',
            icon: Icons.description_outlined,
            actionLabel: 'إنشاء طلب',
            onAction: () {},
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('لا توجد طلبات'), findsOneWidget);
      expect(find.text('ستظهر الطلبات المقدمة في هذه الصفحة.'), findsOneWidget);
      expect(find.text('إنشاء طلب'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports mixed Arabic and English content', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(
            title: 'لا توجد Requests',
            description: 'No requests متاحة حاليًا.',
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('لا توجد Requests'), findsOneWidget);
      expect(find.text('No requests متاحة حاليًا.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          PortalEmptyState(
            title: 'No employee requests are currently available',
            description:
                'Submitted employee requests will appear here after they are created.',
            actionLabel: 'Create a new request',
            onAction: () {},
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(PortalEmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow in compact mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(
            title: 'No recent items',
            description: 'Recent items will appear here.',
            compact: true,
          ),
          textScaler: const TextScaler.linear(1.5),
        ),
      );

      expect(find.byType(PortalEmptyState), findsOneWidget);
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
