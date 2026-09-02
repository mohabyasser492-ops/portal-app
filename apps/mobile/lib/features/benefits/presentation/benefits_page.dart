import 'package:flutter/material.dart';

import '../../amoc_services/presentation/service_ui.dart';
import '../../../app/theme/portal_design_system.dart';

class BenefitsPage extends StatelessWidget {
  const BenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المزايا والبدلات')),
      body: ListView(
        padding: const EdgeInsets.all(PortalSpacing.md),
        children: [
          const AmocPageHeader(
            title: 'المزايا والبدلات',
            subtitle: 'نظرة عامة على حقوقك ومزاياك الوظيفية.',
            icon: Icons.card_giftcard_outlined,
          ),
          const SizedBox(height: PortalSpacing.lg),
          AmocSurfaceCard(
            borderColor: PortalColors.brand300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: PortalColors.brand50,
                        borderRadius: BorderRadius.circular(PortalRadius.md),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_outlined,
                        color: PortalColors.brand700,
                      ),
                    ),
                    const SizedBox(width: PortalSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التأمين الطبي',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text('بوليصة الفئة أ • تغطية شاملة للأسرة'),
                        ],
                      ),
                    ),
                    AmocStatusPill(
                      label: 'ساري',
                      color: PortalColors.statusSuccess,
                    ),
                  ],
                ),
                const SizedBox(height: PortalSpacing.lg),
                const _BenefitNumber(
                  label: 'الحد الأقصى للتغطية',
                  value: '500,000 ج.م',
                ),
                const SizedBox(height: PortalSpacing.sm),
                const _BenefitNumber(
                  label: 'نسبة التحمل',
                  value: '10%',
                ),
                const SizedBox(height: PortalSpacing.md),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.badge_outlined),
                  label: const Text('عرض البطاقة الرقمية'),
                ),
              ],
            ),
          ),
          const SizedBox(height: PortalSpacing.xl),
          Text(
            'البدلات الحالية',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          Row(
            children: [
              const Expanded(
                child: AmocMetricCard(
                  label: 'بدل وجبة',
                  value: '1,200',
                  helper: 'ج.م/شهر',
                  icon: Icons.restaurant_outlined,
                ),
              ),
              const SizedBox(width: PortalSpacing.sm),
              const Expanded(
                child: AmocMetricCard(
                  label: 'بدل سكن',
                  value: '2,500',
                  helper: 'ج.م/شهر',
                  icon: Icons.home_work_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: PortalSpacing.sm),
          const AmocMetricCard(
            label: 'مكافأة العمل الميداني',
            value: '+15%',
            helper: 'مضافة لراتب الشهر الحالي',
            icon: Icons.engineering_outlined,
          ),
          const SizedBox(height: PortalSpacing.xl),
          Text(
            'مميزات الموظفين',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _BenefitListTile(
            title: 'خصم الأندية الصحية',
            subtitle: 'خصم 40% على اشتراكات محددة.',
            icon: Icons.fitness_center_outlined,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _BenefitListTile(
            title: 'اشتراكات الأندية',
            subtitle: 'عضوية مدعومة لنادي البترول.',
            icon: Icons.sports_outlined,
          ),
        ],
      ),
    );
  }
}

class _BenefitNumber extends StatelessWidget {
  const _BenefitNumber({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BenefitListTile extends StatelessWidget {
  const _BenefitListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AmocSurfaceCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PortalColors.surfaceTertiary,
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
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_left),
        ],
      ),
    );
  }
}
