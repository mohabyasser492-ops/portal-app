import 'package:flutter/material.dart';

import '../../../app/theme/portal_colors.dart';
import '../../../app/theme/portal_icon_sizes.dart';
import '../../../app/theme/portal_spacing.dart';
import '../buttons/portal_button.dart';

/// Visual intent represented by [PortalDialog].
enum PortalDialogType { information, confirmation, warning, destructive, success }

/// A reusable dialog for Portal App.
///
/// The dialog supports:
///
/// - Information, confirmation, warning, destructive, and success states
/// - Optional description and custom content
/// - Optional primary and secondary actions
/// - Optional close button
/// - Accessible route semantics
/// - Arabic RTL through directional layouts
/// - Scrollable content
/// - Action wrapping on narrow screens
class PortalDialog extends StatelessWidget {
  const PortalDialog({
    required this.title,
    this.description,
    this.content,
    this.type = PortalDialogType.information,
    this.icon,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.semanticLabel,
    this.dismissible = true,
    super.key,
  }) : assert(
         (primaryActionLabel == null && onPrimaryAction == null) ||
             (primaryActionLabel != null && onPrimaryAction != null),
         'primaryActionLabel and onPrimaryAction must either both be '
         'provided or both be null.',
       ),
       assert(
         (secondaryActionLabel == null && onSecondaryAction == null) ||
             (secondaryActionLabel != null && onSecondaryAction != null),
         'secondaryActionLabel and onSecondaryAction must either both be '
         'provided or both be null.',
       );

  /// Localized title displayed at the top of the dialog.
  final String title;

  /// Optional localized explanation.
  final String? description;

  /// Optional custom content displayed after the description.
  final Widget? content;

  /// Semantic type controlling the default icon and its color.
  final PortalDialogType type;

  /// Optional icon overriding the icon associated with [type].
  final IconData? icon;

  /// Optional localized label for the primary action.
  final String? primaryActionLabel;

  /// Callback invoked when the primary action is selected.
  final VoidCallback? onPrimaryAction;

  /// Optional localized label for the secondary action.
  final String? secondaryActionLabel;

  /// Callback invoked when the secondary action is selected.
  final VoidCallback? onSecondaryAction;

  /// Optional custom screen-reader description.
  ///
  /// When omitted, [title] and [description] are combined.
  final String? semanticLabel;

  /// Whether the close button is displayed.
  final bool dismissible;

  bool get _hasDescription {
    final value = description;

    return value != null && value.trim().isNotEmpty;
  }

  bool get _hasPrimaryAction {
    return primaryActionLabel != null && onPrimaryAction != null;
  }

  bool get _hasSecondaryAction {
    return secondaryActionLabel != null && onSecondaryAction != null;
  }

  String get _accessibleLabel {
    final customLabel = semanticLabel;

    if (customLabel != null && customLabel.trim().isNotEmpty) {
      return customLabel;
    }

    final supportingDescription = description;

    if (supportingDescription == null || supportingDescription.trim().isEmpty) {
      return title;
    }

    return '$title. $supportingDescription';
  }

  IconData get _resolvedIcon {
    final customIcon = icon;

    if (customIcon != null) {
      return customIcon;
    }

    return switch (type) {
      PortalDialogType.information => Icons.info_outline,
      PortalDialogType.confirmation => Icons.help_outline,
      PortalDialogType.warning => Icons.warning_amber_outlined,
      PortalDialogType.destructive => Icons.delete_outline,
      PortalDialogType.success => Icons.check_circle_outline,
    };
  }

  Color get _iconColor {
    return switch (type) {
      PortalDialogType.information => PortalColors.statusInformation,
      PortalDialogType.confirmation => PortalColors.actionPrimary,
      PortalDialogType.warning => PortalColors.statusWarning,
      PortalDialogType.destructive => PortalColors.statusError,
      PortalDialogType.success => PortalColors.statusSuccess,
    };
  }

  PortalButtonVariant get _primaryButtonVariant {
    if (type == PortalDialogType.destructive) {
      return PortalButtonVariant.destructive;
    }

    return PortalButtonVariant.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: _accessibleLabel,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(PortalSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                if (_hasDescription || content != null) ...[
                  const SizedBox(height: PortalSpacing.md),
                  Flexible(child: SingleChildScrollView(child: _buildContent(context))),
                ],
                if (_hasPrimaryAction || _hasSecondaryAction) ...[
                  const SizedBox(height: PortalSpacing.lg),
                  _buildActions(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(_resolvedIcon, size: PortalIconSizes.xl, color: _iconColor),
        ),
        const SizedBox(width: PortalSpacing.sm),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (dismissible) ...[
          const SizedBox(width: PortalSpacing.sm),
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.close, size: PortalIconSizes.lg),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasDescription)
          Text(
            description!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
          ),
        if (_hasDescription && content != null) const SizedBox(height: PortalSpacing.md),
        if (content != null) content!,
      ],
    );
  }

  Widget _buildActions() {
    if (_hasPrimaryAction && !_hasSecondaryAction) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: PortalButton(
          label: primaryActionLabel!,
          onPressed: onPrimaryAction,
          variant: _primaryButtonVariant,
          semanticLabel: primaryActionLabel,
        ),
      );
    }

    if (!_hasPrimaryAction && _hasSecondaryAction) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: PortalButton(
          label: secondaryActionLabel!,
          onPressed: onSecondaryAction,
          variant: PortalButtonVariant.secondary,
          semanticLabel: secondaryActionLabel,
        ),
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Wrap(
        alignment: WrapAlignment.end,
        runAlignment: WrapAlignment.end,
        spacing: PortalSpacing.sm,
        runSpacing: PortalSpacing.sm,
        children: [
          PortalButton(
            label: secondaryActionLabel!,
            onPressed: onSecondaryAction,
            variant: PortalButtonVariant.secondary,
            semanticLabel: secondaryActionLabel,
          ),
          PortalButton(
            label: primaryActionLabel!,
            onPressed: onPrimaryAction,
            variant: _primaryButtonVariant,
            semanticLabel: primaryActionLabel,
          ),
        ],
      ),
    );
  }
}
