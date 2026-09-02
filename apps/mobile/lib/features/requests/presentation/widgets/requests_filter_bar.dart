import 'package:flutter/material.dart';
import '../../../../app/theme/portal_design_system.dart';
import '../../domain/portal_request_status.dart';
import '../../domain/request_type.dart';

class RequestsFilterBar extends StatelessWidget {
  const RequestsFilterBar({
    required this.selectedStatus,
    required this.selectedType,
    required this.onStatusSelected,
    required this.onTypeSelected,
    required this.onClear,
    this.enabled = true,
    super.key,
  });

  final PortalRequestStatus? selectedStatus;
  final RequestType? selectedType;
  final ValueChanged<PortalRequestStatus?> onStatusSelected;
  final ValueChanged<RequestType?> onTypeSelected;
  final VoidCallback onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: PortalSpacing.sm,
      runSpacing: PortalSpacing.sm,
      children: [
        _FilterDropdown<PortalRequestStatus>(
          label: selectedStatus == null ? 'كل الحالات' : _statusLabel(selectedStatus!),
          value: selectedStatus,
          items: [null, ...PortalRequestStatus.values],
          itemLabel: (value) => value == null ? 'كل الحالات' : _statusLabel(value),
          onChanged: enabled ? onStatusSelected : null,
        ),
        _FilterDropdown<RequestType>(
          label: selectedType == null ? 'كل أنواع الطلبات' : _typeLabel(selectedType!),
          value: selectedType,
          items: [null, ...RequestType.values],
          itemLabel: (value) => value == null ? 'كل أنواع الطلبات' : _typeLabel(value),
          onChanged: enabled ? onTypeSelected : null,
        ),
        if (selectedStatus != null || selectedType != null)
          OutlinedButton.icon(
            onPressed: enabled ? onClear : null,
            icon: const Icon(Icons.clear),
            label: const Text('مسح التصفية'),
          ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({required this.label, required this.value, required this.items, required this.itemLabel, required this.onChanged});
  final String label;
  final T? value;
  final List<T?> items;
  final String Function(T?) itemLabel;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T?>(
        value: value,
        hint: Text(label),
        onChanged: onChanged,
        borderRadius: BorderRadius.circular(PortalRadius.md),
        items: items.map((item) => DropdownMenuItem<T?>(value: item, child: Text(itemLabel(item)))).toList(),
      ),
    );
  }
}

String _statusLabel(PortalRequestStatus status) => switch (status) {
      PortalRequestStatus.draft => 'مسودة',
      PortalRequestStatus.submitted => 'مُقدّم',
      PortalRequestStatus.inReview => 'قيد المراجعة',
      PortalRequestStatus.approved => 'معتمد',
      PortalRequestStatus.rejected => 'مرفوض',
      PortalRequestStatus.cancelled => 'ملغي',
    };

String _typeLabel(RequestType type) => switch (type) {
      RequestType.leave => 'إجازة',
      RequestType.employmentLetter => 'خطاب جهة العمل',
      RequestType.salaryCertificate => 'شهادة راتب',
      RequestType.profileUpdate => 'تحديث الملف الشخصي',
      RequestType.payrollInquiry => 'استفسار رواتب',
      RequestType.generalInquiry => 'استفسار عام',
    };
