import 'package:flutter/material.dart';

import '../../../app/theme/portal_colors.dart';
import '../../../app/theme/portal_elevation.dart';
import '../../../app/theme/portal_radius.dart';
import '../../../app/theme/portal_spacing.dart';

/// Visual styles supported by [PortalCard].
enum PortalCardVariant { standard, outlined, elevated, interactive }

/// A reusable content container used throughout Portal App.
///
/// The card provides:
///
/// - Consistent padding, radius, color, and elevation
/// - Optional title, subtitle, leading widget, and trailing widget
/// - Optional tap interaction
/// - Accessible semantic configuration
/// - Direction-aware layout for Arabic RTL
class PortalCard extends StatelessWidget {
  const PortalCard({
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.variant = PortalCardVariant.standard,
    this.padding = const EdgeInsetsDirectional.all(PortalSpacing.md),
    this.margin = EdgeInsets.zero,
    this.semanticLabel,
    this.excludeChildSemantics = false,
    super.key,
  });

  /// Main card content.
  final Widget child;

  /// Optional heading displayed before the main content.
  final String? title;

  /// Optional supporting text displayed below [title].
  final String? subtitle;

  /// Optional widget displayed at the start of the heading row.
  final Widget? leading;

  /// Optional widget displayed at the end of the heading row.
  final Widget? trailing;

  /// Action performed when the card is selected.
  final VoidCallback? onTap;

  /// Visual appearance of the card.
  final PortalCardVariant variant;

  /// Internal spacing surrounding the card content.
  final EdgeInsetsGeometry padding;

  /// External spacing surrounding the card.
  final EdgeInsetsGeometry margin;

  /// Optional accessible description for the card.
  final String? semanticLabel;

  /// Whether descendant semantics should be excluded.
  ///
  /// Use this only when [semanticLabel] completely describes the card.
  final bool excludeChildSemantics;

  bool get isInteractive => onTap != null || variant == PortalCardVariant.interactive;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: _buildDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(PortalRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          canRequestFocus: onTap != null,
          borderRadius: BorderRadius.circular(PortalRadius.lg),
          child: Padding(padding: padding, child: _buildContent(context)),
        ),
      ),
    );

    if (semanticLabel == null) {
      return card;
    }

    return Semantics(
      container: true,
      button: onTap != null,
      enabled: onTap != null,
      label: semanticLabel,
      child: excludeChildSemantics ? ExcludeSemantics(child: card) : card,
    );
  }

  Widget _buildContent(BuildContext context) {
    final hasHeader = title != null || subtitle != null || leading != null || trailing != null;

    if (!hasHeader) {
      return child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: PortalSpacing.sm)],
            Expanded(child: _buildHeading(context)),
            if (trailing != null) ...[const SizedBox(width: PortalSpacing.sm), trailing!],
          ],
        ),
        const SizedBox(height: PortalSpacing.md),
        child,
      ],
    );
  }

  Widget _buildHeading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) Text(title!, style: Theme.of(context).textTheme.titleMedium),
        if (title != null && subtitle != null) const SizedBox(height: PortalSpacing.xs),
        if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: PortalColors.surfacePrimary,
      borderRadius: BorderRadius.circular(PortalRadius.lg),
      border: _border,
      boxShadow: _boxShadow,
    );
  }

  Border? get _border {
    return switch (variant) {
      PortalCardVariant.standard => Border.all(color: PortalColors.borderSubtle),
      PortalCardVariant.outlined => Border.all(color: PortalColors.borderDefault),
      PortalCardVariant.elevated => null,
      PortalCardVariant.interactive => Border.all(color: PortalColors.borderSubtle),
    };
  }

  List<BoxShadow> get _boxShadow {
    return switch (variant) {
      PortalCardVariant.standard => const [],
      PortalCardVariant.outlined => const [],
      PortalCardVariant.elevated => const [
        BoxShadow(
          color: PortalColors.shadow,
          blurRadius: PortalElevation.high,
          offset: Offset(0, PortalElevation.low),
        ),
      ],
      PortalCardVariant.interactive => const [
        BoxShadow(
          color: PortalColors.shadow,
          blurRadius: PortalElevation.medium,
          offset: Offset(0, PortalElevation.low),
        ),
      ],
    };
  }
}
