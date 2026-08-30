import 'package:flutter/material.dart';

import '../../../../app/theme/portal_design_system.dart';
import '../../domain/request_summary.dart';

/// Displays a recent request summary on the Home dashboard.
///
/// This widget depends only on the frontend [RequestSummary] domain model.
/// Backend DTOs and JSON field names are intentionally kept out of the
/// presentation layer.
class HomeRecentRequestCard extends StatelessWidget {
  const HomeRecentRequestCard({required this.request, this.onTap, super.key});

  /// Request information displayed by the card.
  final RequestSummary request;

  /// Optional action called when the request card is selected.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final presentation = _RequestStatusPresentation.fromStatus(request.status);

    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: presentation.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PortalRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(PortalSpacing.sm),
                    child: Icon(
                      presentation.icon,
                      color: presentation.color,
                      size: PortalIconSizes.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: PortalSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: PortalSpacing.xs),
                    Text(
                      request.referenceNumber,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PortalColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: PortalSpacing.sm),
                    Wrap(
                      spacing: PortalSpacing.sm,
                      runSpacing: PortalSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _RequestStatusBadge(presentation: presentation),
                        Text(
                          _formatDate(request.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: PortalColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: PortalSpacing.sm),
                const ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right,
                    color: PortalColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: onTap != null,
      label: _semanticLabel(presentation),
      child: ExcludeSemantics(child: card),
    );
  }

  String _semanticLabel(_RequestStatusPresentation presentation) {
    return '${request.title}. '
        'Reference ${request.referenceNumber}. '
        'Status ${presentation.label}. '
        'Updated ${_formatDate(request.updatedAt)}.';
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString();
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

class _RequestStatusBadge extends StatelessWidget {
  const _RequestStatusBadge({required this.presentation});

  final _RequestStatusPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PortalRadius.sm),
        border: Border.all(color: presentation.color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.sm,
          vertical: PortalSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              presentation.icon,
              size: PortalIconSizes.sm,
              color: presentation.color,
            ),
            const SizedBox(width: PortalSpacing.xs),
            Text(
              presentation.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: presentation.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _RequestStatusPresentation {
  const _RequestStatusPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  factory _RequestStatusPresentation.fromStatus(RequestSummaryStatus status) {
    return switch (status) {
      RequestSummaryStatus.draft => const _RequestStatusPresentation(
        label: 'Draft',
        icon: Icons.edit_note_outlined,
        color: PortalColors.textSecondary,
      ),
      RequestSummaryStatus.pending => const _RequestStatusPresentation(
        label: 'Pending',
        icon: Icons.schedule_outlined,
        color: PortalColors.statusWarning,
      ),
      RequestSummaryStatus.approved => const _RequestStatusPresentation(
        label: 'Approved',
        icon: Icons.check_circle_outline,
        color: PortalColors.statusSuccess,
      ),
      RequestSummaryStatus.rejected => const _RequestStatusPresentation(
        label: 'Rejected',
        icon: Icons.cancel_outlined,
        color: PortalColors.statusError,
      ),
    };
  }
}
