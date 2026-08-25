import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_spacing.dart';

void main() {
  group('PortalSpacing', () {
    test('starts with a zero spacing value', () {
      expect(
        PortalSpacing.none,
        0,
      );
    });

    test('uses positive values after the zero token', () {
      expect(PortalSpacing.xxs, greaterThan(0));
      expect(PortalSpacing.xs, greaterThan(0));
      expect(PortalSpacing.sm, greaterThan(0));
      expect(PortalSpacing.md, greaterThan(0));
      expect(PortalSpacing.lg, greaterThan(0));
      expect(PortalSpacing.xl, greaterThan(0));
      expect(PortalSpacing.xxl, greaterThan(0));
      expect(PortalSpacing.xxxl, greaterThan(0));
    });

    test('increases progressively', () {
      final values = <double>[
        PortalSpacing.none,
        PortalSpacing.xxs,
        PortalSpacing.xs,
        PortalSpacing.sm,
        PortalSpacing.md,
        PortalSpacing.lg,
        PortalSpacing.xl,
        PortalSpacing.xxl,
        PortalSpacing.xxxl,
      ];

      for (var index = 1; index < values.length; index++) {
        expect(
          values[index],
          greaterThan(values[index - 1]),
          reason: 'Spacing token at index $index must be greater '
              'than the previous token.',
        );
      }
    });
  });
}
