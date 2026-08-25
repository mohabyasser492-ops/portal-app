import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_colors.dart';
import 'package:portal_app/app/theme/portal_theme.dart';
import 'package:portal_app/app/theme/portal_typography.dart';

void main() {
  group('PortalTheme', () {
    test('uses Material 3', () {
      expect(
        PortalTheme.light.useMaterial3,
        isTrue,
      );
    });

    test('uses the Portal App light color scheme', () {
      final theme = PortalTheme.light;

      expect(theme.brightness, Brightness.light);
      expect(
        theme.colorScheme.primary,
        PortalColors.actionPrimary,
      );
      expect(
        theme.colorScheme.onPrimary,
        PortalColors.textOnPrimary,
      );
      expect(
        theme.colorScheme.surface,
        PortalColors.surfacePrimary,
      );
      expect(
        theme.colorScheme.error,
        PortalColors.statusError,
      );
    });

    test('uses the shared typography scale', () {
      final theme = PortalTheme.light;

      final titleLarge = theme.textTheme.titleLarge;
      final bodyMedium = theme.textTheme.bodyMedium;
      final labelLarge = theme.textTheme.labelLarge;

      expect(titleLarge, isNotNull);
      expect(bodyMedium, isNotNull);
      expect(labelLarge, isNotNull);

      expect(
        titleLarge!.fontSize,
        PortalTypography.titleLarge.fontSize,
      );
      expect(
        titleLarge.fontWeight,
        PortalTypography.titleLarge.fontWeight,
      );
      expect(
        titleLarge.height,
        PortalTypography.titleLarge.height,
      );
      expect(
        titleLarge.color,
        PortalTypography.titleLarge.color,
      );

      expect(
        bodyMedium!.fontSize,
        PortalTypography.bodyMedium.fontSize,
      );
      expect(
        bodyMedium.fontWeight,
        PortalTypography.bodyMedium.fontWeight,
      );
      expect(
        bodyMedium.height,
        PortalTypography.bodyMedium.height,
      );
      expect(
        bodyMedium.color,
        PortalTypography.bodyMedium.color,
      );

      expect(
        labelLarge!.fontSize,
        PortalTypography.labelLarge.fontSize,
      );
      expect(
        labelLarge.fontWeight,
        PortalTypography.labelLarge.fontWeight,
      );
      expect(
        labelLarge.height,
        PortalTypography.labelLarge.height,
      );
      expect(
        labelLarge.color,
        PortalTypography.labelLarge.color,
      );
    });

    test('uses the secondary surface as the scaffold background', () {
      expect(
        PortalTheme.light.scaffoldBackgroundColor,
        PortalColors.surfaceSecondary,
      );
    });

    test('configures core component themes', () {
      final theme = PortalTheme.light;

      expect(theme.appBarTheme.backgroundColor, isNotNull);
      expect(theme.cardTheme.color, isNotNull);
      expect(theme.elevatedButtonTheme.style, isNotNull);
      expect(theme.outlinedButtonTheme.style, isNotNull);
      expect(theme.textButtonTheme.style, isNotNull);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.dialogTheme.backgroundColor, isNotNull);
      expect(
        theme.snackBarTheme.behavior,
        SnackBarBehavior.floating,
      );
    });

    testWidgets('provides the Portal theme to descendant widgets', (
      tester,
    ) async {
      ThemeData? receivedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: PortalTheme.light,
          home: Builder(
            builder: (context) {
              receivedTheme = Theme.of(context);

              return const Scaffold(
                body: Text('Portal App'),
              );
            },
          ),
        ),
      );

      expect(receivedTheme, isNotNull);
      expect(
        receivedTheme!.colorScheme.primary,
        PortalColors.actionPrimary,
      );

      final receivedBodyMedium = receivedTheme!.textTheme.bodyMedium;

      expect(receivedBodyMedium, isNotNull);
      expect(
        receivedBodyMedium!.fontSize,
        PortalTypography.bodyMedium.fontSize,
      );
      expect(
        receivedBodyMedium.fontWeight,
        PortalTypography.bodyMedium.fontWeight,
      );
      expect(
        receivedBodyMedium.height,
        PortalTypography.bodyMedium.height,
      );
      expect(
        receivedBodyMedium.color,
        PortalTypography.bodyMedium.color,
      );
    });
  });
}
