import 'package:flutter/material.dart';
import '../../../../app/theme/portal_design_system.dart';
import '../../domain/portal_request_status.dart';

class RequestStatusBadge extends StatelessWidget {
  const RequestStatusBadge({required this.status, super.key});
  final PortalRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final data = _presentation(status);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: PortalSpacing.sm,
        vertical: PortalSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(PortalRadius.sm),
      ),
      child: Text(
        data.label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: data.foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

_RequestStatusPresentation _presentation(PortalRequestStatus status) => switch (status) {
  PortalRequestStatus.draft => const _RequestStatusPresentation(
    'Draft',
    PortalColors.neutral700,
    PortalColors.neutral100,
  ),
  PortalRequestStatus.submitted => const _RequestStatusPresentation(
    'Submitted',
    PortalColors.statusInformation,
    PortalColors.statusInformationSurface,
  ),
  PortalRequestStatus.inReview => const _RequestStatusPresentation(
    'In review',
    PortalColors.statusWarning,
    PortalColors.statusWarningSurface,
  ),
  PortalRequestStatus.approved => const _RequestStatusPresentation(
    'Approved',
    PortalColors.statusSuccess,
    PortalColors.statusSuccessSurface,
  ),
  PortalRequestStatus.rejected => const _RequestStatusPresentation(
    'Rejected',
    PortalColors.statusError,
    PortalColors.statusErrorSurface,
  ),
  PortalRequestStatus.cancelled => const _RequestStatusPresentation(
    'Cancelled',
    PortalColors.textSecondary,
    PortalColors.surfaceTertiary,
  ),
};

final class _RequestStatusPresentation {
  const _RequestStatusPresentation(this.label, this.foreground, this.background);
  final String label;
  final Color foreground;
  final Color background;
}
