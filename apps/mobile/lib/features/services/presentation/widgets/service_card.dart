import 'package:flutter/material.dart';

import '../../../../app/theme/portal_design_system.dart';
import '../../domain/portal_service.dart';
import '../../domain/service_category.dart';

/// Displays one service in the Portal Services catalog.
///
/// This widget depends only on the frontend [PortalService] domain model.
/// Backend DTOs, endpoint paths, and JSON structures are intentionally kept
/// outside the presentation layer.
class ServiceCard extends StatelessWidget {
  const ServiceCard({required this.service, this.onTap, super.key});

  /// Service information displayed in the card.
  final PortalService service;

  /// Action called when an available service is selected.
  ///
  /// The callback is ignored when [PortalService.isAvailable] is false.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final categoryLabel = _categoryLabel(service.category);
    final icon = _iconForName(service.iconName);

    final effectiveOnTap = service.isAvailable ? onTap : null;

    return Semantics(
      container: true,
      button: effectiveOnTap != null,
      enabled: service.isAvailable,
      label: _semanticLabel(categoryLabel),
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: effectiveOnTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ServiceIcon(
                        icon: icon,
                        isAvailable: service.isAvailable,
                      ),
                      const SizedBox(width: PortalSpacing.md),
                      Expanded(
                        child: Text(
                          service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: service.isAvailable
                                    ? PortalColors.textPrimary
                                    : PortalColors.textSecondary,
                              ),
                        ),
                      ),
                      if (effectiveOnTap != null) ...[
                        const SizedBox(width: PortalSpacing.sm),
                        const Icon(
                          Icons.chevron_right,
                          color: PortalColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: PortalSpacing.md),
                  Text(
                    service.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: service.isAvailable
                          ? PortalColors.textPrimary
                          : PortalColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: PortalSpacing.md),
                  Wrap(
                    spacing: PortalSpacing.sm,
                    runSpacing: PortalSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _ServiceCategoryBadge(
                        label: categoryLabel,
                        isAvailable: service.isAvailable,
                      ),
                      if (service.isFeatured)
                        const _ServiceStatusBadge(
                          label: 'Featured',
                          icon: Icons.star_outline,
                          color: PortalColors.actionPrimary,
                        ),
                      if (!service.isAvailable)
                        const _ServiceStatusBadge(
                          label: 'Unavailable',
                          icon: Icons.block_outlined,
                          color: PortalColors.statusError,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(String categoryLabel) {
    final featuredDescription = service.isFeatured ? 'Featured service. ' : '';

    final availabilityDescription = service.isAvailable
        ? 'Available. '
        : 'Currently unavailable. ';

    return '$featuredDescription'
        '${service.name}. '
        '${service.description} '
        'Category $categoryLabel. '
        '$availabilityDescription';
  }

  String _categoryLabel(ServiceCategory category) {
    return switch (category) {
      ServiceCategory.humanResources => 'Human Resources',
      ServiceCategory.leave => 'Leave',
      ServiceCategory.payroll => 'Payroll',
      ServiceCategory.documents => 'Documents',
      ServiceCategory.profile => 'Profile',
      ServiceCategory.general => 'General',
    };
  }

  IconData _iconForName(String iconName) {
    return switch (iconName) {
      'description' => Icons.description_outlined,
      'event_available' => Icons.event_available_outlined,
      'payments' => Icons.payments_outlined,
      'person' => Icons.person_outline,
      'health_and_safety' => Icons.health_and_safety_outlined,
      'help_outline' => Icons.help_outline,
      'verified_user' => Icons.verified_user_outlined,
      'calendar_month' => Icons.calendar_month_outlined,
      'account_balance' => Icons.account_balance_outlined,
      _ => Icons.apps_outlined,
    };
  }
}

/// Decorative icon displayed at the beginning of a service card.
class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.icon, required this.isAvailable});

  final IconData icon;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable
        ? PortalColors.actionPrimary
        : PortalColors.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PortalRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.sm),
        child: Icon(icon, color: color, size: PortalIconSizes.md),
      ),
    );
  }
}

/// Category label displayed on a service card.
class _ServiceCategoryBadge extends StatelessWidget {
  const _ServiceCategoryBadge({required this.label, required this.isAvailable});

  final String label;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable
        ? PortalColors.actionPrimary
        : PortalColors.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PortalRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.sm,
          vertical: PortalSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Status badge displayed for featured or unavailable services.
class _ServiceStatusBadge extends StatelessWidget {
  const _ServiceStatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PortalRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.sm,
          vertical: PortalSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: PortalIconSizes.sm, color: color),
            const SizedBox(width: PortalSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
