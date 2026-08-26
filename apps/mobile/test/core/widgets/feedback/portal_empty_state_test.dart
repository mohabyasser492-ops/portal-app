import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/buttons/portal_button.dart';
import 'package:portal_app/core/widgets/feedback/portal_empty_state.dart';

void main() {
  group('PortalEmptyState', () {
    testWidgets('renders the title and description', (tester) async {
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

    testWidgets('renders the default icon', (tester) async {
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

    testWidgets('does not render an action when omitted', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalEmptyState(title: 'No announcements')),
      );

      expect(find.byType(PortalButton), findsNothing);
    });

    testWidgets('renders and calls the optional action', (tester) async {
      var actionCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          PortalEmptyState(
            title: 'No search results',
            description: 'Try a different search term.',
            actionLabel: 'Clear search',
            onAction: () {
              actionCount++;
            },
          ),
        ),
      );

      expect(find.byType(PortalButton), findsOneWidget);
      expect(find.text('Clear search'), findsOneWidget);

      await tester.tap(find.text('Clear search'));
      await tester.pump();

      expect(actionCount, 1);
    });

    testWidgets('uses title as semantic label without description', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalEmptyState(title: 'No announcements')),
      );

      final semanticsWidget = _findEmptyStateSemantics(tester);

      expect(semanticsWidget.properties.label, 'No announcements');
    });

    testWidgets('combines title and description for semantics', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(
            title: 'No announcements',
            description: 'New announcements will appear here.',
          ),
        ),
      );

      final semanticsWidget = _findEmptyStateSemantics(tester);

      expect(
        semanticsWidget.properties.label,
        'No announcements. '
        'New announcements will appear here.',
      );
    });

    testWidgets('uses a custom semantic label', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalEmptyState(
            title: 'No announcements',
            description: 'New announcements will appear here.',
            semanticLabel: 'The announcement list is currently empty',
          ),
        ),
      );

      final semanticsWidget = _findEmptyStateSemantics(tester);

      expect(
        semanticsWidget.properties.label,
        'The announcement list is currently empty',
      );
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
  });
}

Semantics _findEmptyStateSemantics(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PortalEmptyState),
    matching: find.byWidgetPredicate((widget) {
      return widget is Semantics &&
          widget.container == true &&
          widget.properties.label != null;
    }),
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
