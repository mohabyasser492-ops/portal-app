import 'package:flutter/material.dart';

import '../../../app/theme/portal_colors.dart';
import '../../../app/theme/portal_icon_sizes.dart';
import '../../../app/theme/portal_radius.dart';
import '../../../app/theme/portal_spacing.dart';

/// Status types presented by [PortalStatusBadge].
///
/// The status type controls the badge icon, foreground color, and background
/// color. The visible label is supplied separately so the component can use
/// localized Arabic or English text.
enum PortalStatusType { success, warning, error, information, neutral }

/// A compact status indicator that communicates status through text, icon,
/// color, and accessibility semantics.
///
/// Status must never be communicated by color alone. Every badge therefore
/// includes a visible label and icon.
class PortalStatusBadge extends StatelessWidget {
  const PortalStatusBadge({
    required this.label,
    required this.type,
    this.semanticLabel,
    this.compact = false,
    super.key,
  });

  /// Localized text displayed inside the badge.
  final String label;

  /// Semantic status category that controls the badge appearance.
  final PortalStatusType type;

  /// Optional accessible description.
  ///
  /// When omitted, [label] is used.
  final String? semanticLabel;

  /// Reduces the badge's horizontal and vertical padding.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final configuration = _configuration;

    return Semantics(
      container: true,
      label: semanticLabel ?? label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: configuration.backgroundColor,
            borderRadius: BorderRadius.circular(PortalRadius.full),
            border: Border.all(
              color: configuration.foregroundColor.withValues(alpha: 0.24),
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: compact ? PortalSpacing.sm : PortalSpacing.md,
              vertical: compact ? PortalSpacing.xs : PortalSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  configuration.icon,
                  size: compact ? PortalIconSizes.sm : PortalIconSizes.md,
                  color: configuration.foregroundColor,
                ),
                const SizedBox(width: PortalSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: configuration.foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _PortalStatusConfiguration get _configuration {
    return switch (type) {
      PortalStatusType.success => const _PortalStatusConfiguration(
        icon: Icons.check_circle_outline,
        foregroundColor: PortalColors.statusSuccess,
        backgroundColor: PortalColors.statusSuccessSurface,
      ),
      PortalStatusType.warning => const _PortalStatusConfiguration(
        icon: Icons.schedule_outlined,
        foregroundColor: PortalColors.statusWarning,
        backgroundColor: PortalColors.statusWarningSurface,
      ),
      PortalStatusType.error => const _PortalStatusConfiguration(
        icon: Icons.error_outline,
        foregroundColor: PortalColors.statusError,
        backgroundColor: PortalColors.statusErrorSurface,
      ),
      PortalStatusType.information => const _PortalStatusConfiguration(
        icon: Icons.info_outline,
        foregroundColor: PortalColors.statusInformation,
        backgroundColor: PortalColors.statusInformationSurface,
      ),
      PortalStatusType.neutral => const _PortalStatusConfiguration(
        icon: Icons.circle_outlined,
        foregroundColor: PortalColors.textSecondary,
        backgroundColor: PortalColors.surfaceTertiary,
      ),
    };
  }
}

final class _PortalStatusConfiguration {
  const _PortalStatusConfiguration({
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
}
