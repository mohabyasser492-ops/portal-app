import 'package:flutter/material.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/portal_widgets.dart';

/// Development preview for reusable Portal App components.
///
/// All displayed information is synthetic and intended only for development
/// and visual verification.
class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
        children: [
          Text('Portal App components', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: PortalSpacing.sm),
          Text(
            'Development preview using synthetic content.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
          ),
          const SizedBox(height: PortalSpacing.xl),
          const _PreviewSection(title: 'Buttons', child: _ButtonsPreview()),
          const SizedBox(height: PortalSpacing.xl),
          const _PreviewSection(title: 'Status badges', child: _StatusBadgesPreview()),
          const SizedBox(height: PortalSpacing.xl),
          const _PreviewSection(
            title: 'Loading state',
            child: PortalCard(child: PortalLoadingState(message: 'Loading employee information')),
          ),
          const SizedBox(height: PortalSpacing.xl),
          const _PreviewSection(
            title: 'Empty state',
            child: PortalCard(
              child: PortalEmptyState(
                title: 'No announcements',
                description: 'New announcements will appear here.',
                icon: Icons.campaign_outlined,
              ),
            ),
          ),
          const SizedBox(height: PortalSpacing.xl),
          _PreviewSection(
            title: 'Error state',
            child: PortalCard(
              child: PortalErrorState(
                title: 'Unable to load information',
                description: 'Check your connection and try again.',
                retryLabel: 'Try again',
                onRetry: () {},
              ),
            ),
          ),
          const SizedBox(height: PortalSpacing.xl),
          const _PreviewSection(
            title: 'Skeleton loading',
            child: PortalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PortalListTileSkeleton(animate: false),
                  SizedBox(height: PortalSpacing.md),
                  PortalListTileSkeleton(showTrailing: true, animate: false),
                  SizedBox(height: PortalSpacing.md),
                  PortalTextSkeleton(width: 280, lines: 3, animate: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: PortalSpacing.xl),
          _PreviewSection(
            title: 'Dialog',
            child: PortalButton(
              label: 'Show confirmation dialog',
              variant: PortalButtonVariant.secondary,
              expand: true,
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    return PortalDialog(
                      title: 'Submit request?',
                      description: 'Review the request before submitting.',
                      type: PortalDialogType.confirmation,
                      primaryActionLabel: 'Submit',
                      onPrimaryAction: () {
                        Navigator.of(dialogContext).pop();
                      },
                      secondaryActionLabel: 'Cancel',
                      onSecondaryAction: () {
                        Navigator.of(dialogContext).pop();
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: PortalSpacing.xl),
          const _PreviewSection(
            title: 'Arabic RTL',
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: PortalCard(
                title: 'الملف الشخصي',
                subtitle: 'المعلومات الشخصية والوظيفية',
                leading: Icon(Icons.person_outline),
                child: Text('يمكنك مراجعة بيانات الموظف من خلال هذه البطاقة.'),
              ),
            ),
          ),
          const SizedBox(height: PortalSpacing.xxxl),
        ],
      ),
    );
  }
}

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

class _ButtonsPreview extends StatelessWidget {
  const _ButtonsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
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
          label: 'Delete',
          leadingIcon: Icons.delete_outline,
          variant: PortalButtonVariant.destructive,
          expand: true,
          onPressed: () {},
        ),
        const SizedBox(height: PortalSpacing.sm),
        const PortalButton(label: 'Disabled action', expand: true, onPressed: null),
      ],
    );
  }
}

class _StatusBadgesPreview extends StatelessWidget {
  const _StatusBadgesPreview();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: PortalSpacing.sm,
      runSpacing: PortalSpacing.sm,
      children: [
        PortalStatusBadge(label: 'Approved', type: PortalStatusType.success),
        PortalStatusBadge(label: 'Pending', type: PortalStatusType.warning),
        PortalStatusBadge(label: 'Rejected', type: PortalStatusType.error),
        PortalStatusBadge(label: 'Information', type: PortalStatusType.information),
        PortalStatusBadge(label: 'Draft', type: PortalStatusType.neutral),
      ],
    );
  }
}
