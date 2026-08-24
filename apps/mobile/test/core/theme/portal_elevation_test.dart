import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_elevation.dart';

void main() {
  group('PortalElevation', () {
    test('starts with zero elevation', () {
      expect(
        PortalElevation.none,
        0,
      );
    });

    test('uses positive elevation after the zero token', () {
      expect(PortalElevation.low, greaterThan(0));
      expect(PortalElevation.medium, greaterThan(0));
      expect(PortalElevation.high, greaterThan(0));
      expect(PortalElevation.overlay, greaterThan(0));
    });

    test('increases progressively', () {
      final values = <double>[
        PortalElevation.none,
        PortalElevation.low,
        PortalElevation.medium,
        PortalElevation.high,
        PortalElevation.overlay,
      ];

      for (var index = 1; index < values.length; index++) {
        expect(
          values[index],
          greaterThan(values[index - 1]),
          reason: 'Elevation token at index $index must be greater '
              'than the previous token.',
        );
      }
    });
  });
}
