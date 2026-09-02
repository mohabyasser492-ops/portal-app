import 'package:flutter/material.dart';

import '../../amoc_services/presentation/service_ui.dart';
import '../../../app/theme/portal_design_system.dart';

class ShiftManagementPage extends StatefulWidget {
  const ShiftManagementPage({super.key});

  @override
  State<ShiftManagementPage> createState() => _ShiftManagementPageState();
}

class _ShiftManagementPageState extends State<ShiftManagementPage> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الورديات')),
      body: ListView(
        padding: const EdgeInsets.all(PortalSpacing.md),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'سجل المنشأة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('تصفية'),
              ),
            ],
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _AlertLog(
            time: '10:45 ص',
            title: 'تسرب ضغط - صمام أ-12',
            detail: 'تم اكتشاف انخفاض في الضغط في خط التبريد الرئيسي.',
            status: 'حرج',
            color: PortalColors.statusError,
          ),
          const _AlertLog(
            time: '09:15 ص',
            title: 'فحص دوري - مضخة 3',
            detail: 'جدولة الفحص الأسبوعي للمضخة رقم 3 حسب تعليمات الصيانة الوقائية.',
            status: 'قيد الانتظار',
            color: PortalColors.statusWarning,
          ),
          const _AlertLog(
            time: '08:00 ص',
            title: 'تسليم الوردية',
            detail: 'تم استلام الوردية الصباحية بنجاح. جميع الأنظمة تعمل ضمن المعدلات الطبيعية.',
            status: 'مكتمل',
            color: PortalColors.statusSuccess,
          ),
          const SizedBox(height: PortalSpacing.lg),
          AmocSurfaceCard(
            borderColor: PortalColors.brand500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوردية الصباحية - وحدة 4',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: PortalSpacing.xs),
                const Text('مشرف الوردية: أحمد محمود'),
                const SizedBox(height: PortalSpacing.xs),
                const Text('08:00 ص - 04:00 م'),
                const SizedBox(height: PortalSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _acknowledged = true),
                    child: Text(
                      _acknowledged ? 'تم تحديث الحالة' : 'تحديث الحالة',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PortalSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: AmocMetricCard(
                  label: 'الإنتاج الحالي',
                  value: '1,245',
                  helper: 'برميل/ساعة • +2.4%',
                  icon: Icons.oil_barrel_outlined,
                ),
              ),
              SizedBox(width: PortalSpacing.sm),
              Expanded(
                child: AmocMetricCard(
                  label: 'ضغط الشبكة',
                  value: '84',
                  helper: 'PSI • مستقر',
                  icon: Icons.speed_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _SafetyBanner(),
          const SizedBox(height: PortalSpacing.lg),
          const AmocSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فحص دوري - مضخة 3',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text('رقم السجل: #L-4920'),
                SizedBox(height: 8),
                Text('الموقع: الوحدة 4 - القطاع ج'),
                SizedBox(height: 8),
                Text('المُبلغ: فريق الصيانة الدورية'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertLog extends StatelessWidget {
  const _AlertLog({
    required this.time,
    required this.title,
    required this.detail,
    required this.status,
    required this.color,
  });

  final String time;
  final String title;
  final String detail;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: PortalSpacing.sm),
      padding: const EdgeInsets.all(PortalSpacing.md),
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.md),
        border: BorderDirectional(
          end: BorderSide(color: color, width: 3),
          top: const BorderSide(color: PortalColors.borderSubtle),
          bottom: const BorderSide(color: PortalColors.borderSubtle),
          start: const BorderSide(color: PortalColors.borderSubtle),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: PortalSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    AmocStatusPill(label: status, color: color),
                  ],
                ),
                const SizedBox(height: PortalSpacing.xs),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PortalSpacing.md),
      decoration: BoxDecoration(
        color: PortalColors.statusErrorSurface,
        borderRadius: BorderRadius.circular(PortalRadius.md),
        border: Border.all(color: PortalColors.statusError, width: 1.5),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: PortalColors.statusError,
          ),
          SizedBox(width: PortalSpacing.sm),
          Expanded(
            child: Text(
              'تنبيه نشط: راجع سجل المنشأة لتفاصيل التسرب.',
            ),
          ),
        ],
      ),
    );
  }
}
