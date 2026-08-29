import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/portal_route_names.dart';
import '../../../app/theme/portal_design_system.dart';
import '../../../features/authentication/application/authentication_controller.dart';

/// Number of primary destinations displayed by the navigation shell.
const int portalNavigationDestinationCount = 4;

/// Screen width at which the navigation shell changes from bottom navigation
/// to a navigation rail.
const double portalNavigationRailBreakpoint = 720;

/// Primary destinations available in Portal App.
///
/// The order must remain synchronized with:
///
/// - GoRouter stateful branches
/// - NavigationBar destinations
/// - NavigationRail destinations
enum PortalNavigationDestination { home, services, requests, profile }

/// Responsive navigation shell used by the authenticated application.
///
/// Compact screens use a bottom [NavigationBar].
/// Wide screens use a [NavigationRail].
///
/// The application bar provides actions for:
///
/// - Opening the design-system preview
/// - Signing out of the authenticated session
class PortalNavigationShell extends ConsumerWidget {
  const PortalNavigationShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
    this.showAppBar = true,
    super.key,
  }) : assert(
         currentIndex >= 0 && currentIndex < portalNavigationDestinationCount,
         'currentIndex must reference a valid navigation destination.',
       );

  /// Index of the currently selected destination.
  final int currentIndex;

  /// Called when the user selects a different destination.
  final ValueChanged<int> onDestinationSelected;

  /// Active route content displayed inside the navigation shell.
  final Widget child;

  /// Whether the shared application bar is displayed.
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;

    final useNavigationRail = width >= portalNavigationRailBreakpoint;

    return Scaffold(
      appBar: showAppBar ? _buildAppBar(context: context, ref: ref) : null,
      body: useNavigationRail ? _buildWideLayout() : child,
      bottomNavigationBar: useNavigationRail ? null : _buildNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return AppBar(
      title: const Text('Portal App'),
      actions: [
        IconButton(
          tooltip: 'Open design system',
          onPressed: () {
            context.pushNamed(PortalRouteNames.designSystem);
          },
          icon: const Icon(Icons.palette_outlined),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: () {
            ref.read(authenticationControllerProvider.notifier).signOut();
          },
          icon: const Icon(Icons.logout_outlined),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        SafeArea(
          child: NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: _handleDestinationSelection,
            labelType: NavigationRailLabelType.all,
            groupAlignment: -1,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.apps_outlined),
                selectedIcon: Icon(Icons.apps),
                label: Text('Services'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description),
                label: Text('Requests'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
        ),
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: PortalColors.borderSubtle,
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: _handleDestinationSelection,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.apps_outlined),
          selectedIcon: Icon(Icons.apps),
          label: 'Services',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: 'Requests',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _handleDestinationSelection(int index) {
    if (index == currentIndex) {
      return;
    }

    if (index < 0 || index >= portalNavigationDestinationCount) {
      return;
    }

    onDestinationSelected(index);
  }
}
