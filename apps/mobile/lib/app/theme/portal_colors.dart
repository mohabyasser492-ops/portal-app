import 'package:flutter/material.dart';

/// Defines the color palette and semantic color tokens used by Portal App.
///
/// Feature widgets should use semantic tokens such as [actionPrimary] and
/// [textPrimary] instead of using raw hexadecimal color values directly.
final class PortalColors {
  const PortalColors._();

  // ---------------------------------------------------------------------------
  // Brand palette
  // ---------------------------------------------------------------------------

  static const Color brand50 = Color(0xFFEAF2FB);
  static const Color brand100 = Color(0xFFD1E3F6);
  static const Color brand200 = Color(0xFFA6C8EC);
  static const Color brand300 = Color(0xFF78ABE1);
  static const Color brand400 = Color(0xFF4D8ED5);
  static const Color brand500 = Color(0xFF1F6FBE);
  static const Color brand600 = Color(0xFF195FA4);
  static const Color brand700 = Color(0xFF144E88);
  static const Color brand800 = Color(0xFF103E6C);
  static const Color brand900 = Color(0xFF0B2C4D);

  // ---------------------------------------------------------------------------
  // Neutral palette
  // ---------------------------------------------------------------------------

  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ---------------------------------------------------------------------------
  // Status palette
  // ---------------------------------------------------------------------------

  static const Color green50 = Color(0xFFECFDF3);
  static const Color green700 = Color(0xFF027A48);

  static const Color amber50 = Color(0xFFFFFAEB);
  static const Color amber700 = Color(0xFFB54708);

  static const Color red50 = Color(0xFFFEF3F2);
  static const Color red700 = Color(0xFFB42318);

  static const Color blue50 = Color(0xFFEFF8FF);
  static const Color blue700 = Color(0xFF175CD3);

  // ---------------------------------------------------------------------------
  // Semantic surface colors
  // ---------------------------------------------------------------------------

  static const Color surfacePrimary = neutral0;
  static const Color surfaceSecondary = neutral50;
  static const Color surfaceTertiary = neutral100;
  static const Color surfaceDisabled = neutral200;

  // ---------------------------------------------------------------------------
  // Semantic text colors
  // ---------------------------------------------------------------------------

  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral600;
  static const Color textMuted = neutral500;
  static const Color textDisabled = neutral400;
  static const Color textOnPrimary = neutral0;

  // ---------------------------------------------------------------------------
  // Semantic border colors
  // ---------------------------------------------------------------------------

  static const Color borderDefault = neutral300;
  static const Color borderSubtle = neutral200;
  static const Color borderFocused = brand600;
  static const Color borderDisabled = neutral200;

  // ---------------------------------------------------------------------------
  // Semantic action colors
  // ---------------------------------------------------------------------------

  static const Color actionPrimary = brand600;
  static const Color actionPrimaryPressed = brand700;
  static const Color actionPrimaryDisabled = brand200;

  static const Color actionSecondary = neutral0;
  static const Color actionSecondaryPressed = brand50;

  static const Color actionDestructive = red700;

  // ---------------------------------------------------------------------------
  // Semantic status colors
  // ---------------------------------------------------------------------------

  static const Color statusSuccess = green700;
  static const Color statusSuccessSurface = green50;

  static const Color statusWarning = amber700;
  static const Color statusWarningSurface = amber50;

  static const Color statusError = red700;
  static const Color statusErrorSurface = red50;

  static const Color statusInformation = blue700;
  static const Color statusInformationSurface = blue50;

  // ---------------------------------------------------------------------------
  // Semantic icon colors
  // ---------------------------------------------------------------------------

  static const Color iconPrimary = neutral800;
  static const Color iconSecondary = neutral600;
  static const Color iconDisabled = neutral400;
  static const Color iconOnPrimary = neutral0;

  // ---------------------------------------------------------------------------
  // Overlay and shadow colors
  // ---------------------------------------------------------------------------

  static const Color overlay = Color(0x990F172A);
  static const Color shadow = Color(0x1F0F172A);
}
