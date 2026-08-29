import 'package:flutter/material.dart';

import '../../../app/theme/portal_design_system.dart';

/// The number of primary destinations displayed by the navigation shell.
const int portalNavigationDestinationCount = 4;

/// The viewport width at which the shell switches from bottom navigation
/// to a navigation rail.
const double portalNavigationRailBreakpoint = 720;

/// The primary application destinations.
///
/// The order of this enum must remain synchronized with the order of
/// destinations rendered by [PortalNavigationShell].
enum PortalNavigationDestination { home, services, requests, profile }

/// A responsive application shell for Portal App.
///
/// Compact viewports use a bottom [NavigationBar]. Wider viewports use a
/// [NavigationRail]. The shell receives its current destination and navigation
/// callback from the routing layer, which keeps this widget independent from
/// a specific router implementation.
class PortalNavigationShell extends StatelessWidget {
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

  /// The index of the currently selected destination.
  final int currentIndex;

  /// Called when the user selects a navigation destination.
  final ValueChanged<int> onDestinationSelected;

  /// The active route content.
  final Widget child;

  /// Whether the shell should display its shared application bar.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final useNavigationRail =
        MediaQuery.sizeOf(context).width >= portalNavigationRailBreakpoint;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Portal App')) : null,
      body: useNavigationRail ? _buildWideLayout() : child,
      bottomNavigationBar: useNavigationRail ? null : _buildNavigationBar(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        SafeArea(
          child: NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: _selectDestination,
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
      onDestinationSelected: _selectDestination,
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

  void _selectDestination(int index) {
    if (index == currentIndex) {
      return;
    }

    onDestinationSelected(index);
  }
}
