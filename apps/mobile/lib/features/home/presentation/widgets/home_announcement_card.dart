import 'package:flutter/material.dart';

import '../../../../app/theme/portal_design_system.dart';
import '../../domain/announcement_summary.dart';

/// Displays an announcement summary on the Home dashboard.
///
/// This widget depends only on the frontend [AnnouncementSummary] domain
/// model. Backend DTOs and JSON field names are intentionally excluded from
/// the presentation layer.
class HomeAnnouncementCard extends StatelessWidget {
  const HomeAnnouncementCard({required this.announcement, this.onTap, super.key});

  /// Announcement information displayed by the card.
  final AnnouncementSummary announcement;

  /// Optional action called when the announcement is selected.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(child: _AnnouncementIcon(isPinned: announcement.isPinned)),
                  const SizedBox(width: PortalSpacing.md),
                  Expanded(
                    child: Text(announcement.title, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: PortalSpacing.sm),
                    const ExcludeSemantics(
                      child: Icon(Icons.chevron_right, color: PortalColors.textSecondary),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: PortalSpacing.md),
              Text(announcement.summary, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: PortalSpacing.md),
              Wrap(
                spacing: PortalSpacing.sm,
                runSpacing: PortalSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _formatDate(announcement.publishedAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: PortalColors.textSecondary),
                  ),
                  if (announcement.isPinned) const _PinnedAnnouncementBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: onTap != null,
      label: _semanticLabel(),
      child: ExcludeSemantics(child: card),
    );
  }

  String _semanticLabel() {
    final pinnedDescription = announcement.isPinned ? 'Pinned announcement. ' : '';

    final normalizedTitle = _withTerminalPunctuation(announcement.title);

    final normalizedSummary = _withTerminalPunctuation(announcement.summary);

    return '$pinnedDescription'
        '$normalizedTitle '
        '$normalizedSummary '
        'Published ${_formatDate(announcement.publishedAt)}.';
  }

  String _withTerminalPunctuation(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.endsWith('.') ||
        normalizedValue.endsWith('!') ||
        normalizedValue.endsWith('?')) {
      return normalizedValue;
    }

    return '$normalizedValue.';
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString();
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

/// Decorative announcement icon.
class _AnnouncementIcon extends StatelessWidget {
  const _AnnouncementIcon({required this.isPinned});

  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    final color = isPinned ? PortalColors.actionPrimary : PortalColors.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PortalRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.sm),
        child: Icon(
          isPinned ? Icons.push_pin_outlined : Icons.campaign_outlined,
          color: color,
          size: PortalIconSizes.md,
        ),
      ),
    );
  }
}

/// Visible text indicator for pinned announcements.
class _PinnedAnnouncementBadge extends StatelessWidget {
  const _PinnedAnnouncementBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PortalColors.actionPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PortalRadius.sm),
        border: Border.all(color: PortalColors.actionPrimary.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.sm,
          vertical: PortalSpacing.xs,
        ),
        child: Text(
          'Pinned',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: PortalColors.actionPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
