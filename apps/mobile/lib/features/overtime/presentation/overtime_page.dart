import 'package:flutter/material.dart';

import '../../amoc_services/presentation/service_ui.dart';
import '../../../app/theme/portal_design_system.dart';

class OvertimePage extends StatefulWidget {
  const OvertimePage({super.key});

  @override
  State<OvertimePage> createState() => _OvertimePageState();
}

class _OvertimePageState extends State<OvertimePage> {
  final _hoursController = TextEditingController();
  final _reasonController = TextEditingController();
  String _project = 'اختر المشروع أو الوحدة...';
  DateTime? _date;

  @override
  void dispose() {
    _hoursController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب عمل إضافي')),
      body: ListView(
        padding: const EdgeInsets.all(PortalSpacing.md),
        children: [
          const AmocPageHeader(
            title: 'طلب عمل إضافي',
            subtitle: 'تسجيل وتتبع ساعات العمل الإضافية الخاصة بك.',
            icon: Icons.more_time_outlined,
          ),
          const SizedBox(height: PortalSpacing.lg),
          const AmocMetricCard(
            label: 'ملخص شهر أكتوبر',
            value: '12.5 ساعة',
            helper: 'إجمالي الساعات المسجلة',
            icon: Icons.schedule_outlined,
          ),
          const SizedBox(height: PortalSpacing.lg),
          Text(
            'سجل الطلبات السابقة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          const _OvertimeHistoryRow(
            title: 'مشروع التوسعة B',
            status: 'معتمد',
            hours: '4.0 ساعات',
            date: '15 أكتوبر 2023',
            statusColor: PortalColors.statusSuccess,
          ),
          const _OvertimeHistoryRow(
            title: 'صيانة الوحدة 4',
            status: 'قيد الانتظار',
            hours: '3.5 ساعات',
            date: '22 أكتوبر 2023',
            statusColor: PortalColors.statusWarning,
          ),
          const _OvertimeHistoryRow(
            title: 'مراجعة تقارير السلامة',
            status: 'معتمد',
            hours: '5.0 ساعات',
            date: '05 أكتوبر 2023',
            statusColor: PortalColors.statusSuccess,
          ),
          const SizedBox(height: PortalSpacing.xl),
          Text(
            'تسجيل ساعات جديدة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: PortalSpacing.sm),
          AmocSurfaceCard(
            child: Column(
              children: [
                _FieldLabel(
                  label: 'تاريخ العمل الإضافي',
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _date == null
                          ? 'اختر التاريخ'
                          : '${_date!.day}/${_date!.month}/${_date!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                TextField(
                  controller: _hoursController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'عدد الساعات',
                    hintText: 'مثال: 2.5',
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _project,
                  decoration: const InputDecoration(
                    labelText: 'المشروع / كود الوحدة',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'اختر المشروع أو الوحدة...',
                      child: Text('اختر المشروع أو الوحدة...'),
                    ),
                    DropdownMenuItem(
                      value: 'الوحدة 1 - التكرير',
                      child: Text('الوحدة 1 - التكرير'),
                    ),
                    DropdownMenuItem(
                      value: 'الوحدة 2 - التقطير',
                      child: Text('الوحدة 2 - التقطير'),
                    ),
                    DropdownMenuItem(
                      value: 'مشروع الصيانة الدورية A',
                      child: Text('مشروع الصيانة الدورية A'),
                    ),
                    DropdownMenuItem(
                      value: 'مشروع التوسعة B',
                      child: Text('مشروع التوسعة B'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _project = value);
                  },
                ),
                const SizedBox(height: PortalSpacing.md),
                TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'سبب العمل الإضافي التفصيلي',
                    hintText: 'اكتب سبب العمل الإضافي...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: PortalSpacing.lg),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('تقديم الطلب'),
                  ),
                ),
              ],
            ),
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

  void _submit() {
    if (_hoursController.text.trim().isEmpty ||
        _reasonController.text.trim().isEmpty ||
        _date == null ||
        _project == 'اختر المشروع أو الوحدة...') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى استكمال جميع البيانات المطلوبة.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تقديم طلب العمل الإضافي بنجاح.')),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: PortalSpacing.xs),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: child,
        ),
      ],
    );
  }
}

class _OvertimeHistoryRow extends StatelessWidget {
  const _OvertimeHistoryRow({
    required this.title,
    required this.status,
    required this.hours,
    required this.date,
    required this.statusColor,
  });

  final String title;
  final String status;
  final String hours;
  final String date;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PortalSpacing.md),
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        border: Border.all(color: PortalColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history,
            color: PortalColors.iconSecondary,
          ),
          const SizedBox(width: PortalSpacing.sm),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmocStatusPill(label: status, color: statusColor),
              const SizedBox(height: PortalSpacing.xs),
              Text(hours, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
