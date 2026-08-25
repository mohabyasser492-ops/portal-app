import 'package:flutter/material.dart';

import 'portal_colors.dart';
import 'portal_elevation.dart';
import 'portal_radius.dart';
import 'portal_spacing.dart';
import 'portal_typography.dart';

/// Builds the application-wide Flutter themes used by Portal App.
///
/// Feature widgets should consume styles through [Theme.of] instead of
/// recreating colors, typography, shapes, and component styles locally.
final class PortalTheme {
  const PortalTheme._();

  /// The primary light theme used by Portal App.
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: PortalColors.actionPrimary,
      onPrimary: PortalColors.textOnPrimary,
      secondary: PortalColors.brand500,
      onSecondary: PortalColors.textOnPrimary,
      error: PortalColors.statusError,
      onError: PortalColors.textOnPrimary,
      surface: PortalColors.surfacePrimary,
      onSurface: PortalColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PortalColors.surfaceSecondary,
      textTheme: PortalTypography.textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      dialogTheme: _dialogTheme,
      dividerTheme: _dividerTheme,
      iconTheme: _iconTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      snackBarTheme: _snackBarTheme,
      visualDensity: VisualDensity.standard,
    );
  }

  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: PortalElevation.none,
    scrolledUnderElevation: PortalElevation.low,
    backgroundColor: PortalColors.surfacePrimary,
    foregroundColor: PortalColors.textPrimary,
    centerTitle: false,
    titleTextStyle: PortalTypography.titleLarge,
    iconTheme: IconThemeData(
      color: PortalColors.iconPrimary,
    ),
  );

  static const CardThemeData _cardTheme = CardThemeData(
    color: PortalColors.surfacePrimary,
    surfaceTintColor: Colors.transparent,
    shadowColor: PortalColors.shadow,
    elevation: PortalElevation.low,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.lg),
      ),
      side: BorderSide(
        color: PortalColors.borderSubtle,
      ),
    ),
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size(0, 48),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.lg,
          vertical: PortalSpacing.sm,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return PortalColors.actionPrimaryDisabled;
          }

          if (states.contains(WidgetState.pressed)) {
            return PortalColors.actionPrimaryPressed;
          }

          return PortalColors.actionPrimary;
        },
      ),
      foregroundColor: const WidgetStatePropertyAll<Color>(
        PortalColors.textOnPrimary,
      ),
      textStyle: const WidgetStatePropertyAll<TextStyle>(
        PortalTypography.labelLarge,
      ),
      elevation: const WidgetStatePropertyAll<double>(
        PortalElevation.none,
      ),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(PortalRadius.md),
          ),
        ),
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size(0, 48),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.lg,
          vertical: PortalSpacing.sm,
        ),
      ),
      foregroundColor: const WidgetStatePropertyAll<Color>(
        PortalColors.actionPrimary,
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return PortalColors.actionSecondaryPressed;
          }

          return PortalColors.actionSecondary;
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(
              color: PortalColors.borderDisabled,
            );
          }

          if (states.contains(WidgetState.focused)) {
            return const BorderSide(
              color: PortalColors.borderFocused,
              width: 2,
            );
          }

          return const BorderSide(
            color: PortalColors.actionPrimary,
          );
        },
      ),
      textStyle: const WidgetStatePropertyAll<TextStyle>(
        PortalTypography.labelLarge,
      ),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(PortalRadius.md),
          ),
        ),
      ),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size(48, 48),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.md,
          vertical: PortalSpacing.sm,
        ),
      ),
      foregroundColor: const WidgetStatePropertyAll<Color>(
        PortalColors.actionPrimary,
      ),
      overlayColor: const WidgetStatePropertyAll<Color>(
        PortalColors.actionSecondaryPressed,
      ),
      textStyle: const WidgetStatePropertyAll<TextStyle>(
        PortalTypography.labelLarge,
      ),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(PortalRadius.md),
          ),
        ),
      ),
    ),
  );

  static const InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: PortalColors.surfacePrimary,
    contentPadding: EdgeInsetsDirectional.symmetric(
      horizontal: PortalSpacing.md,
      vertical: PortalSpacing.md,
    ),
    labelStyle: PortalTypography.bodyMedium,
    hintStyle: TextStyle(
      color: PortalColors.textMuted,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    helperStyle: PortalTypography.bodySmall,
    errorStyle: TextStyle(
      color: PortalColors.statusError,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.md),
      ),
      borderSide: BorderSide(
        color: PortalColors.borderDefault,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.md),
      ),
      borderSide: BorderSide(
        color: PortalColors.borderDefault,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.md),
      ),
      borderSide: BorderSide(
        color: PortalColors.borderFocused,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.md),
      ),
      borderSide: BorderSide(
        color: PortalColors.statusError,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.md),
      ),
      borderSide: BorderSide(
        color: PortalColors.statusError,
        width: 2,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.md),
      ),
      borderSide: BorderSide(
        color: PortalColors.borderDisabled,
      ),
    ),
  );

  static const DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: PortalColors.surfacePrimary,
    surfaceTintColor: Colors.transparent,
    elevation: PortalElevation.high,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.xl),
      ),
    ),
    titleTextStyle: PortalTypography.headlineSmall,
    contentTextStyle: PortalTypography.bodyMedium,
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: PortalColors.borderSubtle,
    thickness: 1,
    space: PortalSpacing.md,
  );

  static const IconThemeData _iconTheme = IconThemeData(
    color: PortalColors.iconPrimary,
  );

  static const ProgressIndicatorThemeData _progressIndicatorTheme =
      ProgressIndicatorThemeData(
    color: PortalColors.actionPrimary,
    linearTrackColor: PortalColors.surfaceTertiary,
    circularTrackColor: PortalColors.surfaceTertiary,
  );

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: PortalColors.neutral800,
    contentTextStyle: TextStyle(
      color: PortalColors.neutral0,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    actionTextColor: PortalColors.brand100,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(PortalRadius.md),
      ),
    ),
  );
}
