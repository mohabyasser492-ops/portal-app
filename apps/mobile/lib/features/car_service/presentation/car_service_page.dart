import 'package:flutter/material.dart';

import '../../amoc_services/presentation/service_ui.dart';
import '../../../app/theme/portal_design_system.dart';

class CarServicePage extends StatefulWidget {
  const CarServicePage({super.key});

  @override
  State<CarServicePage> createState() => _CarServicePageState();
}

class _CarServicePageState extends State<CarServicePage> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب سيارة')),
      body: ListView(
        padding: const EdgeInsets.all(PortalSpacing.md),
        children: [
          const AmocPageHeader(
            title: 'طلب سيارة',
            subtitle: 'أنشئ طلب نقل للمواقع والمهام التشغيلية.',
            icon: Icons.directions_car_outlined,
          ),
          const SizedBox(height: PortalSpacing.lg),
          AmocSurfaceCard(
            borderColor: PortalColors.brand300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل الطلب الجديد',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: PortalSpacing.lg),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'الوجهة (الموقع)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          _date == null
                              ? 'التاريخ'
                              : '${_date!.day}/${_date!.month}/${_date!.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: PortalSpacing.sm),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'الوقت',
                          prefixIcon: Icon(Icons.schedule_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PortalSpacing.md),
                const TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'الغرض من الرحلة',
                    hintText: 'اكتب الغرض من الرحلة...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: PortalSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إرسال طلب السيارة بنجاح.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('إرسال الطلب'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PortalSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  'الطلبات الأخيرة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _CarHistory(
            location: 'موقع الحفر الشمالي',
            date: '12 أكتوبر 2023 • 08:00 صباحاً',
            status: 'مقبول',
            color: PortalColors.statusSuccess,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _CarHistory(
            location: 'مقر الإدارة الرئيسي',
            date: '15 أكتوبر 2023 • 14:30 مساءً',
            status: 'قيد المراجعة',
            color: PortalColors.statusWarning,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (date != null) setState(() => _date = date);
  }
}

class _CarHistory extends StatelessWidget {
  const _CarHistory({
    required this.location,
    required this.date,
    required this.status,
    required this.color,
  });

  final String location;
  final String date;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AmocSurfaceCard(
      child: Row(
        children: [
          const Icon(
            Icons.directions_car_outlined,
            color: PortalColors.brand700,
          ),
          const SizedBox(width: PortalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: PortalSpacing.xxs),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          AmocStatusPill(label: status, color: color),
        ],
      ),
    );
  }
}
