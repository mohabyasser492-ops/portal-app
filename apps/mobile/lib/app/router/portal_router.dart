import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/navigation/portal_navigation_shell.dart';
import '../../features/home/presentation/home_placeholder_page.dart';
import '../../features/not_found/presentation/not_found_page.dart';
import '../../features/profile/presentation/profile_placeholder_page.dart';
import '../../features/requests/presentation/requests_placeholder_page.dart';
import '../../features/services/presentation/services_placeholder_page.dart';
import 'portal_route_names.dart';
import 'portal_route_paths.dart';

/// Creates the central Portal App router.
///
/// A fresh router and fresh navigator keys are created for each invocation.
/// This avoids navigation state leaking between widget tests.
GoRouter createPortalRouter({
  String initialLocation = PortalRoutePaths.home,
  Listenable? refreshListenable,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-root-navigator');

  final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-home-navigator');

  final servicesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-services-navigator');

  final requestsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-requests-navigator');

  final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'portal-profile-navigator');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    routes: [
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
          return const Scaffold(body: Center(child: Text('Design system preview')));
        },
      ),
    ],
    errorBuilder: (context, state) {
      return NotFoundPage(requestedLocation: state.uri.toString());
    },
  );
}
