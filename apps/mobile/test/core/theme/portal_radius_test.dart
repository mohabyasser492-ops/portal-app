import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_radius.dart';

void main() {
  group('PortalRadius', () {
    test('starts with a zero radius', () {
      expect(
        PortalRadius.none,
        0,
      );
    });

    test('uses positive values after the zero token', () {
      expect(PortalRadius.xs, greaterThan(0));
      expect(PortalRadius.sm, greaterThan(0));
      expect(PortalRadius.md, greaterThan(0));
      expect(PortalRadius.lg, greaterThan(0));
      expect(PortalRadius.xl, greaterThan(0));
      expect(PortalRadius.full, greaterThan(0));
    });

    test('increases progressively', () {
      final values = <double>[
        PortalRadius.none,
        PortalRadius.xs,
        PortalRadius.sm,
        PortalRadius.md,
        PortalRadius.lg,
        PortalRadius.xl,
        PortalRadius.full,
      ];

      for (var index = 1; index < values.length; index++) {
        expect(
          values[index],
          greaterThan(values[index - 1]),
          reason: 'Radius token at index $index must be greater '
              'than the previous token.',
        );
      }
    });

    test('provides a large radius for pill-shaped components', () {
      expect(
        PortalRadius.full,
        greaterThanOrEqualTo(999),
      );
    });
  });
}
