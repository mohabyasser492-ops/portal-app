import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/portal_design_system.dart';
import '../application/requests_controller.dart';
import '../domain/request_type.dart';

class RequestCreatePage extends ConsumerStatefulWidget {
  const RequestCreatePage({this.initialType, super.key});
  final RequestType? initialType;

  @override
  ConsumerState<RequestCreatePage> createState() => _RequestCreatePageState();
}

class _RequestCreatePageState extends ConsumerState<RequestCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late RequestType _type;
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? RequestType.generalInquiry;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(requestsControllerProvider.select((state) => state.isSubmitting));
    return Scaffold(
      appBar: AppBar(title: const Text('طلب جديد')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
            children: [
              Text('تفاصيل الطلب', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: PortalSpacing.sm),
              Text(
                'اختر نوع الطلب واكتب ما تحتاجه.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
              ),
              const SizedBox(height: PortalSpacing.xl),
              DropdownButtonFormField<RequestType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'نوع الطلب'),
                items: RequestType.values
                    .map((type) => DropdownMenuItem(value: type, child: Text(_typeLabel(type))))
                    .toList(),
                onChanged: submitting ? null : (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: PortalSpacing.md),
              TextFormField(
                controller: _descriptionController,
                minLines: 6,
                maxLines: 10,
                enabled: !submitting,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'التفاصيل',
                  hintText: 'اكتب تفاصيل طلبك وأي معلومات مرتبطة به.',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().length < 5
                    ? 'يرجى إدخال 5 أحرف على الأقل.'
                    : null,
              ),
              const SizedBox(height: PortalSpacing.lg),
              FilledButton.icon(
                onPressed: submitting ? null : _submit,
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(submitting ? 'جاري التقديم...' : 'تقديم الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final created = await ref
        .read(requestsControllerProvider.notifier)
        .createRequest(type: _type, description: _descriptionController.text);
    if (!mounted) return;
    if (created != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${created.referenceNumber} submitted successfully.')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to submit the request.')));
    }
  }

  static String _typeLabel(RequestType type) => switch (type) {
    RequestType.leave => 'إجازة',
    RequestType.employmentLetter => 'خطاب جهة العمل',
    RequestType.salaryCertificate => 'شهادة راتب',
    RequestType.profileUpdate => 'تحديث الملف الشخصي',
    RequestType.payrollInquiry => 'استفسار رواتب',
    RequestType.generalInquiry => 'استفسار عام',
  };
}
