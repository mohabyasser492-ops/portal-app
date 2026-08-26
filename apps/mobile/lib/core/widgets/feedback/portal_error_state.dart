import 'package:flutter/material.dart';

import '../../../app/theme/portal_icon_sizes.dart';
import '../../../app/theme/portal_spacing.dart';

/// A reusable error-state component for Portal App.
///
/// Use [PortalErrorState] when content cannot be loaded or an operation fails.
///
/// Examples:
/// - Employee information could not be loaded
/// - Announcements could not be retrieved
/// - A request could not be submitted
/// - A network operation failed
/// - A service is temporarily unavailable
///
/// The component supports:
/// - A localized error title
/// - An optional localized description
/// - A customizable error icon
/// - An optional retry action
/// - An optional secondary action
/// - Standard and compact layouts
/// - Accessibility live-region announcements
/// - Arabic RTL through directional layout behavior
class PortalErrorState extends StatelessWidget {
  const PortalErrorState({
    required this.title,
    this.description,
    this.icon = Icons.error_outline,
    this.retryLabel,
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.semanticLabel,
    this.compact = false,
    this.padding = const EdgeInsetsDirectional.all(PortalSpacing.lg),
    super.key,
  }) : assert(
         (retryLabel == null && onRetry == null) ||
             (retryLabel != null && onRetry != null),
         'retryLabel and onRetry must either both be provided or both be null.',
       ),
       assert(
         (secondaryActionLabel == null && onSecondaryAction == null) ||
             (secondaryActionLabel != null && onSecondaryAction != null),
         'secondaryActionLabel and onSecondaryAction must either both be '
         'provided or both be null.',
       );

  /// Localized title describing the error.
  final String title;

  /// Optional localized explanation or recovery guidance.
  final String? description;

  /// Icon displayed above the error title.
  ///
  /// The icon is excluded from screen-reader output.
  final IconData icon;

  /// Optional localized label for the primary retry action.
  final String? retryLabel;

  /// Callback invoked when the retry action is selected.
  final VoidCallback? onRetry;

  /// Optional localized label for a secondary action.
  final String? secondaryActionLabel;

  /// Callback invoked when the secondary action is selected.
  final VoidCallback? onSecondaryAction;

  /// Optional custom screen-reader description.
  ///
  /// When omitted, [title] and [description] are combined automatically.
  final String? semanticLabel;

  /// Whether the component should use smaller spacing and icon dimensions.
  final bool compact;

  /// Space surrounding the error-state content.
  final EdgeInsetsGeometry padding;

  String get _accessibilityLabel {
    if (semanticLabel != null && semanticLabel!.trim().isNotEmpty) {
      return semanticLabel!;
    }

    if (description == null || description!.trim().isEmpty) {
      return title;
    }

    return '$title. $description';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double iconSize = compact ? PortalIconSizes.md : PortalIconSizes.xl;

    final double spacingSmall = compact ? PortalSpacing.sm : PortalSpacing.md;

    final double spacingLarge = compact ? PortalSpacing.md : PortalSpacing.lg;

    return Semantics(
      container: true,
      liveRegion: true,
      label: _accessibilityLabel,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: iconSize, color: theme.colorScheme.error),
            ),
            SizedBox(height: spacingLarge),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (description != null && description!.trim().isNotEmpty) ...[
              SizedBox(height: spacingSmall),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (retryLabel != null) ...[
              SizedBox(height: spacingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: Text(retryLabel!),
                ),
              ),
            ],
            if (secondaryActionLabel != null) ...[
              SizedBox(height: spacingSmall),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
