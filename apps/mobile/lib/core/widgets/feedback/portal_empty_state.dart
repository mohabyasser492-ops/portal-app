import 'package:flutter/material.dart';

import '../../../app/theme/portal_colors.dart';
import '../../../app/theme/portal_icon_sizes.dart';
import '../../../app/theme/portal_spacing.dart';
import '../buttons/portal_button.dart';

/// A reusable empty-state component for Portal App.
///
/// Use this component when content loaded successfully but no items are
/// available. Examples include:
///
/// - No announcements
/// - No employee requests
/// - No search results
/// - No pending approvals
/// - No available services
///
/// The component supports an icon, title, optional description, and optional
/// action button.
class PortalEmptyState extends StatelessWidget {
  const PortalEmptyState({
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
    this.compact = false,
    this.padding = const EdgeInsetsDirectional.all(PortalSpacing.lg),
    super.key,
  }) : assert(
         (actionLabel == null && onAction == null) ||
             (actionLabel != null && onAction != null),
         'actionLabel and onAction must either both be provided or both be null.',
       );

  /// Localized title describing the empty state.
  final String title;

  /// Optional localized explanation or guidance.
  final String? description;

  /// Decorative icon displayed above the title.
  final IconData icon;

  /// Optional localized label for the action button.
  final String? actionLabel;

  /// Optional callback for the action button.
  final VoidCallback? onAction;

  /// Optional screen-reader description for the empty state.
  ///
  /// When omitted, the component combines [title] and [description].
  final String? semanticLabel;

  /// Reduces icon size, padding, and spacing.
  final bool compact;

  /// Space surrounding the empty-state content.
  final EdgeInsetsGeometry padding;

  bool get _hasAction {
    return actionLabel != null && onAction != null;
  }

  String get _accessibleLabel {
    final customLabel = semanticLabel;

    if (customLabel != null) {
      return customLabel;
    }

    final supportingDescription = description;

    if (supportingDescription == null || supportingDescription.trim().isEmpty) {
      return title;
    }

    return '$title. $supportingDescription';
  }

  double get _iconSize {
    return compact ? PortalIconSizes.xl : PortalIconSizes.display;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: _accessibleLabel,
      child: Padding(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: _iconSize,
                    color: PortalColors.iconSecondary,
                  ),
                ),
                SizedBox(height: compact ? PortalSpacing.sm : PortalSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: compact
                      ? Theme.of(context).textTheme.titleSmall
                      : Theme.of(context).textTheme.titleLarge,
                ),
                if (description != null) ...[
                  SizedBox(
                    height: compact ? PortalSpacing.xs : PortalSpacing.sm,
                  ),
                  Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PortalColors.textSecondary,
                    ),
                  ),
                ],
                if (_hasAction) ...[
                  SizedBox(
                    height: compact ? PortalSpacing.md : PortalSpacing.lg,
                  ),
                  PortalButton(
                    label: actionLabel!,
                    onPressed: onAction,
                    variant: PortalButtonVariant.secondary,
                    semanticLabel: actionLabel,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
