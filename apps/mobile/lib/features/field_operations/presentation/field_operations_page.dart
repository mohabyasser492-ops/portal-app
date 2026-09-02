import 'package:flutter/material.dart';

import '../../amoc_services/presentation/service_ui.dart';
import '../../../app/theme/portal_design_system.dart';

class FieldOperationsPage extends StatefulWidget {
  const FieldOperationsPage({super.key});

  @override
  State<FieldOperationsPage> createState() => _FieldOperationsPageState();
}

class _FieldOperationsPageState extends State<FieldOperationsPage> {
  final _descriptionController = TextEditingController();
  String _severity = 'متوسط';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عمليات الموقع')),
      body: ListView(
        padding: const EdgeInsets.all(PortalSpacing.md),
        children: [
          const AmocPageHeader(
            title: 'عمليات الموقع والسلامة',
            subtitle: 'مؤشرات السلامة والتنبيهات والتبليغ السريع.',
            icon: Icons.health_and_safety_outlined,
          ),
          const SizedBox(height: PortalSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: AmocMetricCard(
                  label: 'ساعات السلامة',
                  value: '1,420',
                  helper: 'منذ آخر حادث مسجل',
                  icon: Icons.health_and_safety_outlined,
                ),
              ),
              SizedBox(width: PortalSpacing.sm),
              Expanded(
                child: AmocMetricCard(
                  label: 'حالة الشبكة',
                  value: 'مستقرة',
                  helper: 'آخر تحديث منذ 4 دقائق',
                  icon: Icons.monitor_heart_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: PortalSpacing.lg),
          Container(
            padding: const EdgeInsets.all(PortalSpacing.md),
            decoration: BoxDecoration(
              color: PortalColors.statusErrorSurface,
              borderRadius: BorderRadius.circular(PortalRadius.lg),
              border: Border.all(
                color: PortalColors.statusError,
                width: 2,
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: PortalColors.statusError,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: PortalColors.neutral0,
                  ),
                ),
                SizedBox(width: PortalSpacing.md),
                Expanded(
                  child: Text(
                    'استخدم نموذج التبليغ التالي للإبلاغ عن حادث أو وشيك وقوعه.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PortalSpacing.lg),
          Text(
            'تبليغ جديد',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          AmocSurfaceCard(
            borderColor: PortalColors.statusError.withValues(alpha: 0.45),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _severity,
                  decoration: const InputDecoration(
                    labelText: 'درجة الخطورة',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'منخفض', child: Text('منخفض')),
                    DropdownMenuItem(value: 'متوسط', child: Text('متوسط')),
                    DropdownMenuItem(value: 'حرج', child: Text('حرج')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _severity = value);
                  },
                ),
                const SizedBox(height: PortalSpacing.md),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل البلاغ',
                    hintText: 'صف ما حدث وما الإجراء المطلوب...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: PortalSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: PortalColors.statusError,
                    ),
                    onPressed: _submit,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('إرسال البلاغ الفوري'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب تفاصيل البلاغ أولاً.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال البلاغ إلى فريق السلامة.')),
    );
  }
}
