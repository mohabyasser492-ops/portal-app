import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_colors.dart';

void main() {
  group('PortalColors', () {
    test('uses the brand palette for primary actions', () {
      expect(
        PortalColors.actionPrimary,
        PortalColors.brand600,
      );

      expect(
        PortalColors.actionPrimaryPressed,
        PortalColors.brand700,
      );

      expect(
        PortalColors.actionPrimaryDisabled,
        PortalColors.brand200,
      );
    });

    test('provides semantic text colors', () {
      expect(
        PortalColors.textPrimary,
        PortalColors.neutral900,
      );

      expect(
        PortalColors.textSecondary,
        PortalColors.neutral600,
      );

      expect(
        PortalColors.textDisabled,
        PortalColors.neutral400,
      );
    });

    test('provides a foreground and surface for every status', () {
      expect(
        PortalColors.statusSuccess,
        isNot(PortalColors.statusSuccessSurface),
      );

      expect(
        PortalColors.statusWarning,
        isNot(PortalColors.statusWarningSurface),
      );

      expect(
        PortalColors.statusError,
        isNot(PortalColors.statusErrorSurface),
      );

      expect(
        PortalColors.statusInformation,
        isNot(PortalColors.statusInformationSurface),
      );
    });

    test('uses a fully opaque color for primary text', () {
      expect(
        PortalColors.textPrimary.a,
        1.0,
      );
    });

    test('uses transparency for the application overlay', () {
      expect(
        PortalColors.overlay.a,
        lessThan(1.0),
      );
    });
  });
}
