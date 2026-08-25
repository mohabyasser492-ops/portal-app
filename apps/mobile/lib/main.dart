import 'package:flutter/material.dart';

import 'app/theme/portal_spacing.dart';
import 'app/theme/portal_theme.dart';
import 'core/widgets/buttons/portal_button.dart';
import 'core/widgets/cards/portal_card.dart';
import 'core/widgets/inputs/portal_text_field.dart';
import 'core/widgets/status/portal_status_badge.dart';

void main() {
  runApp(const PortalApp());
}

class PortalApp extends StatelessWidget {
  const PortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal App',
      debugShowCheckedModeBanner: false,
      theme: PortalTheme.light,
      home: const PortalDesignSystemPreviewPage(),
    );
  }
}

class PortalDesignSystemPreviewPage extends StatelessWidget {
  const PortalDesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portal App')),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
        children: [
          Text('Design system preview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: PortalSpacing.sm),
          Text(
            'This temporary screen previews the reusable Portal App components.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: PortalSpacing.xl),

          // -------------------------------------------------------------------
          // Buttons
          // -------------------------------------------------------------------
          _PreviewSection(
            title: 'Buttons',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PortalButton(
                  label: 'Primary action',
                  leadingIcon: Icons.check,
                  expand: true,
                  onPressed: () {},
                ),
                const SizedBox(height: PortalSpacing.sm),
                PortalButton(
                  label: 'Secondary action',
                  variant: PortalButtonVariant.secondary,
                  expand: true,
                  onPressed: () {},
                ),
                const SizedBox(height: PortalSpacing.sm),
                PortalButton(
                  label: 'Text action',
                  variant: PortalButtonVariant.text,
                  expand: true,
                  onPressed: () {},
                ),
                const SizedBox(height: PortalSpacing.sm),
                PortalButton(
                  label: 'Delete',
                  variant: PortalButtonVariant.destructive,
                  leadingIcon: Icons.delete_outline,
                  expand: true,
                  onPressed: () {},
                ),
                const SizedBox(height: PortalSpacing.sm),
                PortalButton(label: 'Submitting', isLoading: true, expand: true, onPressed: () {}),
                const SizedBox(height: PortalSpacing.sm),
                const PortalButton(label: 'Disabled action', expand: true, onPressed: null),
              ],
            ),
          ),

          const SizedBox(height: PortalSpacing.xl),

          // -------------------------------------------------------------------
          // Text fields
          // -------------------------------------------------------------------
          const _PreviewSection(
            title: 'Text fields',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PortalTextField(
                  label: 'Employee name',
                  hint: 'Enter employee name',
                  leadingIcon: Icons.person_outline,
                  requiredField: true,
                ),
                SizedBox(height: PortalSpacing.md),
                PortalTextField(
                  label: 'Search services',
                  hint: 'Search by service name',
                  leadingIcon: Icons.search,
                  trailingIcon: Icons.close,
                ),
                SizedBox(height: PortalSpacing.md),
                PortalTextField(label: 'Password', obscureText: true, showPasswordToggle: true),
                SizedBox(height: PortalSpacing.md),
                PortalTextField(
                  label: 'Description',
                  hint: 'Enter a detailed description',
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                ),
                SizedBox(height: PortalSpacing.md),
                PortalTextField(label: 'Employee number', initialValue: '12345', readOnly: true),
                SizedBox(height: PortalSpacing.md),
                PortalTextField(
                  label: 'Disabled field',
                  initialValue: 'Unavailable',
                  enabled: false,
                ),
                SizedBox(height: PortalSpacing.md),
                PortalTextField(
                  label: 'Reason',
                  requiredField: true,
                  errorText: 'A reason is required',
                ),
              ],
            ),
          ),

          const SizedBox(height: PortalSpacing.xl),

          // -------------------------------------------------------------------
          // Cards
          // -------------------------------------------------------------------
          _PreviewSection(
            title: 'Cards',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PortalCard(
                  title: 'Employee profile',
                  subtitle: 'Personal and employment information',
                  leading: Icon(Icons.person_outline),
                  child: Text('Review the information available in your employee profile.'),
                ),
                const SizedBox(height: PortalSpacing.md),
                PortalCard(
                  title: 'My requests',
                  subtitle: 'View recent request activity',
                  leading: const Icon(Icons.description_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  variant: PortalCardVariant.interactive,
                  semanticLabel: 'Open my requests',
                  onTap: () {},
                  child: const Text('You have no pending requests.'),
                ),
                const SizedBox(height: PortalSpacing.md),
                const PortalCard(
                  title: 'Important announcement',
                  subtitle: 'Synthetic preview content',
                  leading: Icon(Icons.campaign_outlined),
                  variant: PortalCardVariant.elevated,
                  child: Text('This card demonstrates the elevated visual style.'),
                ),
              ],
            ),
          ),

          const SizedBox(height: PortalSpacing.xl),

          // -------------------------------------------------------------------
          // Status badges
          // -------------------------------------------------------------------
          const _PreviewSection(
            title: 'Status badges',
            child: Wrap(
              spacing: PortalSpacing.sm,
              runSpacing: PortalSpacing.sm,
              children: [
                PortalStatusBadge(
                  label: 'Approved',
                  semanticLabel: 'Request status: approved',
                  type: PortalStatusType.success,
                ),
                PortalStatusBadge(
                  label: 'Pending',
                  semanticLabel: 'Request status: pending',
                  type: PortalStatusType.warning,
                ),
                PortalStatusBadge(
                  label: 'Rejected',
                  semanticLabel: 'Request status: rejected',
                  type: PortalStatusType.error,
                ),
                PortalStatusBadge(label: 'Information', type: PortalStatusType.information),
                PortalStatusBadge(
                  label: 'Draft',
                  semanticLabel: 'Request status: draft',
                  type: PortalStatusType.neutral,
                ),
                PortalStatusBadge(
                  label: 'Compact',
                  type: PortalStatusType.information,
                  compact: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: PortalSpacing.xl),

          // -------------------------------------------------------------------
          // Arabic RTL examples
          // -------------------------------------------------------------------
          _PreviewSection(
            title: 'Arabic RTL examples',
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PortalTextField(
                    label: 'اسم الموظف',
                    hint: 'أدخل اسم الموظف',
                    helperText: 'استخدم الاسم المسجل في ملف الموظف',
                    leadingIcon: Icons.person_outline,
                    requiredField: true,
                  ),
                  const SizedBox(height: PortalSpacing.md),
                  const PortalCard(
                    title: 'الملف الشخصي',
                    subtitle: 'المعلومات الشخصية والوظيفية',
                    leading: Icon(Icons.person_outline),
                    trailing: Icon(Icons.chevron_left),
                    child: Text('يمكنك مراجعة بيانات الموظف من خلال هذه البطاقة.'),
                  ),
                  const SizedBox(height: PortalSpacing.md),
                  const Wrap(
                    spacing: PortalSpacing.sm,
                    runSpacing: PortalSpacing.sm,
                    children: [
                      PortalStatusBadge(
                        label: 'مقبول',
                        semanticLabel: 'حالة الطلب: مقبول',
                        type: PortalStatusType.success,
                      ),
                      PortalStatusBadge(
                        label: 'قيد المراجعة',
                        semanticLabel: 'حالة الطلب: قيد المراجعة',
                        type: PortalStatusType.warning,
                      ),
                      PortalStatusBadge(
                        label: 'مرفوض',
                        semanticLabel: 'حالة الطلب: مرفوض',
                        type: PortalStatusType.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: PortalSpacing.md),
                  PortalButton(
                    label: 'متابعة',
                    trailingIcon: Icons.arrow_back,
                    expand: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: PortalSpacing.xxxl),
        ],
      ),
    );
  }
}

/// A private preview-only widget that displays a section heading followed by
/// the supplied component examples.
///
/// This widget is used only by the temporary design-system preview page.
class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: PortalSpacing.md),
        child,
      ],
    );
  }
}
