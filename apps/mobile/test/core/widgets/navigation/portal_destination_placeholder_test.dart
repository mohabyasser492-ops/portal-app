import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/core/widgets/cards/portal_card.dart';
import 'package:portal_app/core/widgets/navigation/portal_destination_placeholder.dart';
import 'package:portal_app/features/home/presentation/home_placeholder_page.dart';
import 'package:portal_app/features/profile/presentation/profile_placeholder_page.dart';
import 'package:portal_app/features/requests/presentation/requests_placeholder_page.dart';
import 'package:portal_app/features/services/presentation/services_placeholder_page.dart';

void main() {
  group('PortalDestinationPlaceholder', () {
    testWidgets('renders its title and description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDestinationPlaceholder(
            title: 'Home',
            description: 'Employee dashboard content.',
            icon: Icons.home_outlined,
            routePath: '/',
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);

      expect(find.text('Employee dashboard content.'), findsOneWidget);

      expect(find.text('Feature coming soon'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the supplied icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDestinationPlaceholder(
            title: 'Services',
            description: 'Employee services.',
            icon: Icons.apps_outlined,
            routePath: '/services',
          ),
        ),
      );

      expect(find.byIcon(Icons.apps_outlined), findsOneWidget);
    });

    testWidgets('renders the route path', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDestinationPlaceholder(
            title: 'Requests',
            description: 'Employee requests.',
            icon: Icons.description_outlined,
            routePath: '/requests',
          ),
        ),
      );

      expect(find.text('/requests'), findsOneWidget);
    });

    testWidgets('uses the shared PortalCard', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDestinationPlaceholder(
            title: 'Profile',
            description: 'Employee profile.',
            icon: Icons.person_outline,
            routePath: '/profile',
          ),
        ),
      );

      expect(find.byType(PortalCard), findsOneWidget);
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDestinationPlaceholder(
            title: 'الرئيسية',
            description: 'ستظهر لوحة معلومات الموظف في هذه الصفحة.',
            icon: Icons.home_outlined,
            routePath: '/',
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.text('الرئيسية'), findsOneWidget);

      expect(
        find.text('ستظهر لوحة معلومات الموظف في هذه الصفحة.'),
        findsOneWidget,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PortalDestinationPlaceholder(
            title: 'Employee services',
            description:
                'Employee services and available self-service actions will appear here.',
            icon: Icons.apps_outlined,
            routePath: '/services',
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(PortalDestinationPlaceholder), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });

  group('Destination placeholder pages', () {
    testWidgets('renders the Home destination', (tester) async {
      await tester.pumpWidget(_buildTestApp(const HomePlaceholderPage()));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('renders the Services destination', (tester) async {
      await tester.pumpWidget(_buildTestApp(const ServicesPlaceholderPage()));

      expect(find.text('Services'), findsOneWidget);
      expect(find.text('/services'), findsOneWidget);
      expect(find.byIcon(Icons.apps_outlined), findsOneWidget);
    });

    testWidgets('renders the Requests destination', (tester) async {
      await tester.pumpWidget(_buildTestApp(const RequestsPlaceholderPage()));

      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('/requests'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('renders the Profile destination', (tester) async {
      await tester.pumpWidget(_buildTestApp(const ProfilePlaceholderPage()));

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('/profile'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
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
        child: Scaffold(body: child),
      ),
    ),
  );
}
