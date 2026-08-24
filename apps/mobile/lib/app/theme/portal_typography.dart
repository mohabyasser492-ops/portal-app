import 'package:flutter/material.dart';

import 'portal_colors.dart';

/// Defines the typography scale used throughout Portal App.
///
/// These styles provide consistent visual hierarchy and readable line heights
/// for both English and Arabic content.
final class PortalTypography {
  const PortalTypography._();

  static const TextStyle displayLarge = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.4,
  );

  static const TextStyle displayMedium = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle displaySmall = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleLarge = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static const TextStyle titleSmall = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    color: PortalColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle labelLarge = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle labelMedium = TextStyle(
    color: PortalColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle labelSmall = TextStyle(
    color: PortalColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Converts Portal App typography tokens into Flutter's standard TextTheme.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
