import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_colors.dart';
import 'package:portal_app/app/theme/portal_typography.dart';

void main() {
  group('PortalTypography', () {
    test('uses progressively smaller display styles', () {
      expect(
        PortalTypography.displayLarge.fontSize,
        greaterThan(PortalTypography.displayMedium.fontSize!),
      );

      expect(
        PortalTypography.displayMedium.fontSize,
        greaterThan(PortalTypography.displaySmall.fontSize!),
      );
    });

    test('uses readable body text sizes', () {
      expect(
        PortalTypography.bodyLarge.fontSize,
        greaterThanOrEqualTo(18),
      );

      expect(
        PortalTypography.bodyMedium.fontSize,
        greaterThanOrEqualTo(16),
      );

      expect(
        PortalTypography.bodySmall.fontSize,
        greaterThanOrEqualTo(14),
      );
    });

    test('uses generous line heights for body content', () {
      expect(
        PortalTypography.bodyLarge.height,
        greaterThanOrEqualTo(1.5),
      );

      expect(
        PortalTypography.bodyMedium.height,
        greaterThanOrEqualTo(1.5),
      );

      expect(
        PortalTypography.bodySmall.height,
        greaterThanOrEqualTo(1.5),
      );
    });

    test('uses semantic colors for primary and secondary content', () {
      expect(
        PortalTypography.bodyMedium.color,
        PortalColors.textPrimary,
      );

      expect(
        PortalTypography.bodySmall.color,
        PortalColors.textSecondary,
      );
    });

    test('uses stronger weights for titles than body content', () {
      expect(
        PortalTypography.titleMedium.fontWeight,
        FontWeight.w600,
      );

      expect(
        PortalTypography.bodyMedium.fontWeight,
        FontWeight.w400,
      );
    });

    test('maps typography tokens to the Flutter text theme', () {
      expect(
        PortalTypography.textTheme.titleLarge,
        PortalTypography.titleLarge,
      );

      expect(
        PortalTypography.textTheme.bodyMedium,
        PortalTypography.bodyMedium,
      );

      expect(
        PortalTypography.textTheme.labelLarge,
        PortalTypography.labelLarge,
      );
    });
  });
}
