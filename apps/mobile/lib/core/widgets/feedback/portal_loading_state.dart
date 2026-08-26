import 'package:flutter/material.dart';

import '../../../app/theme/portal_colors.dart';
import '../../../app/theme/portal_icon_sizes.dart';
import '../../../app/theme/portal_spacing.dart';

/// Visual layouts supported by [PortalLoadingState].
enum PortalLoadingStateLayout {
  /// Displays the indicator above the message.
  centered,

  /// Displays the indicator beside the message.
  inline,
}

/// A reusable loading-state component for Portal App.
///
/// The component provides:
///
/// - A consistent progress indicator
/// - An optional localized loading message
/// - Centered and inline layouts
/// - Accessibility semantics
/// - Arabic RTL support through directional layout behavior
class PortalLoadingState extends StatelessWidget {
  const PortalLoadingState({
    this.message,
    this.semanticLabel,
    this.layout = PortalLoadingStateLayout.centered,
    this.compact = false,
    this.padding = const EdgeInsetsDirectional.all(PortalSpacing.lg),
    super.key,
  });

  /// Optional localized message displayed to the user.
  ///
  /// Examples:
  ///
  /// - Loading profile
  /// - Loading announcements
  /// - جاري تحميل الملف الشخصي
  final String? message;

  /// Optional screen-reader description.
  ///
  /// When omitted, [message] is used. If both values are null, the fallback
  /// accessibility label is "Loading".
  final String? semanticLabel;

  /// Controls whether the loading indicator and message use a centered or
  /// inline arrangement.
  final PortalLoadingStateLayout layout;

  /// Reduces the progress-indicator size and spacing.
  final bool compact;

  /// Space surrounding the loading-state content.
  final EdgeInsetsGeometry padding;

  String get _accessibleLabel {
    return semanticLabel ?? message ?? 'Loading';
  }

  double get _indicatorSize {
    return compact ? PortalIconSizes.lg : PortalIconSizes.display;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: _accessibleLabel,
      child: ExcludeSemantics(
        child: Padding(
          padding: padding,
          child: switch (layout) {
            PortalLoadingStateLayout.centered => _buildCenteredLayout(context),
            PortalLoadingStateLayout.inline => _buildInlineLayout(context),
          },
        ),
      ),
    );
  }

  Widget _buildCenteredLayout(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: compact ? PortalSpacing.sm : PortalSpacing.md),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PortalColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineLayout(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgressIndicator(),
        if (message != null) ...[
          SizedBox(width: compact ? PortalSpacing.sm : PortalSpacing.md),
          Flexible(
            child: Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PortalColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox.square(
      dimension: _indicatorSize,
      child: const CircularProgressIndicator(strokeWidth: 3),
    );
  }
}
