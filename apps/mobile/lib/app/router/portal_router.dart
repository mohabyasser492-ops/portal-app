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

/// Root navigator key used for pages displayed above the navigation shell.
final GlobalKey<NavigatorState> portalRootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'portal-root-navigator');

/// Navigator key for the Home branch.
final GlobalKey<NavigatorState> portalHomeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'portal-home-navigator');

/// Navigator key for the Services branch.
final GlobalKey<NavigatorState> portalServicesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'portal-services-navigator');

/// Navigator key for the Requests branch.
final GlobalKey<NavigatorState> portalRequestsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'portal-requests-navigator');

/// Navigator key for the Profile branch.
final GlobalKey<NavigatorState> portalProfileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'portal-profile-navigator');

/// Creates the central Portal App router.
///
/// A new router can be created for each test, preventing navigation state from
/// leaking between test cases.
GoRouter createPortalRouter({String initialLocation = PortalRoutePaths.home}) {
  return GoRouter(
    navigatorKey: portalRootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PortalNavigationShell(
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(index);
            },
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: portalHomeNavigatorKey,
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
            navigatorKey: portalServicesNavigatorKey,
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
            navigatorKey: portalRequestsNavigatorKey,
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
            navigatorKey: portalProfileNavigatorKey,
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
    ],
    errorBuilder: (context, state) {
      return NotFoundPage(requestedLocation: state.uri.toString());
    },
  );
}
