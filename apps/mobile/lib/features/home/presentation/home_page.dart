import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_empty_state.dart';
import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_skeleton.dart';
import '../application/home_controller.dart';
import '../application/home_state.dart';
import '../application/home_status.dart';
import '../domain/home_dashboard.dart';
import 'widgets/home_recent_request_card.dart';
import 'widgets/home_announcement_card.dart';

/// Home dashboard displayed after successful authentication.
///
/// This page depends on the Home controller and contains no backend-specific
/// implementation details.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(homeControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return SafeArea(
      child: RefreshIndicator(onRefresh: _refresh, child: _buildContent(state)),
    );
  }

  Future<void> _refresh() {
    return ref.read(homeControllerProvider.notifier).loadDashboard();
  }

  Widget _buildContent(HomeState state) {
    return switch (state.status) {
      HomeStatus.initial => const _HomeLoadingView(),
      HomeStatus.loading => const _HomeLoadingView(),
      HomeStatus.success => _HomeDashboardView(dashboard: state.dashboard!),
      HomeStatus.empty => _HomeEmptyView(onRefresh: _retry),
      HomeStatus.failure => _HomeFailureView(
        message: state.errorMessage ?? 'Unable to load the dashboard.',
        onRetry: _retry,
      ),
    };
  }

  void _retry() {
    ref.read(homeControllerProvider.notifier).retry();
  }
}

/// Loading presentation displayed while dashboard data is requested.
class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('home-loading'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
      children: const [
        PortalSkeleton(width: 220, height: 28, animate: false),
        SizedBox(height: PortalSpacing.sm),
        PortalSkeleton(width: 280, height: 16, animate: false),
        SizedBox(height: PortalSpacing.xl),
        PortalSkeleton(width: double.infinity, height: 112, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalSkeleton(width: double.infinity, height: 112, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalSkeleton(width: double.infinity, height: 112, animate: false),
        SizedBox(height: PortalSpacing.xl),
        PortalSkeleton(width: 180, height: 24, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalListTileSkeleton(animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalListTileSkeleton(animate: false),
      ],
    );
  }
}

/// Populated Home dashboard presentation.
class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('home-dashboard'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
      children: [
        Text(
          'Welcome, ${dashboard.employeeDisplayName}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: PortalSpacing.sm),
        Text(
          'Here is an overview of your Portal activity.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
        ),
        const SizedBox(height: PortalSpacing.xl),
        _DashboardSummaryGrid(dashboard: dashboard),
        const SizedBox(height: PortalSpacing.xl),
        const _HomeSectionHeader(
          title: 'Recent requests',
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: PortalSpacing.md),
        if (dashboard.recentRequests.isEmpty)
          const _HomeSectionEmptyCard(
            message: 'No recent requests are available.',
          )
        else
          ...dashboard.recentRequests.map((request) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: PortalSpacing.md,
              ),
              child: HomeRecentRequestCard(request: request),
            );
          }),
        const SizedBox(height: PortalSpacing.lg),
        const _HomeSectionHeader(
          title: 'Announcements',
          icon: Icons.campaign_outlined,
        ),
        const SizedBox(height: PortalSpacing.md),
        if (dashboard.announcements.isEmpty)
          const _HomeSectionEmptyCard(
            message: 'No announcements are available.',
          )
        else
          ...dashboard.announcements.map((announcement) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: PortalSpacing.md,
              ),
              child: HomeAnnouncementCard(announcement: announcement),
            );
          }),
      ],
    );
  }
}

/// Responsive grid containing the Home dashboard summary cards.
///
/// Compact layouts use one column, medium layouts use two columns, and wide
/// layouts use three columns.
class _DashboardSummaryGrid extends StatelessWidget {
  const _DashboardSummaryGrid({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _columnCountForWidth(constraints.maxWidth);

        final totalSpacing = PortalSpacing.md * (columnCount - 1);

        final cardWidth = (constraints.maxWidth - totalSpacing) / columnCount;

        return Wrap(
          spacing: PortalSpacing.md,
          runSpacing: PortalSpacing.md,
          children: [
            SizedBox(
              width: cardWidth,
              child: _DashboardValueCard(
                label: 'Pending requests',
                value: dashboard.pendingRequestCount,
                icon: Icons.schedule_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _DashboardValueCard(
                label: 'Approved requests',
                value: dashboard.approvedRequestCount,
                icon: Icons.check_circle_outline,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _DashboardValueCard(
                label: 'Available services',
                value: dashboard.availableServiceCount,
                icon: Icons.apps_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  int _columnCountForWidth(double width) {
    if (width >= 900) {
      return 3;
    }

    if (width >= 600) {
      return 2;
    }

    return 1;
  }
}

/// Summary card displayed near the top of the dashboard.
class _DashboardValueCard extends StatelessWidget {
  const _DashboardValueCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: PortalColors.actionPrimary,
                  size: PortalIconSizes.lg,
                ),
                const SizedBox(width: PortalSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.toString(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: PortalColors.actionPrimary),
                      ),
                      const SizedBox(height: PortalSpacing.xs),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Heading used for a Home dashboard content section.
class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(
          child: Icon(
            icon,
            color: PortalColors.actionPrimary,
            size: PortalIconSizes.md,
          ),
        ),
        const SizedBox(width: PortalSpacing.sm),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}

/// Compact empty state displayed inside a populated dashboard section.
class _HomeSectionEmptyCard extends StatelessWidget {
  const _HomeSectionEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
        child: Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.inbox_outlined,
                color: PortalColors.textSecondary,
              ),
            ),
            const SizedBox(width: PortalSpacing.md),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PortalColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty dashboard presentation.
class _HomeEmptyView extends StatelessWidget {
  const _HomeEmptyView({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('home-empty'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
      children: [
        PortalEmptyState(
          title: 'No dashboard information',
          description:
              'Dashboard information will appear when it becomes available.',
          icon: Icons.dashboard_outlined,
          actionLabel: 'Refresh',
          onAction: onRefresh,
        ),
      ],
    );
  }
}

/// Dashboard failure presentation.
class _HomeFailureView extends StatelessWidget {
  const _HomeFailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('home-failure'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
      children: [
        PortalErrorState(
          title: 'Unable to load dashboard',
          description: message,
          retryLabel: 'Try again',
          onRetry: onRetry,
          semanticLabel: 'Unable to load dashboard. $message',
        ),
      ],
    );
  }
}
