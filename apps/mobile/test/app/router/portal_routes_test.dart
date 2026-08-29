import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/router/portal_route_names.dart';
import 'package:portal_app/app/router/portal_route_paths.dart';

void main() {
  group('PortalRouteNames', () {
    test('uses unique route names', () {
      final names = <String>{
        PortalRouteNames.home,
        PortalRouteNames.services,
        PortalRouteNames.requests,
        PortalRouteNames.profile,
        PortalRouteNames.designSystem,
        PortalRouteNames.notFound,
      };

      expect(names.length, 6);
    });

    test('uses non-empty route names', () {
      final names = <String>[
        PortalRouteNames.home,
        PortalRouteNames.services,
        PortalRouteNames.requests,
        PortalRouteNames.profile,
        PortalRouteNames.designSystem,
        PortalRouteNames.notFound,
      ];

      expect(names.every((name) => name.trim().isNotEmpty), isTrue);
    });
  });

  group('PortalRoutePaths', () {
    test('uses unique route paths', () {
      final paths = <String>{
        PortalRoutePaths.home,
        PortalRoutePaths.services,
        PortalRoutePaths.requests,
        PortalRoutePaths.profile,
        PortalRoutePaths.designSystem,
        PortalRoutePaths.notFound,
      };

      expect(paths.length, 6);
    });

    test('starts every route path with a slash', () {
      final paths = <String>[
        PortalRoutePaths.home,
        PortalRoutePaths.services,
        PortalRoutePaths.requests,
        PortalRoutePaths.profile,
        PortalRoutePaths.designSystem,
        PortalRoutePaths.notFound,
      ];

      expect(paths.every((path) => path.startsWith('/')), isTrue);
    });

    test('uses the root path for home', () {
      expect(PortalRoutePaths.home, '/');
    });
  });
}
