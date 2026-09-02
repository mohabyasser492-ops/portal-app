import 'package:flutter/material.dart';

import '../../amoc_services/presentation/service_ui.dart';
import '../../../app/theme/portal_design_system.dart';

class PayrollPage extends StatelessWidget {
  const PayrollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسير الرواتب')),
      body: ListView(
        padding: const EdgeInsets.all(PortalSpacing.md),
        children: [
          AmocPageHeader(
            title: 'مسير الرواتب',
            subtitle: 'راجع صافي الراتب والاستحقاقات والاستقطاعات الشهرية.',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: PortalSpacing.lg),
          Container(
            padding: const EdgeInsets.all(PortalSpacing.lg),
            decoration: BoxDecoration(
              color: PortalColors.brand800,
              borderRadius: BorderRadius.circular(PortalRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صافي راتب الشهر الحالي',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PortalColors.neutral0.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: PortalSpacing.sm),
                Text(
                  '12,450 ج.م',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: PortalColors.neutral0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: PortalSpacing.xs),
                const Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: PortalIconSizes.sm,
                      color: PortalColors.neutral0,
                    ),
                    SizedBox(width: PortalSpacing.xs),
                    Text(
                      'أكتوبر 2026',
                      style: TextStyle(color: PortalColors.neutral0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: PortalSpacing.lg),
          Text(
            'تفاصيل الاستحقاقات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const AmocSurfaceCard(
            child: Column(
              children: [
                _PayrollRow(label: 'الراتب الأساسي', value: '8,000 ج.م'),
                _PayrollRow(label: 'بدل انتقال', value: '1,500 ج.م'),
                _PayrollRow(label: 'إضافي (Overtime)', value: '3,200 ج.م'),
                _PayrollRow(
                  label: 'إجمالي الاستحقاقات',
                  value: '12,700 ج.م',
                  strong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: PortalSpacing.lg),
          Text(
            'الاستقطاعات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const AmocSurfaceCard(
            child: Column(
              children: [
                _PayrollRow(label: 'تأمينات اجتماعية', value: '-150 ج.م'),
                _PayrollRow(label: 'ضرائب', value: '-100 ج.م'),
                _PayrollRow(
                  label: 'إجمالي الاستقطاعات',
                  value: '-250 ج.م',
                  strong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: PortalSpacing.xl),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سيتم تجهيز كشف الراتب بصيغة PDF.'),
                  ),
                );
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('تحميل كشف الراتب - PDF'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayrollRow extends StatelessWidget {
  const _PayrollRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: PortalSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
