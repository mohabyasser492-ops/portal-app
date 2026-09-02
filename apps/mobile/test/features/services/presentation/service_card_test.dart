import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/services/domain/portal_service.dart';
import 'package:portal_app/features/services/domain/service_category.dart';
import 'package:portal_app/features/services/presentation/widgets/service_card.dart';

void main() {
  group('ServiceCard', () {
    testWidgets('displays service information', (tester) async {
      const service = PortalService(
        id: 'service-001',
        name: 'Employment Letter',
        description:
            'Request a synthetic employment letter for frontend development.',
        category: ServiceCategory.documents,
        iconName: 'description',
      );

      await tester.pumpWidget(
        _buildTestApp(const ServiceCard(service: service)),
      );

      expect(find.byType(ServiceCard), findsOneWidget);

      expect(find.text('Employment Letter'), findsOneWidget);

      expect(
        find.text(
          'Request a synthetic employment letter '
          'for frontend development.',
        ),
        findsOneWidget,
      );

      expect(find.text('Documents'), findsOneWidget);

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays a featured service badge', (tester) async {
      const service = PortalService(
        id: 'service-featured',
        name: 'Featured Service',
        description: 'Synthetic featured service description.',
        category: ServiceCategory.general,
        iconName: 'apps',
        isFeatured: true,
      );

      await tester.pumpWidget(
        _buildTestApp(const ServiceCard(service: service)),
      );

      expect(find.text('Featured'), findsOneWidget);

      expect(find.byIcon(Icons.star_outline), findsOneWidget);

      expect(find.text('Unavailable'), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not display featured badge by default', (tester) async {
      const service = PortalService(
        id: 'service-standard',
        name: 'Standard Service',
        description: 'Synthetic standard service description.',
        category: ServiceCategory.general,
        iconName: 'apps',
      );

      await tester.pumpWidget(
        _buildTestApp(const ServiceCard(service: service)),
      );

      expect(find.text('Featured'), findsNothing);

      expect(find.byIcon(Icons.star_outline), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays an unavailable service badge', (tester) async {
      const service = PortalService(
        id: 'service-unavailable',
        name: 'Unavailable Service',
        description: 'Synthetic unavailable service description.',
        category: ServiceCategory.payroll,
        iconName: 'account_balance',
        isAvailable: false,
      );

      await tester.pumpWidget(
        _buildTestApp(const ServiceCard(service: service)),
      );

      expect(find.text('Unavailable'), findsOneWidget);

      expect(find.byIcon(Icons.block_outlined), findsOneWidget);

      expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not display a navigation icon without a callback', (
      tester,
    ) async {
      const service = PortalService(
        id: 'service-static',
        name: 'Static Service',
        description: 'Synthetic non-interactive service description.',
        category: ServiceCategory.general,
        iconName: 'apps',
      );

      await tester.pumpWidget(
        _buildTestApp(const ServiceCard(service: service)),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays a navigation icon for an interactive service', (
      tester,
    ) async {
      const service = PortalService(
        id: 'service-interactive',
        name: 'Interactive Service',
        description: 'Synthetic interactive service description.',
        category: ServiceCategory.general,
        iconName: 'apps',
      );

      await tester.pumpWidget(
        _buildTestApp(ServiceCard(service: service, onTap: () {})),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('calls callback for an available service', (tester) async {
      var tapCount = 0;

      const service = PortalService(
        id: 'service-interactive',
        name: 'Interactive Service',
        description: 'Synthetic interactive service description.',
        category: ServiceCategory.general,
        iconName: 'apps',
      );

      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(
            service: service,
            onTap: () {
              tapCount++;
            },
          ),
        ),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(ServiceCard),
        matching: find.byType(InkWell),
      );

      expect(inkWellFinder, findsOneWidget);

      await tester.tap(inkWellFinder);
      await tester.pump();

      expect(tapCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not call callback for an unavailable service', (
      tester,
    ) async {
      var tapCount = 0;

      const service = PortalService(
        id: 'service-unavailable',
        name: 'Unavailable Service',
        description: 'Synthetic unavailable service description.',
        category: ServiceCategory.payroll,
        iconName: 'account_balance',
        isAvailable: false,
      );

      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(
            service: service,
            onTap: () {
              tapCount++;
            },
          ),
        ),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(ServiceCard),
        matching: find.byType(InkWell),
      );

      expect(inkWellFinder, findsOneWidget);

      final inkWell = tester.widget<InkWell>(inkWellFinder);

      expect(inkWell.onTap, isNull);

      expect(find.byIcon(Icons.chevron_right), findsNothing);

      await tester.tap(inkWellFinder);
      await tester.pump();

      expect(tapCount, 0);

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the fallback icon for unknown icon names', (
      tester,
    ) async {
      const service = PortalService(
        id: 'service-unknown-icon',
        name: 'Unknown Icon Service',
        description: 'Synthetic service with an unknown icon name.',
        category: ServiceCategory.general,
        iconName: 'unknown_icon_name',
      );

      await tester.pumpWidget(
        _buildTestApp(const ServiceCard(service: service)),
      );

      expect(find.byIcon(Icons.apps_outlined), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('maps all known service icons', (tester) async {
      const iconCases = <String, IconData>{
        'description': Icons.description_outlined,
        'event_available': Icons.event_available_outlined,
        'payments': Icons.payments_outlined,
        'person': Icons.person_outline,
        'health_and_safety': Icons.health_and_safety_outlined,
        'help_outline': Icons.help_outline,
        'verified_user': Icons.verified_user_outlined,
        'calendar_month': Icons.calendar_month_outlined,
        'account_balance': Icons.account_balance_outlined,
      };

      for (final entry in iconCases.entries) {
        final service = PortalService(
          id: 'service-${entry.key}',
          name: 'Synthetic ${entry.key} service',
          description: 'Synthetic service used to verify icon mapping.',
          category: ServiceCategory.general,
          iconName: entry.key,
        );

        await tester.pumpWidget(_buildTestApp(ServiceCard(service: service)));

        expect(
          find.byIcon(entry.value),
          findsOneWidget,
          reason: 'Expected ${entry.key} to map to ${entry.value}.',
        );

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('displays the Human Resources category', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(
            service: _createService(category: ServiceCategory.humanResources),
          ),
        ),
      );

      expect(find.text('Human Resources'), findsOneWidget);
    });

    testWidgets('displays the Leave category', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(service: _createService(category: ServiceCategory.leave)),
        ),
      );

      expect(find.text('Leave'), findsOneWidget);
    });

    testWidgets('displays the Payroll category', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(
            service: _createService(category: ServiceCategory.payroll),
          ),
        ),
      );

      expect(find.text('Payroll'), findsOneWidget);
    });

    testWidgets('displays the Documents category', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(
            service: _createService(category: ServiceCategory.documents),
          ),
        ),
      );

      expect(find.text('Documents'), findsOneWidget);
    });

    testWidgets('displays the Profile category', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(
            service: _createService(category: ServiceCategory.profile),
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('displays the General category', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(
            service: _createService(category: ServiceCategory.general),
          ),
        ),
      );

      expect(find.text('General'), findsOneWidget);
    });

    testWidgets('provides semantics for an available service', (tester) async {
      const service = PortalService(
        id: 'service-semantic',
        name: 'Employment Letter',
        description: 'Request a synthetic employment letter.',
        category: ServiceCategory.documents,
        iconName: 'description',
      );

      await tester.pumpWidget(
        _buildTestApp(const ServiceCard(service: service)),
      );

      const expectedLabel =
          'Employment Letter. '
          'Request a synthetic employment letter. '
          'Category Documents. '
          'Available. ';

      final semantics = _findServiceSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.container, isTrue);

      expect(semantics.properties.button, isFalse);

      expect(semantics.properties.enabled, isTrue);

      expect(semantics.properties.label, expectedLabel);

      expect(tester.takeException(), isNull);
    });

    testWidgets('provides semantics for a featured service', (tester) async {
      const service = PortalService(
        id: 'service-featured-semantic',
        name: 'Leave Request',
        description: 'Create a synthetic employee leave request.',
        category: ServiceCategory.leave,
        iconName: 'event_available',
        isFeatured: true,
      );

      await tester.pumpWidget(
        _buildTestApp(const ServiceCard(service: service)),
      );

      const expectedLabel =
          'Featured service. '
          'Leave Request. '
          'Create a synthetic employee leave request. '
          'Category Leave. '
          'Available. ';

      final semantics = _findServiceSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.properties.label, expectedLabel);

      expect(semantics.properties.enabled, isTrue);

      expect(tester.takeException(), isNull);
    });

    testWidgets('marks an interactive available service as a button', (
      tester,
    ) async {
      const service = PortalService(
        id: 'service-button-semantic',
        name: 'General Inquiry',
        description: 'Send a synthetic general inquiry.',
        category: ServiceCategory.general,
        iconName: 'help_outline',
      );

      await tester.pumpWidget(
        _buildTestApp(ServiceCard(service: service, onTap: () {})),
      );

      const expectedLabel =
          'General Inquiry. '
          'Send a synthetic general inquiry. '
          'Category General. '
          'Available. ';

      final semantics = _findServiceSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.properties.button, isTrue);

      expect(semantics.properties.enabled, isTrue);

      expect(tester.takeException(), isNull);
    });

    testWidgets('provides semantics for unavailable service', (tester) async {
      const service = PortalService(
        id: 'service-unavailable-semantic',
        name: 'Bank Details Update',
        description: 'Request a synthetic payroll bank update.',
        category: ServiceCategory.payroll,
        iconName: 'account_balance',
        isAvailable: false,
      );

      await tester.pumpWidget(
        _buildTestApp(ServiceCard(service: service, onTap: () {})),
      );

      const expectedLabel =
          'Bank Details Update. '
          'Request a synthetic payroll bank update. '
          'Category Payroll. '
          'Currently unavailable. ';

      final semantics = _findServiceSemantics(
        tester,
        expectedLabel: expectedLabel,
      );

      expect(semantics.properties.button, isFalse);

      expect(semantics.properties.enabled, isFalse);

      expect(semantics.properties.label, expectedLabel);

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports increased text scaling', (tester) async {
      const service = PortalService(
        id: 'service-text-scaling',
        name: 'Synthetic Service With a Long Descriptive Name',
        description:
            'This synthetic service description verifies increased '
            'text scaling without layout overflow.',
        category: ServiceCategory.humanResources,
        iconName: 'health_and_safety',
        isFeatured: true,
      );

      await tester.pumpWidget(
        _buildTestApp(
          const ServiceCard(service: service),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(ServiceCard), findsOneWidget);

      expect(
        find.text('Synthetic Service With a Long Descriptive Name'),
        findsOneWidget,
      );

      expect(
        find.text(
          'This synthetic service description verifies increased '
          'text scaling without layout overflow.',
        ),
        findsOneWidget,
      );

      expect(find.text('Human Resources'), findsOneWidget);

      expect(find.text('Featured'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses directional layout in RTL', (tester) async {
      const service = PortalService(
        id: 'service-rtl',
        name: 'خدمة تجريبية',
        description: 'وصف تجريبي لاختبار اتجاه العرض.',
        category: ServiceCategory.general,
        iconName: 'apps',
      );

      await tester.pumpWidget(
        _buildTestApp(
          ServiceCard(service: service, onTap: () {}),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.byType(ServiceCard), findsOneWidget);

      expect(find.text('خدمة تجريبية'), findsOneWidget);

      expect(find.text('وصف تجريبي لاختبار اتجاه العرض.'), findsOneWidget);

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      final directionalityFinder = find.ancestor(
        of: find.byType(ServiceCard),
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

PortalService _createService({required ServiceCategory category}) {
  return PortalService(
    id: 'service-${category.name}',
    name: 'Synthetic ${category.name} service',
    description: 'Synthetic service used to verify category labels.',
    category: category,
    iconName: 'apps',
  );
}

Semantics _findServiceSemantics(
  WidgetTester tester, {
  required String expectedLabel,
}) {
  final finder = find.byWidgetPredicate((widget) {
    return widget is Semantics &&
        widget.container == true &&
        widget.properties.label == expectedLabel;
  }, description: 'ServiceCard semantics with label "$expectedLabel"');

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
