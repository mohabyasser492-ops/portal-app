import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/portal_route_paths.dart';
import '../../../app/theme/portal_design_system.dart';

class QuickAccessPage extends StatelessWidget {
  const QuickAccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(
          PortalSpacing.md,
          PortalSpacing.md,
          PortalSpacing.md,
          PortalSpacing.xl,
        ),
        children: [
          Text(
            'وصول سريع',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: PortalSpacing.xs),
          Text(
            'الوصول إلى أهم الخدمات والطلبات اليومية.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PortalColors.textSecondary,
            ),
          ),
          const SizedBox(height: PortalSpacing.lg),
          const _EmergencyActionCard(),
          const SizedBox(height: PortalSpacing.xl),
          Text(
            'الخدمات السريعة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          Wrap(
            spacing: PortalSpacing.sm,
            runSpacing: PortalSpacing.sm,
            children: const [
              _CompactAction(
                title: 'خدمة السيارات',
                icon: Icons.directions_car_outlined,
                route: PortalRoutePaths.carService,
              ),
              _CompactAction(
                title: 'العمل الإضافي',
                icon: Icons.schedule_outlined,
                route: PortalRoutePaths.overtime,
              ),
              _CompactAction(
                title: 'بدل الوجبات',
                icon: Icons.restaurant_outlined,
                route: PortalRoutePaths.benefits,
              ),
            ],
          ),
          const SizedBox(height: PortalSpacing.xl),
          Text(
            'خدمات الموارد البشرية',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _ServiceTile(
            title: 'مسير الرواتب',
            subtitle: 'عرض قسائم الراتب وتفاصيل الاستحقاقات والاستقطاعات.',
            icon: Icons.payments_outlined,
            route: PortalRoutePaths.payroll,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _ServiceTile(
            title: 'التدريب والتطوير',
            subtitle: 'استعراض الدورات القادمة والشهادات المكتملة.',
            icon: Icons.school_outlined,
            route: PortalRoutePaths.training,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _ServiceTile(
            title: 'المزايا والبدلات',
            subtitle: 'استعراض بيانات التأمين الطبي والبدلات والمزايا.',
            icon: Icons.card_giftcard_outlined,
            route: PortalRoutePaths.benefits,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _ServiceTile(
            title: 'إدارة الورديات',
            subtitle: 'متابعة الوردية الحالية والتنبيهات التشغيلية.',
            icon: Icons.engineering_outlined,
            route: PortalRoutePaths.shiftManagement,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _ServiceTile(
            title: 'عمليات الموقع',
            subtitle: 'مؤشرات السلامة والتنبيهات والإجراءات الميدانية.',
            icon: Icons.health_and_safety_outlined,
            route: PortalRoutePaths.fieldOperations,
          ),
          const SizedBox(height: PortalSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => context.push(PortalRoutePaths.serviceCatalog),
            icon: const Icon(Icons.apps_outlined),
            label: const Text('عرض كل الخدمات'),
          ),
        ],
      ),
    );
  }
}

class _EmergencyActionCard extends StatelessWidget {
  const _EmergencyActionCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(PortalRoutePaths.fieldOperations),
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
            const CircleAvatar(
              radius: 22,
              backgroundColor: PortalColors.statusError,
              child: Icon(
                Icons.warning_amber_rounded,
                color: PortalColors.neutral0,
              ),
            ),
            const SizedBox(width: PortalSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإبلاغ عن حادث / وشيك الوقوع',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PortalColors.statusError,
                    ),
                  ),
                  const SizedBox(height: PortalSpacing.xxs),
                  Text(
                    'اضغط هنا للتبليغ الفوري',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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

class _CompactAction extends StatelessWidget {
  const _CompactAction({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(PortalRadius.md),
      child: Container(
        width: (MediaQuery.sizeOf(context).width - 40) / 3,
        constraints: const BoxConstraints(minWidth: 100),
        padding: const EdgeInsets.all(PortalSpacing.md),
        decoration: BoxDecoration(
          color: PortalColors.surfacePrimary,
          borderRadius: BorderRadius.circular(PortalRadius.md),
          border: Border.all(color: PortalColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, color: PortalColors.brand700),
            const SizedBox(height: PortalSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(PortalRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(PortalSpacing.md),
        decoration: BoxDecoration(
          color: PortalColors.surfacePrimary,
          borderRadius: BorderRadius.circular(PortalRadius.lg),
          border: Border.all(color: PortalColors.borderSubtle),
          boxShadow: const [
            BoxShadow(
              color: PortalColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
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
              child: Icon(icon, color: PortalColors.brand700),
            ),
            const SizedBox(width: PortalSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: PortalSpacing.xxs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: PortalColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
