import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_empty_state.dart';
import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_skeleton.dart';
import '../application/home_controller.dart';
import '../application/home_state.dart';
import '../application/home_status.dart';
import '../domain/announcement_summary.dart';
import '../domain/home_dashboard.dart';
import '../domain/request_summary.dart';

/// Home dashboard displayed after successful authentication.
///
/// The page depends on [HomeController] and contains no backend-specific logic.
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
      child: RefreshIndicator(
        onRefresh: () {
          return ref.read(homeControllerProvider.notifier).loadDashboard();
        },
        child: _buildContent(state),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    return switch (state.status) {
      HomeStatus.initial => const _HomeLoadingView(),
      HomeStatus.loading => const _HomeLoadingView(),
      HomeStatus.success => _HomeDashboardView(dashboard: state.dashboard!),
      HomeStatus.empty => _HomeEmptyView(
        onRefresh: () {
          ref.read(homeControllerProvider.notifier).retry();
        },
      ),
      HomeStatus.failure => _HomeFailureView(
        message: state.errorMessage ?? 'Unable to load the dashboard.',
        onRetry: () {
          ref.read(homeControllerProvider.notifier).retry();
        },
      ),
    };
  }
}

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
        _SummaryLoadingGrid(),
        SizedBox(height: PortalSpacing.xl),
        PortalSkeleton(width: 160, height: 22, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalListTileSkeleton(animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalListTileSkeleton(animate: false),
        SizedBox(height: PortalSpacing.xl),
        PortalSkeleton(width: 150, height: 22, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalTextSkeleton(width: 300, lines: 3, animate: false),
      ],
    );
  }
}

class _SummaryLoadingGrid extends StatelessWidget {
  const _SummaryLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 1;
        final spacing = PortalSpacing.md * (columns - 1);
        final itemWidth = (constraints.maxWidth - spacing) / columns;

        return Wrap(
          spacing: PortalSpacing.md,
          runSpacing: PortalSpacing.md,
          children: List<Widget>.generate(3, (index) {
            return SizedBox(
              width: itemWidth,
              child: const PortalSkeleton(
                width: double.infinity,
                height: 112,
                animate: false,
              ),
            );
          }),
        );
      },
    );
  }
}

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
        _DashboardSectionHeader(
          title: 'Recent requests',
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: PortalSpacing.md),
        if (dashboard.recentRequests.isEmpty)
          const _SectionEmptyCard(message: 'No recent requests are available.')
        else
          ...dashboard.recentRequests.map((request) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: PortalSpacing.md,
              ),
              child: _RecentRequestCard(request: request),
            );
          }),
        const SizedBox(height: PortalSpacing.lg),
        _DashboardSectionHeader(
          title: 'Announcements',
          icon: Icons.campaign_outlined,
        ),
        const SizedBox(height: PortalSpacing.md),
        if (dashboard.announcements.isEmpty)
          const _SectionEmptyCard(message: 'No announcements are available.')
        else
          ...dashboard.announcements.map((announcement) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: PortalSpacing.md,
              ),
              child: _AnnouncementCard(announcement: announcement),
            );
          }),
      ],
    );
  }
}

class _DashboardSummaryGrid extends StatelessWidget {
  const _DashboardSummaryGrid({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        final spacing = PortalSpacing.md * (columns - 1);

        final itemWidth = (constraints.maxWidth - spacing) / columns;

        return Wrap(
          spacing: PortalSpacing.md,
          runSpacing: PortalSpacing.md,
          children: [
            SizedBox(
              width: itemWidth,
              child: _SummaryCard(
                label: 'Pending requests',
                value: dashboard.pendingRequestCount,
                icon: Icons.schedule_outlined,
                color: PortalColors.statusWarning,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryCard(
                label: 'Approved requests',
                value: dashboard.approvedRequestCount,
                icon: Icons.check_circle_outline,
                color: PortalColors.statusSuccess,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryCard(
                label: 'Available services',
                value: dashboard.availableServiceCount,
                icon: Icons.apps_outlined,
                color: PortalColors.actionPrimary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(icon, color: color, size: PortalIconSizes.lg),
              ),
              const SizedBox(width: PortalSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: color),
                    ),
                    const SizedBox(height: PortalSpacing.xs),
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(child: Icon(icon, color: PortalColors.actionPrimary)),
        const SizedBox(width: PortalSpacing.sm),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}

class _RecentRequestCard extends StatelessWidget {
  const _RecentRequestCard({required this.request});

  final RequestSummary request;

  @override
  Widget build(BuildContext context) {
    final statusPresentation = _RequestStatusPresentation.fromStatus(
      request.status,
    );

    return Semantics(
      container: true,
      label:
          '${request.title}. Reference ${request.referenceNumber}. '
          'Status ${statusPresentation.label}.',
      child: Card(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  statusPresentation.icon,
                  color: statusPresentation.color,
                ),
              ),
              const SizedBox(width: PortalSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: PortalSpacing.xs),
                    Text(
                      request.referenceNumber,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PortalColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: PortalSpacing.sm),
                    _RequestStatusLabel(presentation: statusPresentation),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestStatusLabel extends StatelessWidget {
  const _RequestStatusLabel({required this.presentation});

  final _RequestStatusPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PortalRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.sm,
          vertical: PortalSpacing.xs,
        ),
        child: Text(
          presentation.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: presentation.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RequestStatusPresentation {
  const _RequestStatusPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  factory _RequestStatusPresentation.fromStatus(RequestSummaryStatus status) {
    return switch (status) {
      RequestSummaryStatus.draft => const _RequestStatusPresentation(
        label: 'Draft',
        icon: Icons.edit_note_outlined,
        color: PortalColors.textSecondary,
      ),
      RequestSummaryStatus.pending => const _RequestStatusPresentation(
        label: 'Pending',
        icon: Icons.schedule_outlined,
        color: PortalColors.statusWarning,
      ),
      RequestSummaryStatus.approved => const _RequestStatusPresentation(
        label: 'Approved',
        icon: Icons.check_circle_outline,
        color: PortalColors.statusSuccess,
      ),
      RequestSummaryStatus.rejected => const _RequestStatusPresentation(
        label: 'Rejected',
        icon: Icons.cancel_outlined,
        color: PortalColors.statusError,
      ),
    };
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});

  final AnnouncementSummary announcement;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: announcement.isPinned
          ? 'Pinned announcement. ${announcement.title}. '
                '${announcement.summary}'
          : '${announcement.title}. ${announcement.summary}',
      child: Card(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (announcement.isPinned) ...[
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.push_pin_outlined,
                        color: PortalColors.actionPrimary,
                      ),
                    ),
                    const SizedBox(width: PortalSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PortalSpacing.sm),
              Text(
                announcement.summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: PortalSpacing.sm),
              Text(
                _formatDate(announcement.publishedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PortalColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final localValue = value.toLocal();

    final month = localValue.month.toString().padLeft(2, '0');
    final day = localValue.day.toString().padLeft(2, '0');

    return '${localValue.year}-$month-$day';
  }
}

class _SectionEmptyCard extends StatelessWidget {
  const _SectionEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
        ),
      ),
    );
  }
}

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
