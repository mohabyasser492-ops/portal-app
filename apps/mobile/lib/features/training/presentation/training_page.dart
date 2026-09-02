import 'package:flutter/material.dart';

import '../../amoc_services/presentation/service_ui.dart';
import '../../../app/theme/portal_design_system.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التدريب والتطوير')),
      body: ListView(
        padding: const EdgeInsets.all(PortalSpacing.md),
        children: [
          const AmocPageHeader(
            title: 'التدريب والتطوير',
            subtitle: 'عزز مهاراتك من خلال برامجنا التدريبية المعتمدة.',
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: PortalSpacing.lg),
          AmocSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'تقدم التدريب السنوي',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '28',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: PortalColors.brand800,
                      ),
                    ),
                    const Text(' ساعة'),
                  ],
                ),
                const SizedBox(height: PortalSpacing.sm),
                const Text('الهدف: 40 ساعة'),
                const SizedBox(height: PortalSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(PortalRadius.full),
                  child: const LinearProgressIndicator(
                    value: 0.70,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PortalSpacing.xl),
          Text(
            'الدورات القادمة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _CourseCard(
            date: '15 أكتوبر',
            title: 'بروتوكولات السلامة المتقدمة',
            description:
                'تحديث شامل لإجراءات السلامة الصناعية والتعامل مع الطوارئ.',
            duration: '8 ساعات',
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _CourseCard(
            date: '22 أكتوبر',
            title: 'الصيانة الفنية الوقائية',
            description:
                'استراتيجيات الصيانة الاستباقية للمعدات الدوارة والأنظمة المعقدة.',
            duration: '12 ساعة',
          ),
          const SizedBox(height: PortalSpacing.xl),
          Text(
            'الشهادات المكتملة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _CertificateCard(
            title: 'أساسيات الإسعافات الأولية',
            date: 'سبتمبر 2023',
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _CertificateCard(
            title: 'إدارة المخاطر التشغيلية',
            date: 'مايو 2023',
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.date,
    required this.title,
    required this.description,
    required this.duration,
  });

  final String date;
  final String title;
  final String description;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return AmocSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PortalColors.brand800,
                  PortalColors.brand500.withValues(alpha: 0.65),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(PortalRadius.lg),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.school_outlined,
                size: 48,
                color: PortalColors.neutral0.withValues(alpha: 0.90),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(PortalSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AmocStatusPill(
                      label: date,
                      color: PortalColors.brand700,
                    ),
                    const Spacer(),
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: PortalSpacing.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: PortalSpacing.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: PortalSpacing.md),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إرسال طلب التسجيل.')),
                      );
                    },
                    child: const Text('تسجيل'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.title,
    required this.date,
  });

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return AmocSurfaceCard(
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            color: PortalColors.brand700,
            size: PortalIconSizes.xl,
          ),
          const SizedBox(width: PortalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: PortalSpacing.xxs),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: 'تحميل الشهادة',
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
    );
  }
}
