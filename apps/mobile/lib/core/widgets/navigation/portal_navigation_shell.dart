import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../features/authentication/application/authentication_controller.dart';

const int portalNavigationDestinationCount = 4;
const double portalNavigationRailBreakpoint = 720;

enum PortalNavigationDestination { home, quickAccess, activity, profile }

class PortalNavigationShell extends ConsumerWidget {
  const PortalNavigationShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
    this.showAppBar = true,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= portalNavigationRailBreakpoint;

    return Scaffold(
      appBar: showAppBar ? _buildAppBar(context, ref) : null,
      body: useRail ? _buildWideLayout() : child,
      bottomNavigationBar: useRail ? null : _buildNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      titleSpacing: PortalSpacing.md,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PortalColors.brand800,
              borderRadius: BorderRadius.circular(PortalRadius.sm),
            ),
            alignment: Alignment.center,
            child: const Text(
              'A',
              style: TextStyle(
                color: PortalColors.neutral0,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: PortalSpacing.sm),
          Text('AMOC Portal', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => _showNotifications(context),
          icon: const Icon(Icons.notifications_none_outlined),
        ),
        PopupMenuButton<String>(
          tooltip: 'Account',
          onSelected: (value) {
            if (value == 'profile') {
              context.go('/profile');
            } else if (value == 'signout') {
              ref.read(authenticationControllerProvider.notifier).signOut();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'profile', child: Text('الملف الشخصي')),
            PopupMenuItem(value: 'signout', child: Text('تسجيل الخروج')),
          ],
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: PortalSpacing.md),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PortalColors.brand50,
                shape: BoxShape.circle,
                border: Border.all(color: PortalColors.borderSubtle),
              ),
              alignment: Alignment.center,
              child: const Text(
                'FA',
                style: TextStyle(
                  color: PortalColors.brand800,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
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
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('الرئيسية'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bolt_outlined),
                selectedIcon: Icon(Icons.bolt),
                label: Text('وصول سريع'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('النشاط'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('الملف الشخصي'),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: PortalColors.borderSubtle),
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
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.bolt_outlined),
          selectedIcon: Icon(Icons.bolt),
          label: 'وصول سريع',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'النشاط',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'الملف الشخصي',
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

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: PortalColors.surfacePrimary,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(PortalSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الإشعارات', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: PortalSpacing.md),
                _NotificationRow(
                  icon: Icons.warning_amber_outlined,
                  title: 'تنبيه سلامة جديد',
                  subtitle: 'يرجى مراجعة تحديثات إجراءات السلامة.',
                  color: PortalColors.statusError,
                ),
                const SizedBox(height: PortalSpacing.sm),
                _NotificationRow(
                  icon: Icons.schedule_outlined,
                  title: 'طلب إضافي قيد المراجعة',
                  subtitle: 'طلبك الأخير تم استلامه بنجاح.',
                  color: PortalColors.statusWarning,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(PortalRadius.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PortalSpacing.sm),
          child: Icon(icon, color: color),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
