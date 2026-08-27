import 'package:flutter/material.dart';
import 'core/widgets/dialogs/portal_dialog.dart';
import 'core/widgets/dialogs/show_portal_dialog.dart';
import 'app/theme/portal_spacing.dart';
import 'app/theme/portal_theme.dart';
import 'core/widgets/buttons/portal_button.dart';
import 'core/widgets/cards/portal_card.dart';
import 'core/widgets/inputs/portal_text_field.dart';
import 'core/widgets/status/portal_status_badge.dart';
import 'core/widgets/feedback/portal_loading_state.dart';
import 'core/widgets/feedback/portal_empty_state.dart';
import 'core/widgets/feedback/portal_error_state.dart';
import 'core/widgets/feedback/portal_skeleton.dart';

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
          Text(
            'Design system preview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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
                PortalButton(
                  label: 'Submitting',
                  isLoading: true,
                  expand: true,
                  onPressed: () {},
                ),
                const SizedBox(height: PortalSpacing.sm),
                const PortalButton(
                  label: 'Disabled action',
                  expand: true,
                  onPressed: null,
                ),
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
                PortalTextField(
                  label: 'Password',
                  obscureText: true,
                  showPasswordToggle: true,
                ),
                SizedBox(height: PortalSpacing.md),
                PortalTextField(
                  label: 'Description',
                  hint: 'Enter a detailed description',
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                ),
                SizedBox(height: PortalSpacing.md),
                PortalTextField(
                  label: 'Employee number',
                  initialValue: '12345',
                  readOnly: true,
                ),
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
                  child: Text(
                    'Review the information available in your employee profile.',
                  ),
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
                  child: Text(
                    'This card demonstrates the elevated visual style.',
                  ),
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
                PortalStatusBadge(
                  label: 'Information',
                  type: PortalStatusType.information,
                ),
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
          const SizedBox(height: PortalSpacing.md),

          PortalButton(
            label: 'عرض نافذة التأكيد',
            variant: PortalButtonVariant.secondary,
            expand: true,
            onPressed: () {
              showPortalDialog<void>(
                context: context,
                barrierDismissible: false,
                dialog: PortalDialog(
                  title: 'إرسال الطلب؟',
                  description: 'راجع بيانات الطلب قبل الإرسال.',
                  type: PortalDialogType.confirmation,
                  primaryActionLabel: 'إرسال',
                  onPrimaryAction: () {
                    Navigator.of(context).pop();
                  },
                  secondaryActionLabel: 'إلغاء',
                  onSecondaryAction: () {
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          ),

          const SizedBox(height: PortalSpacing.md),

          PortalButton(
            label: 'عرض نافذة التأكيد',
            variant: PortalButtonVariant.secondary,
            expand: true,
            onPressed: () {
              showPortalDialog<void>(
                context: context,
                barrierDismissible: false,
                dialog: PortalDialog(
                  title: 'إرسال الطلب؟',
                  description: 'راجع بيانات الطلب قبل الإرسال.',
                  type: PortalDialogType.confirmation,
                  primaryActionLabel: 'إرسال',
                  onPrimaryAction: () {
                    Navigator.of(context).pop();
                  },
                  secondaryActionLabel: 'إلغاء',
                  onSecondaryAction: () {
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          ),
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
                    child: Text(
                      'يمكنك مراجعة بيانات الموظف من خلال هذه البطاقة.',
                    ),
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

          const SizedBox(height: PortalSpacing.xl),

          const _PreviewSection(
            title: 'Loading states',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PortalCard(
                  child: PortalLoadingState(
                    message: 'Loading employee information',
                  ),
                ),
                SizedBox(height: PortalSpacing.md),
                PortalCard(
                  child: PortalLoadingState(
                    message: 'Refreshing',
                    layout: PortalLoadingStateLayout.inline,
                    compact: true,
                    padding: EdgeInsetsDirectional.zero,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: PortalSpacing.xl),

          _PreviewSection(
            title: 'Empty states',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PortalCard(
                  child: PortalEmptyState(
                    title: 'No announcements',
                    description: 'New company announcements will appear here.',
                    icon: Icons.campaign_outlined,
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                PortalCard(
                  child: PortalEmptyState(
                    title: 'No search results',
                    description:
                        'Try a different service name or clear the search.',
                    icon: Icons.search_off_outlined,
                    actionLabel: 'Clear search',
                    onAction: () {},
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                const PortalCard(
                  child: PortalEmptyState(
                    title: 'No recent requests',
                    description: 'Submitted requests will appear here.',
                    icon: Icons.description_outlined,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: PortalSpacing.xl),

          _PreviewSection(
            title: 'Error states',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PortalCard(
                  child: PortalErrorState(
                    title: 'Unable to load employee information',
                    description:
                        'Check your internet connection and try again.',
                    retryLabel: 'Try again',
                    onRetry: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Retry action selected')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                PortalCard(
                  child: PortalErrorState(
                    title: 'Unable to submit request',
                    description:
                        'The request was not submitted. Try again or return to your saved drafts.',
                    retryLabel: 'Try again',
                    onRetry: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request submission retry selected'),
                        ),
                      );
                    },
                    secondaryActionLabel: 'Return to drafts',
                    onSecondaryAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Return to drafts selected'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                PortalCard(
                  child: PortalErrorState(
                    title: 'Service temporarily unavailable',
                    description: 'This service cannot be reached right now.',
                    icon: Icons.cloud_off_outlined,
                    secondaryActionLabel: 'Go back',
                    onSecondaryAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Go back action selected'),
                        ),
                      );
                    },
                    compact: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: PortalSpacing.xl),

          _PreviewSection(
            title: 'Dialogs',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PortalButton(
                  label: 'Show information dialog',
                  expand: true,
                  onPressed: () {
                    showPortalDialog<void>(
                      context: context,
                      dialog: PortalDialog(
                        title: 'Employee information',
                        description:
                            'The information shown in the preview is synthetic.',
                        primaryActionLabel: 'Understood',
                        onPrimaryAction: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: PortalSpacing.sm),
                PortalButton(
                  label: 'Show confirmation dialog',
                  variant: PortalButtonVariant.secondary,
                  expand: true,
                  onPressed: () {
                    showPortalDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      dialog: PortalDialog(
                        title: 'Submit request?',
                        description:
                            'Review the request information before submitting.',
                        type: PortalDialogType.confirmation,
                        primaryActionLabel: 'Submit',
                        onPrimaryAction: () {
                          Navigator.of(context).pop();
                        },
                        secondaryActionLabel: 'Cancel',
                        onSecondaryAction: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: PortalSpacing.sm),
                PortalButton(
                  label: 'Show destructive dialog',
                  variant: PortalButtonVariant.destructive,
                  expand: true,
                  onPressed: () {
                    showPortalDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      dialog: PortalDialog(
                        title: 'Delete draft?',
                        description: 'The deleted draft cannot be restored.',
                        type: PortalDialogType.destructive,
                        primaryActionLabel: 'Delete',
                        onPrimaryAction: () {
                          Navigator.of(context).pop();
                        },
                        secondaryActionLabel: 'Keep draft',
                        onSecondaryAction: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: PortalSpacing.xl),

          const _PreviewSection(
            title: 'Skeleton loading',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PortalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PortalSkeleton(
                            width: 56,
                            height: 56,
                            shape: PortalSkeletonShape.circle,
                          ),
                          SizedBox(width: PortalSpacing.md),
                          Expanded(
                            child: PortalTextSkeleton(
                              width: 220,
                              lines: 2,
                              lastLineWidthFactor: 0.55,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: PortalSpacing.lg),
                      PortalTextSkeleton(width: 320, lines: 4),
                    ],
                  ),
                ),
                SizedBox(height: PortalSpacing.md),
                PortalCard(
                  child: Column(
                    children: [
                      PortalListTileSkeleton(),
                      SizedBox(height: PortalSpacing.md),
                      PortalListTileSkeleton(showTrailing: true),
                      SizedBox(height: PortalSpacing.md),
                      PortalListTileSkeleton(showLeading: false),
                    ],
                  ),
                ),
                SizedBox(height: PortalSpacing.md),
                PortalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PortalSkeleton(width: 180, height: 20, animate: false),
                      SizedBox(height: PortalSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: PortalSkeleton(
                          width: 320,
                          height: 120,
                          animate: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
