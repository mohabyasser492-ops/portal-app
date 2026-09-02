import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/portal_route_paths.dart';
import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_empty_state.dart';
import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_skeleton.dart';
import '../application/home_controller.dart';
import '../application/home_status.dart';
import '../domain/home_dashboard.dart';
import 'widgets/home_announcement_card.dart';
import 'widgets/home_recent_request_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(homeControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).loadDashboard(),
        child: switch (state.status) {
          HomeStatus.initial || HomeStatus.loading => const _HomeLoadingView(),
          HomeStatus.success => _HomeDashboardView(dashboard: state.dashboard!),
          HomeStatus.empty => _HomeEmptyView(
            onRefresh: () => ref.read(homeControllerProvider.notifier).retry(),
          ),
          HomeStatus.failure => _HomeFailureView(
            message: state.errorMessage ?? 'تعذر تحميل الصفحة الرئيسية.',
            onRetry: () => ref.read(homeControllerProvider.notifier).retry(),
          ),
        },
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('home-loading'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(PortalSpacing.md),
      children: const [
        PortalSkeleton(width: 230, height: 28, animate: false),
        SizedBox(height: PortalSpacing.sm),
        PortalSkeleton(width: 250, height: 16, animate: false),
        SizedBox(height: PortalSpacing.lg),
        PortalSkeleton(width: double.infinity, height: 116, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalSkeleton(width: double.infinity, height: 110, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalSkeleton(width: double.infinity, height: 110, animate: false),
        SizedBox(height: PortalSpacing.lg),
        PortalListTileSkeleton(animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalListTileSkeleton(animate: false),
      ],
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey('home-dashboard'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            PortalSpacing.md,
            PortalSpacing.md,
            PortalSpacing.md,
            PortalSpacing.xl,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WelcomeHeader(name: dashboard.employeeDisplayName),
                const SizedBox(height: PortalSpacing.md),
                const _ShiftLocationCard(),
                const SizedBox(height: PortalSpacing.md),
                _StatsGrid(dashboard: dashboard),
                const SizedBox(height: PortalSpacing.xl),
                _SectionHeader(title: 'أخبار الشركة', actionLabel: 'عرض الكل', onPressed: () {}),
                const SizedBox(height: PortalSpacing.sm),
                const _AnnouncementHighlight(
                  title: 'New Safety Protocol',
                  summary: 'تحديثات هامة على إجراءات السلامة في الموقع.',
                  icon: Icons.warning_amber_outlined,
                ),
                const SizedBox(height: PortalSpacing.sm),
                if (dashboard.announcements.isNotEmpty)
                  HomeAnnouncementCard(announcement: dashboard.announcements.last),
                const SizedBox(height: PortalSpacing.xl),
                _SectionHeader(
                  title: 'آخر الطلبات',
                  actionLabel: 'عرض الكل',
                  onPressed: () => context.push(PortalRoutePaths.requests),
                ),
                const SizedBox(height: PortalSpacing.sm),
                if (dashboard.recentRequests.isEmpty)
                  const PortalEmptyState(
                    title: 'لا توجد طلبات حديثة',
                    description: 'ستظهر الطلبات الجديدة هنا.',
                    icon: Icons.inbox_outlined,
                  )
                else
                  ...dashboard.recentRequests
                      .take(3)
                      .map(
                        (request) => Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: PortalSpacing.sm),
                          child: HomeRecentRequestCard(request: request),
                        ),
                      ),
                const SizedBox(height: PortalSpacing.lg),
                _EmergencyCard(onPressed: () => context.push(PortalRoutePaths.fieldOperations)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أهلاً بك، $name', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: PortalSpacing.xs),
              Text(
                'بوابتك الذكية لخدمات الموظفين',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShiftLocationCard extends StatelessWidget {
  const _ShiftLocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PortalSpacing.lg),
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.lg),
        border: Border.all(color: PortalColors.borderSubtle),
        boxShadow: const [
          BoxShadow(color: PortalColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PortalColors.brand50,
              borderRadius: BorderRadius.circular(PortalRadius.md),
            ),
            child: const Icon(Icons.wb_sunny_outlined, color: PortalColors.brand700),
          ),
          const SizedBox(width: PortalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الوردية الصباحية', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: PortalSpacing.xxs),
                Text(
                  'موقع الإسكندرية • 08:00 ص - 04:00 م',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('22°C', style: Theme.of(context).textTheme.titleLarge),
              Text('سماء صافية', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatData(
        icon: Icons.pending_actions_outlined,
        label: 'الإجازات المعلقة',
        value: '${dashboard.pendingRequestCount}',
      ),
      _StatData(icon: Icons.logout_outlined, label: 'تصاريح الخروج', value: '3'),
      _StatData(
        icon: Icons.engineering_outlined,
        label: 'أوامر العمل المفتوحة',
        value: '${dashboard.approvedRequestCount}',
      ),
      const _StatData(
        icon: Icons.health_and_safety_outlined,
        label: 'ساعات السلامة',
        value: '1,420',
        emphasize: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - PortalSpacing.sm) / 2;
        return Wrap(
          spacing: PortalSpacing.sm,
          runSpacing: PortalSpacing.sm,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _StatCard(data: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatData {
  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(PortalSpacing.md),
      decoration: BoxDecoration(
        color: data.emphasize ? PortalColors.surfaceTertiary : PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.lg),
        border: Border.all(
          color: data.emphasize ? PortalColors.borderDefault : PortalColors.borderSubtle,
        ),
        boxShadow: const [
          BoxShadow(color: PortalColors.shadow, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(data.icon, color: PortalColors.brand700),
          const SizedBox(width: PortalSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: PortalSpacing.xs),
                Text(
                  data.value,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: PortalColors.brand800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel, required this.onPressed});

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

class _AnnouncementHighlight extends StatelessWidget {
  const _AnnouncementHighlight({required this.title, required this.summary, required this.icon});

  final String title;
  final String summary;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PortalSpacing.md),
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.lg),
        border: Border.all(color: PortalColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PortalColors.statusWarningSurface,
              borderRadius: BorderRadius.circular(PortalRadius.md),
            ),
            child: Icon(icon, color: PortalColors.statusWarning),
          ),
          const SizedBox(width: PortalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: PortalSpacing.xxs),
                Text(summary, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(PortalRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(PortalSpacing.md),
        decoration: BoxDecoration(
          color: PortalColors.statusErrorSurface,
          borderRadius: BorderRadius.circular(PortalRadius.lg),
          border: Border.all(color: PortalColors.statusError, width: 2),
        ),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: PortalColors.statusError, shape: BoxShape.circle),
              child: Padding(
                padding: EdgeInsets.all(PortalSpacing.sm),
                child: Icon(Icons.warning_amber_rounded, color: PortalColors.neutral0),
              ),
            ),
            const SizedBox(width: PortalSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإبلاغ عن حادث / وشيك الوقوع',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: PortalColors.statusError),
                  ),
                  const SizedBox(height: PortalSpacing.xxs),
                  Text('اضغط هنا للتبليغ الفوري', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: PortalColors.statusError),
          ],
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(PortalSpacing.lg),
      children: [
        PortalEmptyState(
          title: 'لا توجد بيانات',
          description: 'لم تصل بيانات لوحة التحكم بعد.',
          icon: Icons.dashboard_outlined,
          actionLabel: 'تحديث',
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(PortalSpacing.lg),
      children: [
        PortalErrorState(
          title: 'تعذر تحميل الصفحة الرئيسية',
          description: message,
          retryLabel: 'حاول مرة أخرى',
          onRetry: onRetry,
          semanticLabel: 'تعذر تحميل الصفحة الرئيسية. $message',
        ),
      ],
    );
  }
}
