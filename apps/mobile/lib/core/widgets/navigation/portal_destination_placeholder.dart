import 'package:flutter/material.dart';

import '../../../app/theme/portal_design_system.dart';
import '../cards/portal_card.dart';

/// Temporary content displayed while a destination's feature is developed.
///
/// This widget provides a consistent placeholder for application routes
/// without introducing feature-specific business logic.
class PortalDestinationPlaceholder extends StatelessWidget {
  const PortalDestinationPlaceholder({
    required this.title,
    required this.description,
    required this.icon,
    required this.routePath,
    super.key,
  });

  /// Heading displayed at the top of the destination.
  final String title;

  /// Description of the feature that will be added later.
  final String description;

  /// Decorative icon representing the destination.
  final IconData icon;

  /// Route path displayed for development verification.
  final String routePath;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        key: PageStorageKey<String>(routePath),
        padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: PortalSpacing.sm),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
          ),
          const SizedBox(height: PortalSpacing.lg),
          PortalCard(
            semanticLabel: '$title placeholder',
            child: Column(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: PortalIconSizes.display,
                    color: PortalColors.actionPrimary,
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                Text(
                  'Feature coming soon',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: PortalSpacing.sm),
                Text(
                  'The navigation destination is ready. '
                  'Feature content will be added in a separate task.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PortalColors.textSecondary,
                  ),
                ),
                const SizedBox(height: PortalSpacing.md),
                Semantics(
                  label: 'Current route: $routePath',
                  child: ExcludeSemantics(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: PortalColors.surfaceTertiary,
                        borderRadius: BorderRadius.circular(PortalRadius.sm),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: PortalSpacing.md,
                          vertical: PortalSpacing.sm,
                        ),
                        child: Text(
                          routePath,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: PortalColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
