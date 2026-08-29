import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_app/app/portal_app.dart';
import 'package:portal_app/app/router/portal_route_paths.dart';
import 'package:portal_app/app/router/portal_router.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/core/widgets/navigation/portal_navigation_shell.dart';
import 'package:portal_app/features/authentication/application/authentication_providers.dart';
import 'package:portal_app/features/authentication/domain/authentication_repository.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';
import 'package:portal_app/features/home/presentation/home_placeholder_page.dart';
import 'package:portal_app/features/not_found/presentation/not_found_page.dart';
import 'package:portal_app/features/profile/presentation/profile_placeholder_page.dart';
import 'package:portal_app/features/requests/presentation/requests_placeholder_page.dart';
import 'package:portal_app/features/services/presentation/services_placeholder_page.dart';
import 'package:portal_app/app/router/authentication_router_refresh_notifier.dart';
import 'package:portal_app/features/authentication/application/authentication_state.dart';

class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Design system preview')));
  }
}

void main() {
  const authenticatedUser = PortalUser(
    id: 'test-user',
    displayName: 'Test Employee',
    email: 'test@example.invalid',
  );
  group('PortalApp', () {
    testWidgets('uses the Portal application theme', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(refreshNotifier: refreshNotifier);
      final repository = _SignedInAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        materialApp.theme?.colorScheme.primary,
        PortalColors.actionPrimary,
      );
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('starts on the Home destination', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(refreshNotifier: refreshNotifier);
      final repository = _SignedInAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomePlaceholderPage), findsOneWidget);
      expect(find.byType(PortalNavigationShell), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.home,
      );
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('navigates between primary destinations', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(refreshNotifier: refreshNotifier);
      final repository = _SignedInAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      await _tapCompactDestination(tester, 'Services');

      expect(find.byType(ServicesPlaceholderPage), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.services,
      );

      await _tapCompactDestination(tester, 'Requests');

      expect(find.byType(RequestsPlaceholderPage), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.requests,
      );

      await _tapCompactDestination(tester, 'Profile');

      expect(find.byType(ProfilePlaceholderPage), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.profile,
      );

      await _tapCompactDestination(tester, 'Home');

      expect(find.byType(HomePlaceholderPage), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.home,
      );
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('opens the design-system preview', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(refreshNotifier: refreshNotifier);
      final repository = _SignedInAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open design system'));
      await tester.pumpAndSettle();

      expect(find.byType(DesignSystemPreviewPage), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.designSystem,
      );
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('returns to the active branch from the preview', (
      tester,
    ) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(
        initialLocation: PortalRoutePaths.services,
        refreshNotifier: refreshNotifier,
      );
      final repository = _SignedInAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ServicesPlaceholderPage), findsOneWidget);

      await tester.tap(find.byTooltip('Open design system'));
      await tester.pumpAndSettle();

      expect(find.byType(DesignSystemPreviewPage), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.byType(ServicesPlaceholderPage), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.services,
      );
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('shows a safe fallback for an unknown route', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(
        initialLocation: '/unknown-route',
        refreshNotifier: refreshNotifier,
      );
      final repository = _SignedInAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);
      expect(find.text('Page not found'), findsWidgets);
      expect(find.textContaining('/unknown-route'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('returns home from the unknown-route page', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(
        initialLocation: '/unknown-route',
        refreshNotifier: refreshNotifier,
      );
      final repository = _SignedInAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsOneWidget);

      await tester.tap(find.text('Return home'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePlaceholderPage), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        PortalRoutePaths.home,
      );
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('uses bottom navigation on a compact screen', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(refreshNotifier: refreshNotifier);
      final repository = _SignedInAuthenticationRepository();

      await _setTestViewport(tester, const Size(390, 844));

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });

    testWidgets('uses a navigation rail on a wide screen', (tester) async {
      final refreshNotifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      final router = createPortalRouter(refreshNotifier: refreshNotifier);
      final repository = _SignedInAuthenticationRepository();

      await _setTestViewport(tester, const Size(1024, 768));

      await tester.pumpWidget(
        _buildTestApp(router: router, repository: repository),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(tester.takeException(), isNull);

      await _disposeRouter(tester, router);
    });
  });
}

Widget _buildTestApp({
  required GoRouter router,
  required AuthenticationRepository repository,
}) {
  return ProviderScope(
    overrides: [authenticationRepositoryProvider.overrideWithValue(repository)],
    child: PortalApp(router: router),
  );
}

Future<void> _tapCompactDestination(WidgetTester tester, String label) async {
  final navigationBarFinder = find.byType(NavigationBar);

  expect(navigationBarFinder, findsOneWidget);

  final destinationFinder = find.descendant(
    of: navigationBarFinder,
    matching: find.text(label),
  );

  expect(destinationFinder, findsOneWidget);

  await tester.tap(destinationFinder);
  await tester.pumpAndSettle();
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

Future<void> _disposeRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(const SizedBox.shrink());

  await tester.pump();

  router.dispose();
}

final class _SignedInAuthenticationRepository
    implements AuthenticationRepository {
  static const PortalUser _user = PortalUser(
    id: 'test-user',
    displayName: 'Test Employee',
    email: 'test@example.invalid',
  );

  @override
  Future<PortalUser?> restoreSession() async {
    return _user;
  }

  @override
  Future<PortalUser> signIn() async {
    return _user;
  }

  @override
  Future<void> signOut() async {}
}
