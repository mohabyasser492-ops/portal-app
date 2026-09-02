import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/navigation/portal_navigation_shell.dart';
import '../../features/quick_access/presentation/quick_access_page.dart';
import '../../features/authentication/presentation/authentication_loading_page.dart';
import '../../features/authentication/presentation/sign_in_route_page.dart';
import '../../features/benefits/presentation/benefits_page.dart';
import '../../features/design_system/presentation/design_system_preview_page.dart';
import '../../features/field_operations/presentation/field_operations_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/not_found/presentation/not_found_page.dart';
import '../../features/overtime/presentation/overtime_page.dart';
import '../../features/payroll/presentation/payroll_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/requests/presentation/requests_page.dart';
import '../../features/requests/presentation/request_create_page.dart';
import '../../features/requests/presentation/request_details_page.dart';
import '../../features/services/presentation/services_page.dart';
import '../../features/car_service/presentation/car_service_page.dart';
import '../../features/shift_management/presentation/shift_management_page.dart';
import '../../features/training/presentation/training_page.dart';
import 'authentication_redirect_guard.dart';
import 'authentication_redirect_store.dart';
import 'authentication_router_refresh_notifier.dart';
import 'portal_route_names.dart';
import 'portal_route_paths.dart';

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
        builder: (_, _) => const AuthenticationLoadingPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.signIn,
        name: PortalRouteNames.signIn,
        builder: (_, _) => const SignInRoutePage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.quickAccess,
        redirect: (_, _) => PortalRoutePaths.services,
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.activity,
        redirect: (_, _) => PortalRoutePaths.requests,
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.serviceCatalog,
        name: PortalRouteNames.serviceCatalog,
        builder: (_, _) => const ServicesPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.shiftManagement,
        name: PortalRouteNames.shiftManagement,
        builder: (_, _) => const ShiftManagementPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.overtime,
        name: PortalRouteNames.overtime,
        builder: (_, _) => const OvertimePage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.carService,
        name: PortalRouteNames.carService,
        builder: (_, _) => const CarServicePage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.payroll,
        name: PortalRouteNames.payroll,
        builder: (_, _) => const PayrollPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.training,
        name: PortalRouteNames.training,
        builder: (_, _) => const TrainingPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.benefits,
        name: PortalRouteNames.benefits,
        builder: (_, _) => const BenefitsPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.fieldOperations,
        name: PortalRouteNames.fieldOperations,
        builder: (_, _) => const FieldOperationsPage(),
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
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: servicesNavigatorKey,
            routes: [
              GoRoute(
                path: PortalRoutePaths.services,
                name: PortalRouteNames.services,
                builder: (_, _) => const QuickAccessPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: requestsNavigatorKey,
            routes: [
              GoRoute(
                path: PortalRoutePaths.requests,
                name: PortalRouteNames.requests,
                builder: (_, _) => const RequestsPage(),
                routes: [
                  GoRoute(path: 'create', builder: (_, _) => const RequestCreatePage()),
                  GoRoute(
                    path: ':requestId',
                    builder: (context, state) =>
                        RequestDetailsPage(requestId: state.pathParameters['requestId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileNavigatorKey,
            routes: [
              GoRoute(
                path: PortalRoutePaths.profile,
                name: PortalRouteNames.profile,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: PortalRoutePaths.designSystem,
        name: PortalRouteNames.designSystem,
        builder: (_, _) => const DesignSystemPreviewPage(),
      ),
    ],
    errorBuilder: (context, state) {
      return NotFoundPage(requestedLocation: state.uri.toString());
    },
  );
}
