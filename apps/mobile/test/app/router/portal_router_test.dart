import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_app/app/router/portal_route_names.dart';
import 'package:portal_app/app/router/portal_route_paths.dart';
import 'package:portal_app/app/router/portal_router.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/core/widgets/navigation/portal_navigation_shell.dart';
import 'package:portal_app/features/home/presentation/home_placeholder_page.dart';
import 'package:portal_app/features/not_found/presentation/not_found_page.dart';
import 'package:portal_app/features/profile/presentation/profile_placeholder_page.dart';
import 'package:portal_app/features/requests/presentation/requests_placeholder_page.dart';
import 'package:portal_app/features/services/presentation/services_placeholder_page.dart';

void main() {
  group('PortalRouter', () {
    testWidgets('starts on the Home route', (tester) async {
      final router = createPortalRouter();

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      expect(find.byType(HomePlaceholderPage), findsOneWidget);

      expect(find.byType(PortalNavigationShell), findsOneWidget);

      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.home,
      );

      router.dispose();
    });

    testWidgets('starts at a supplied initial location', (tester) async {
      final router = createPortalRouter(
        initialLocation: PortalRoutePaths.services,
      );

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      expect(find.byType(ServicesPlaceholderPage), findsOneWidget);

      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.services,
      );

      router.dispose();
    });

    testWidgets('navigates to Services from the navigation bar', (
      tester,
    ) async {
      final router = createPortalRouter();

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Services'));

      await tester.pumpAndSettle();

      expect(find.byType(ServicesPlaceholderPage), findsOneWidget);

      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.services,
      );

      router.dispose();
    });

    testWidgets('navigates to Requests from the navigation bar', (
      tester,
    ) async {
      final router = createPortalRouter();

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Requests'));

      await tester.pumpAndSettle();

      expect(find.byType(RequestsPlaceholderPage), findsOneWidget);

      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.requests,
      );

      router.dispose();
    });

    testWidgets('navigates to Profile from the navigation bar', (tester) async {
      final router = createPortalRouter();

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));

      await tester.pumpAndSettle();

      expect(find.byType(ProfilePlaceholderPage), findsOneWidget);

      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.profile,
      );

      router.dispose();
    });

    testWidgets('supports navigation by route name', (tester) async {
      final router = createPortalRouter();

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      router.goNamed(PortalRouteNames.requests);

      await tester.pumpAndSettle();

      expect(find.byType(RequestsPlaceholderPage), findsOneWidget);

      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.requests,
      );

      router.dispose();
    });

    testWidgets('shows the not-found page for an unknown route', (
      tester,
    ) async {
      final router = createPortalRouter(initialLocation: '/unknown-page');

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);

      expect(find.text('Page not found'), findsWidgets);

      expect(find.textContaining('/unknown-page'), findsOneWidget);

      router.dispose();
    });

    testWidgets('returns home from the not-found page', (tester) async {
      final router = createPortalRouter(initialLocation: '/unknown-page');

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);

      await tester.tap(find.text('Return home'));

      await tester.pumpAndSettle();

      expect(find.byType(HomePlaceholderPage), findsOneWidget);

      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.home,
      );

      router.dispose();
    });
  });
}

Widget _buildTestApp(GoRouter router) {
  return MaterialApp.router(
    title: 'Portal App Router Test',
    theme: PortalTheme.light,
    routerConfig: router,
  );
}
