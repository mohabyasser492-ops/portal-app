import 'package:flutter/material.dart';

import '../../../app/theme/portal_colors.dart';
import '../../../app/theme/portal_icon_sizes.dart';

/// A reusable Portal App text input with consistent styling and behavior.
///
/// The field supports:
///
/// - Visible labels and hints
/// - Validation messages
/// - Helper text
/// - Leading and trailing icons
/// - Password visibility controls
/// - Disabled and read-only states
/// - Single-line and multiline input
/// - Accessible semantic descriptions
class PortalTextField extends StatefulWidget {
  const PortalTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.requiredField = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.focusNode,
    super.key,
  }) : assert(
         controller == null || initialValue == null,
         'controller and initialValue cannot both be provided.',
       ),
       assert(maxLines == null || maxLines > 0, 'maxLines must be null or greater than zero.'),
       assert(minLines == null || minLines > 0, 'minLines must be null or greater than zero.'),
       assert(
         !showPasswordToggle || obscureText,
         'showPasswordToggle requires obscureText to be true.',
       );

  /// Visible label displayed with the text field.
  final String label;

  /// Controls the text currently entered into the field.
  final TextEditingController? controller;

  /// Initial text used when no [controller] is supplied.
  final String? initialValue;

  /// Optional hint displayed when the field has no value.
  final String? hint;

  /// Optional supporting guidance displayed under the field.
  final String? helperText;

  /// Optional externally controlled error message.
  final String? errorText;

  /// Optional accessible label.
  ///
  /// When omitted, [label] is used.
  final String? semanticLabel;

  /// Optional icon shown at the start of the field.
  final IconData? leadingIcon;

  /// Optional icon shown at the end of a non-password field.
  final IconData? trailingIcon;

  /// Action for the optional trailing icon.
  final VoidCallback? onTrailingIconPressed;

  /// Called whenever the field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the current field value.
  final ValueChanged<String>? onSubmitted;

  /// Validation function used by [Form].
  final FormFieldValidator<String>? validator;

  /// Whether the user can interact with the field.
  final bool enabled;

  /// Whether text can be selected but not modified.
  final bool readOnly;

  /// Whether the input should initially hide its characters.
  final bool obscureText;

  /// Whether a password visibility button should be displayed.
  final bool showPasswordToggle;

  /// Whether the label should visually indicate a required field.
  final bool requiredField;

  /// Whether the field requests focus when first displayed.
  final bool autofocus;

  /// Maximum number of visible lines.
  ///
  /// A null value allows the field to grow as needed.
  final int? maxLines;

  /// Minimum number of visible lines.
  final int? minLines;

  /// Maximum number of characters accepted by the field.
  final int? maxLength;

  /// Keyboard optimized for the expected input type.
  final TextInputType? keyboardType;

  /// Action displayed on the software keyboard.
  final TextInputAction? textInputAction;

  /// Automatic capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Platform autofill hints associated with this input.
  final Iterable<String>? autofillHints;

  /// Optional focus node managed by the parent.
  final FocusNode? focusNode;

  @override
  State<PortalTextField> createState() => _PortalTextFieldState();
}

class _PortalTextFieldState extends State<PortalTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant PortalTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      label: widget.semanticLabel ?? widget.label,
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        obscureText: _isObscured,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        minLines: widget.obscureText ? 1 : widget.minLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        autofillHints: widget.autofillHints,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: widget.enabled ? PortalColors.textPrimary : PortalColors.textDisabled,
        ),
        decoration: InputDecoration(
          label: _buildLabel(context),
          hintText: widget.hint,
          helperText: widget.helperText,
          errorText: widget.errorText,
          prefixIcon: _buildLeadingIcon(),
          suffixIcon: _buildTrailingControl(),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    if (!widget.requiredField) {
      return Text(widget.label);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: widget.label),
          TextSpan(
            text: ' *',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: PortalColors.statusError),
          ),
        ],
      ),
    );
  }

  Widget? _buildLeadingIcon() {
    final leadingIcon = widget.leadingIcon;

    if (leadingIcon == null) {
      return null;
    }

    return Icon(
      leadingIcon,
      size: PortalIconSizes.lg,
      color: widget.enabled ? PortalColors.iconSecondary : PortalColors.iconDisabled,
    );
  }

  Widget? _buildTrailingControl() {
    if (widget.showPasswordToggle) {
      return IconButton(
        tooltip: _isObscured ? 'Show password' : 'Hide password',
        onPressed: widget.enabled && !widget.readOnly ? _togglePasswordVisibility : null,
        icon: Icon(
          _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: PortalIconSizes.lg,
        ),
      );
    }

    final trailingIcon = widget.trailingIcon;

    if (trailingIcon == null) {
      return null;
    }

    if (widget.onTrailingIconPressed == null) {
      return Icon(
        trailingIcon,
        size: PortalIconSizes.lg,
        color: widget.enabled ? PortalColors.iconSecondary : PortalColors.iconDisabled,
      );
    }

    return IconButton(
      tooltip: widget.semanticLabel == null ? widget.label : '${widget.semanticLabel} action',
      onPressed: widget.enabled ? widget.onTrailingIconPressed : null,
      icon: Icon(trailingIcon, size: PortalIconSizes.lg),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }
}
