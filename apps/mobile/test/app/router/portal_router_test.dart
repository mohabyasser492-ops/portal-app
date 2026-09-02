import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_app/app/router/portal_route_names.dart';
import 'package:portal_app/app/router/portal_route_paths.dart';
import 'package:portal_app/app/router/portal_router.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/core/widgets/navigation/portal_navigation_shell.dart';
import 'package:portal_app/features/home/presentation/home_page.dart';
import 'package:portal_app/features/not_found/presentation/not_found_page.dart';
//import 'package:portal_app/features/profile/presentation/profile_page.dart';
import 'package:portal_app/features/requests/presentation/requests_placeholder_page.dart';
import 'package:portal_app/features/services/application/services_catalog_providers.dart';
import 'package:portal_app/features/services/data/fake_services_repository.dart';
import 'package:portal_app/features/services/presentation/services_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portal_app/app/router/authentication_router_refresh_notifier.dart';
import 'package:portal_app/features/authentication/application/authentication_state.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';
import 'package:portal_app/features/home/application/home_providers.dart';
import 'package:portal_app/features/home/data/fake_home_repository.dart';

void main() {
  const authenticatedUser = PortalUser(
    id: 'test-user',
    displayName: 'Test Employee',
    email: 'test@example.invalid',
  );
  group('PortalRouter', () {
    testWidgets('starts on the Home route', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(refreshNotifier: refreshNotifier);

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      expect(find.byType(PortalNavigationShell), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.home);

      router.dispose();
    });

    testWidgets('starts at a supplied initial location', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(
        initialLocation: PortalRoutePaths.services,
        refreshNotifier: refreshNotifier,
      );

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      expect(find.byType(ServicesPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.services);

      router.dispose();
    });

    testWidgets('navigates to Services from the navigation bar', (tester) async {
      await _setTestViewport(tester, const Size(390, 844));

      final bundle = _createSignedInRouter();

      await tester.pumpWidget(_buildTestApp(bundle.router));

      await tester.pumpAndSettle();

      final navigationBarFinder = find.byType(NavigationBar);

      expect(navigationBarFinder, findsOneWidget);

      expect(find.byType(NavigationRail), findsNothing);

      final servicesDestinationFinder = find.descendant(
        of: navigationBarFinder,
        matching: find.text('Services'),
      );

      expect(servicesDestinationFinder, findsOneWidget);

      await tester.tap(servicesDestinationFinder);

      await tester.pumpAndSettle();

      expect(find.byType(ServicesPage), findsOneWidget);

      expect(bundle.router.routeInformationProvider.value.uri.path, PortalRoutePaths.services);

      expect(tester.takeException(), isNull);

      await bundle.dispose(tester);
    });

    testWidgets('navigates to Requests from the navigation bar', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(
        initialLocation: PortalRoutePaths.services,
        refreshNotifier: refreshNotifier,
      );

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Requests'));

      await tester.pumpAndSettle();

      expect(find.byType(RequestsPlaceholderPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.requests);

      router.dispose();
    });

    /*testWidgets('navigates to Profile from the navigation bar', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(
        initialLocation: PortalRoutePaths.services,
        refreshNotifier: refreshNotifier,
      );

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));

      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.profile);

      router.dispose();
    });
*/
    testWidgets('supports navigation by route name', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(
        initialLocation: PortalRoutePaths.services,
        refreshNotifier: refreshNotifier,
      );

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      router.goNamed(PortalRouteNames.requests);

      await tester.pumpAndSettle();

      expect(find.byType(RequestsPlaceholderPage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.requests);

      router.dispose();
    });

    testWidgets('shows the not-found page for an unknown route', (tester) async {
      final bundle = _createSignedInRouter(initialLocation: '/unknown-page');

      await tester.pumpWidget(_buildTestApp(bundle.router));

      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);

      expect(find.text('Page not found'), findsWidgets);

      expect(find.text('Return home'), findsOneWidget);

      expect(bundle.router.routeInformationProvider.value.uri.path, '/unknown-page');

      expect(tester.takeException(), isNull);

      await bundle.dispose(tester);
    });

    testWidgets('returns home from the not-found page', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(
        initialLocation: '/unknown-route',
        refreshNotifier: refreshNotifier,
      );

      await tester.pumpWidget(_buildTestApp(router));

      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);

      await tester.tap(find.text('Return home'));

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      expect(router.routeInformationProvider.value.uri.path, PortalRoutePaths.home);

      await tester.pumpWidget(const SizedBox.shrink());

      await tester.pump();

      router.dispose();
      refreshNotifier.dispose();
    });
  });
}

Future<void> _setTestViewport(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;

  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pump();
}

_TestRouterBundle _createSignedInRouter({String initialLocation = PortalRoutePaths.home}) {
  const authenticatedUser = PortalUser(
    id: 'test-user',
    displayName: 'Test Employee',
    email: 'test@example.invalid',
  );

  final refreshNotifier = AuthenticationRouterRefreshNotifier(
    initialState: const AuthenticationState.signedIn(authenticatedUser),
  );

  final router = createPortalRouter(
    initialLocation: initialLocation,
    refreshNotifier: refreshNotifier,
  );

  return _TestRouterBundle(router: router, refreshNotifier: refreshNotifier);
}

final class _TestRouterBundle {
  const _TestRouterBundle({required this.router, required this.refreshNotifier});

  final GoRouter router;

  final AuthenticationRouterRefreshNotifier refreshNotifier;

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());

    await tester.pump();

    router.dispose();
    refreshNotifier.dispose();
  }
}

Widget _buildTestApp(GoRouter router) {
  return ProviderScope(
    overrides: [
      homeRepositoryProvider.overrideWithValue(FakeHomeRepository(operationDelay: Duration.zero)),
      servicesRepositoryProvider.overrideWithValue(
        FakeServicesRepository(operationDelay: Duration.zero),
      ),
    ],
    child: MaterialApp.router(
      title: 'Portal App Router Test',
      theme: PortalTheme.light,
      routerConfig: router,
    ),
  );
}
