import 'package:flutter/material.dart';

import 'portal_colors.dart';
import 'portal_elevation.dart';
import 'portal_radius.dart';
import 'portal_spacing.dart';
import 'portal_typography.dart';
import 'portal_icon_sizes.dart';

/// AMOC corporate design system.
///
/// The visual language follows the provided AMOC reference screens:
/// off-white background, white layered cards, navy primary actions,
/// steel-blue secondary accents and safety-red emergency states.
final class PortalTheme {
  const PortalTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: PortalColors.brand800,
      onPrimary: PortalColors.neutral0,
      secondary: PortalColors.brand500,
      onSecondary: PortalColors.neutral0,
      error: PortalColors.statusError,
      onError: PortalColors.neutral0,
      surface: PortalColors.surfacePrimary,
      onSurface: PortalColors.textPrimary,
      surfaceContainerLowest: PortalColors.neutral0,
      surfaceContainerLow: PortalColors.surfaceSecondary,
      surfaceContainer: PortalColors.surfaceTertiary,
      surfaceContainerHigh: PortalColors.neutral200,
      outline: PortalColors.borderDefault,
      outlineVariant: PortalColors.borderSubtle,
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
      navigationBarTheme: _navigationBarTheme,
      navigationRailTheme: _navigationRailTheme,
      chipTheme: _chipTheme,
      visualDensity: VisualDensity.standard,
    );
  }

  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: PortalElevation.none,
    scrolledUnderElevation: PortalElevation.none,
    backgroundColor: PortalColors.surfacePrimary,
    foregroundColor: PortalColors.textPrimary,
    centerTitle: false,
    toolbarHeight: 68,
    titleTextStyle: PortalTypography.titleLarge,
    iconTheme: IconThemeData(color: PortalColors.iconPrimary, size: PortalIconSizes.lg),
  );

  static const CardThemeData _cardTheme = CardThemeData(
    color: PortalColors.surfacePrimary,
    surfaceTintColor: Colors.transparent,
    shadowColor: PortalColors.shadow,
    elevation: PortalElevation.none,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(PortalRadius.lg)),
      side: BorderSide(color: PortalColors.borderSubtle),
    ),
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.symmetric(horizontal: PortalSpacing.lg, vertical: PortalSpacing.sm),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return PortalColors.actionPrimaryDisabled;
        }
        if (states.contains(WidgetState.pressed)) {
          return PortalColors.actionPrimaryPressed;
        }
        return PortalColors.actionPrimary;
      }),
      foregroundColor: const WidgetStatePropertyAll<Color>(PortalColors.textOnPrimary),
      textStyle: const WidgetStatePropertyAll<TextStyle>(PortalTypography.labelLarge),
      elevation: const WidgetStatePropertyAll<double>(0),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm))),
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.symmetric(horizontal: PortalSpacing.lg, vertical: PortalSpacing.sm),
      ),
      foregroundColor: const WidgetStatePropertyAll<Color>(PortalColors.actionPrimary),
      backgroundColor: const WidgetStatePropertyAll<Color>(PortalColors.surfacePrimary),
      side: const WidgetStatePropertyAll<BorderSide>(BorderSide(color: PortalColors.actionPrimary)),
      textStyle: const WidgetStatePropertyAll<TextStyle>(PortalTypography.labelLarge),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm))),
      ),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.symmetric(horizontal: PortalSpacing.md, vertical: PortalSpacing.sm),
      ),
      foregroundColor: const WidgetStatePropertyAll<Color>(PortalColors.actionPrimary),
      overlayColor: const WidgetStatePropertyAll<Color>(PortalColors.actionSecondaryPressed),
      textStyle: const WidgetStatePropertyAll<TextStyle>(PortalTypography.labelLarge),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm))),
      ),
    ),
  );

  static const InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: PortalColors.surfacePrimary,
    contentPadding: EdgeInsetsDirectional.symmetric(
      horizontal: PortalSpacing.md,
      vertical: PortalSpacing.md,
    ),
    labelStyle: PortalTypography.bodyMedium,
    hintStyle: TextStyle(
      color: PortalColors.textMuted,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    helperStyle: PortalTypography.bodySmall,
    errorStyle: TextStyle(
      color: PortalColors.statusError,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm)),
      borderSide: BorderSide(color: PortalColors.borderDefault),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm)),
      borderSide: BorderSide(color: PortalColors.borderDefault),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm)),
      borderSide: BorderSide(color: PortalColors.borderFocused, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm)),
      borderSide: BorderSide(color: PortalColors.statusError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm)),
      borderSide: BorderSide(color: PortalColors.statusError, width: 1.5),
    ),
  );

  static const DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: PortalColors.surfacePrimary,
    surfaceTintColor: Colors.transparent,
    elevation: PortalElevation.overlay,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(PortalRadius.xl))),
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: PortalColors.borderSubtle,
    thickness: 1,
    space: PortalSpacing.md,
  );

  static const IconThemeData _iconTheme = IconThemeData(color: PortalColors.iconPrimary);

  static const ProgressIndicatorThemeData _progressIndicatorTheme = ProgressIndicatorThemeData(
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(PortalRadius.sm))),
  );

  static const NavigationBarThemeData _navigationBarTheme = NavigationBarThemeData(
    height: 76,
    backgroundColor: PortalColors.surfacePrimary,
    elevation: 1,
    indicatorColor: PortalColors.brand50,
    labelTextStyle: WidgetStatePropertyAll<TextStyle>(PortalTypography.labelSmall),
    iconTheme: WidgetStatePropertyAll<IconThemeData>(IconThemeData(size: PortalIconSizes.lg)),
  );

  static const NavigationRailThemeData _navigationRailTheme = NavigationRailThemeData(
    backgroundColor: PortalColors.surfacePrimary,
    indicatorColor: PortalColors.brand50,
    groupAlignment: -0.85,
    labelType: NavigationRailLabelType.all,
    minWidth: 86,
    useIndicator: true,
    selectedLabelTextStyle: PortalTypography.labelSmall,
    unselectedLabelTextStyle: PortalTypography.labelSmall,
  );

  static const ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: PortalColors.surfaceTertiary,
    selectedColor: PortalColors.brand50,
    side: BorderSide(color: PortalColors.borderSubtle),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(PortalRadius.full)),
    ),
    labelStyle: PortalTypography.labelSmall,
  );
}
