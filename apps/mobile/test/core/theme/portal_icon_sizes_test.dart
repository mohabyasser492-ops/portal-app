import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_icon_sizes.dart';

void main() {
  group('PortalIconSizes', () {
    test('uses positive icon sizes', () {
      expect(PortalIconSizes.xs, greaterThan(0));
      expect(PortalIconSizes.sm, greaterThan(0));
      expect(PortalIconSizes.md, greaterThan(0));
      expect(PortalIconSizes.lg, greaterThan(0));
      expect(PortalIconSizes.xl, greaterThan(0));
      expect(PortalIconSizes.xxl, greaterThan(0));
      expect(PortalIconSizes.display, greaterThan(0));
    });

    test('increases progressively', () {
      final values = <double>[
        PortalIconSizes.xs,
        PortalIconSizes.sm,
        PortalIconSizes.md,
        PortalIconSizes.lg,
        PortalIconSizes.xl,
        PortalIconSizes.xxl,
        PortalIconSizes.display,
      ];

      for (var index = 1; index < values.length; index++) {
        expect(
          values[index],
          greaterThan(values[index - 1]),
          reason: 'Icon-size token at index $index must be greater '
              'than the previous token.',
        );
      }
    });

    test('uses 24 logical pixels as the large standard icon', () {
      expect(
        PortalIconSizes.lg,
        24,
      );
    });

    test('provides a display size for feedback-state illustrations', () {
      expect(
        PortalIconSizes.display,
        greaterThanOrEqualTo(48),
      );
    });
  });
}
