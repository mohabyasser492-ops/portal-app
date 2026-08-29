import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/navigation/portal_navigation_shell.dart';
import '../../features/authentication/presentation/authentication_loading_page.dart';
import '../../features/authentication/presentation/sign_in_route_page.dart';
import '../../features/design_system/presentation/design_system_preview_page.dart';
import '../../features/home/presentation/home_placeholder_page.dart';
import '../../features/not_found/presentation/not_found_page.dart';
import '../../features/profile/presentation/profile_placeholder_page.dart';
import '../../features/requests/presentation/requests_placeholder_page.dart';
import '../../features/services/presentation/services_placeholder_page.dart';
import 'authentication_redirect_guard.dart';
import 'authentication_redirect_store.dart';
import 'authentication_router_refresh_notifier.dart';
import 'portal_route_names.dart';
import 'portal_route_paths.dart';

/// Creates the central Portal App router.
///
/// Each invocation creates fresh navigator keys, preventing navigation state
/// from leaking between application instances and widget tests.
GoRouter createPortalRouter({
  String initialLocation = PortalRoutePaths.home,
  required AuthenticationRouterRefreshNotifier refreshNotifier,
  AuthenticationRedirectStore? redirectStore,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-root-navigator');

  final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-home-navigator');

  final servicesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-services-navigator');

  final requestsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-requests-navigator');

  final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-profile-navigator');

  final effectiveRedirectStore = redirectStore ?? AuthenticationRedirectStore();

  final redirectGuard = AuthenticationRedirectGuard(redirectStore: effectiveRedirectStore);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      return redirectGuard.redirect(
        authenticationState: refreshNotifier.authenticationState,
        currentLocation: state.uri.toString(),
      );
    },
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.authenticationLoading,
        name: PortalRouteNames.authenticationLoading,
        builder: (context, state) {
          return const AuthenticationLoadingPage();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.signIn,
        name: PortalRouteNames.signIn,
        builder: (context, state) {
          return const SignInRoutePage();
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PortalNavigationShell(
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: [
              GoRoute(
                path: PortalRoutePaths.home,
                name: PortalRouteNames.home,
                builder: (context, state) {
                  return const HomePlaceholderPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: servicesNavigatorKey,
            routes: [
              GoRoute(
                path: PortalRoutePaths.services,
                name: PortalRouteNames.services,
                builder: (context, state) {
                  return const ServicesPlaceholderPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: requestsNavigatorKey,
            routes: [
              GoRoute(
                path: PortalRoutePaths.requests,
                name: PortalRouteNames.requests,
                builder: (context, state) {
                  return const RequestsPlaceholderPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: [
              GoRoute(
                path: PortalRoutePaths.profile,
                name: PortalRouteNames.profile,
                builder: (context, state) {
                  return const ProfilePlaceholderPage();
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.designSystem,
        name: PortalRouteNames.designSystem,
        builder: (context, state) {
          return const DesignSystemPreviewPage();
        },
      ),
    ],
    errorBuilder: (context, state) {
      return NotFoundPage(requestedLocation: state.uri.toString());
    },
  );
}
