import 'package:flutter/material.dart';

import '../../../../app/theme/portal_design_system.dart';

/// A card that displays a title and a list of key-value details.
class ProfileDetailCard extends StatelessWidget {
  const ProfileDetailCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  /// The title of the card section.
  final String title;

  /// The icon representing the section.
  final IconData icon;

  /// The details to display within the card.
  /// 
  /// Typically a list of [ProfileDetailRow] widgets.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: PortalColors.actionPrimary),
                const SizedBox(width: PortalSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PortalSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A row displaying a label and a value within a [ProfileDetailCard].
class ProfileDetailRow extends StatelessWidget {
  const ProfileDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      container: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: isLast ? 0 : PortalSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: PortalIconSizes.md,
                color: PortalColors.textSecondary,
              ),
            ),
            const SizedBox(width: PortalSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PortalColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: PortalSpacing.xs),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
