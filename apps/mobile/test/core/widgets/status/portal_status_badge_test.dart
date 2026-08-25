import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_colors.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/core/widgets/status/portal_status_badge.dart';

void main() {
  group('PortalStatusBadge', () {
    testWidgets('renders the provided label', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalStatusBadge(label: 'Approved', type: PortalStatusType.success)),
      );

      expect(find.text('Approved'), findsOneWidget);
      expect(find.byType(PortalStatusBadge), findsOneWidget);
    });

    testWidgets('renders success appearance', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalStatusBadge(label: 'Approved', type: PortalStatusType.success)),
      );

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      final decoration = _findBadgeDecoration(tester);

      expect(decoration.color, PortalColors.statusSuccessSurface);
    });

    testWidgets('renders warning appearance', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalStatusBadge(label: 'Pending', type: PortalStatusType.warning)),
      );

      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);

      final decoration = _findBadgeDecoration(tester);

      expect(decoration.color, PortalColors.statusWarningSurface);
    });

    testWidgets('renders error appearance', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalStatusBadge(label: 'Rejected', type: PortalStatusType.error)),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      final decoration = _findBadgeDecoration(tester);

      expect(decoration.color, PortalColors.statusErrorSurface);
    });

    testWidgets('renders information appearance', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalStatusBadge(label: 'Information', type: PortalStatusType.information),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      final decoration = _findBadgeDecoration(tester);

      expect(decoration.color, PortalColors.statusInformationSurface);
    });

    testWidgets('renders neutral appearance', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalStatusBadge(label: 'Draft', type: PortalStatusType.neutral)),
      );

      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

      final decoration = _findBadgeDecoration(tester);

      expect(decoration.color, PortalColors.surfaceTertiary);
    });

    testWidgets('communicates status using text and icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const PortalStatusBadge(label: 'Approved', type: PortalStatusType.success)),
      );

      expect(find.text('Approved'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('exposes the default semantic label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(const PortalStatusBadge(label: 'Approved', type: PortalStatusType.success)),
      );

      expect(find.bySemanticsLabel('Approved'), findsAtLeastNWidgets(1));

      semanticsHandle.dispose();
    });

    testWidgets('exposes a custom semantic label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildTestApp(
          const PortalStatusBadge(
            label: 'Approved',
            semanticLabel: 'Request status: approved',
            type: PortalStatusType.success,
          ),
        ),
      );

      expect(find.bySemanticsLabel('Request status: approved'), findsAtLeastNWidgets(1));

      semanticsHandle.dispose();
    });

    testWidgets('uses smaller dimensions in compact mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalStatusBadge(label: 'Draft', type: PortalStatusType.neutral, compact: true),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.circle_outlined));

      expect(icon.size, 16);
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalStatusBadge(
            label: 'قيد المراجعة',
            semanticLabel: 'حالة الطلب: قيد المراجعة',
            type: PortalStatusType.warning,
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('قيد المراجعة'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports mixed Arabic and English text', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalStatusBadge(label: 'Approved مقبول', type: PortalStatusType.success),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('Approved مقبول'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalStatusBadge(label: 'Pending manager review', type: PortalStatusType.warning),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(PortalStatusBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

BoxDecoration _findBadgeDecoration(WidgetTester tester) {
  final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox));

  final decoration = decoratedBox.decoration;

  expect(decoration, isA<BoxDecoration>());

  return decoration as BoxDecoration;
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
            child: Align(alignment: AlignmentDirectional.topStart, child: child),
          ),
        ),
      ),
    ),
  );
}
