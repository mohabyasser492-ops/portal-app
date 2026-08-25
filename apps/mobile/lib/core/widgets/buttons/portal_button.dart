import 'package:flutter/material.dart';

import '../../../app/theme/portal_colors.dart';
import '../../../app/theme/portal_icon_sizes.dart';
import '../../../app/theme/portal_spacing.dart';

/// Describes the visual variants supported by [PortalButton].
enum PortalButtonVariant { primary, secondary, text, destructive }

/// A reusable Portal App button with consistent styling and behavior.
///
/// The button supports:
///
/// - Primary, secondary, text, and destructive variants
/// - Optional leading or trailing icons
/// - Disabled state
/// - Loading state
/// - Full-width or content-width layout
/// - Accessible semantic labels
class PortalButton extends StatelessWidget {
  const PortalButton({
    required this.label,
    required this.onPressed,
    this.variant = PortalButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.semanticLabel,
    super.key,
  });

  /// The visible text displayed inside the button.
  final String label;

  /// The action performed when the button is activated.
  ///
  /// A null value disables the button.
  final VoidCallback? onPressed;

  /// Controls the visual appearance of the button.
  final PortalButtonVariant variant;

  /// Optional icon displayed before the text in reading order.
  final IconData? leadingIcon;

  /// Optional icon displayed after the text in reading order.
  final IconData? trailingIcon;

  /// Replaces the normal button content with a progress indicator.
  final bool isLoading;

  /// Makes the button fill the available horizontal space.
  final bool expand;

  /// Optional screen-reader description.
  ///
  /// When omitted, [label] is used.
  final String? semanticLabel;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      enabled: !_isDisabled,
      label: semanticLabel ?? label,
      child: ExcludeSemantics(child: _buildButton(context)),
    );

    if (!expand) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildButton(BuildContext context) {
    final callback = _isDisabled ? null : onPressed;
    final content = _buildContent(context);

    return switch (variant) {
      PortalButtonVariant.primary => ElevatedButton(
        onPressed: callback,
        child: content,
      ),
      PortalButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        child: content,
      ),
      PortalButtonVariant.text => TextButton(
        onPressed: callback,
        child: content,
      ),
      PortalButtonVariant.destructive => ElevatedButton(
        onPressed: callback,
        style: _destructiveStyle,
        child: content,
      ),
    };
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: PortalIconSizes.md,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _loadingIndicatorColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: PortalIconSizes.md),
          const SizedBox(width: PortalSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: PortalSpacing.sm),
          Icon(trailingIcon, size: PortalIconSizes.md),
        ],
      ],
    );
  }

  Color get _loadingIndicatorColor {
    return switch (variant) {
      PortalButtonVariant.primary => PortalColors.textOnPrimary,
      PortalButtonVariant.secondary => PortalColors.actionPrimary,
      PortalButtonVariant.text => PortalColors.actionPrimary,
      PortalButtonVariant.destructive => PortalColors.textOnPrimary,
    };
  }

  ButtonStyle get _destructiveStyle {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return PortalColors.actionPrimaryDisabled;
        }

        if (states.contains(WidgetState.pressed)) {
          return PortalColors.red700.withValues(alpha: 0.88);
        }

        return PortalColors.actionDestructive;
      }),
      foregroundColor: const WidgetStatePropertyAll<Color>(
        PortalColors.textOnPrimary,
      ),
    );
  }
}
