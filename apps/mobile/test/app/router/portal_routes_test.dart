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
        PortalRouteNames.signIn,
        PortalRouteNames.authenticationLoading,
        PortalRouteNames.notFound,
      };

      expect(names.length, 8);
    });

    test('uses non-empty route names', () {
      final names = <String>[
        PortalRouteNames.home,
        PortalRouteNames.services,
        PortalRouteNames.requests,
        PortalRouteNames.profile,
        PortalRouteNames.designSystem,
        PortalRouteNames.signIn,
        PortalRouteNames.authenticationLoading,
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
        PortalRoutePaths.signIn,
        PortalRoutePaths.authenticationLoading,
        PortalRoutePaths.notFound,
      };

      expect(paths.length, 8);
    });

    test('starts every route path with a slash', () {
      final paths = <String>[
        PortalRoutePaths.home,
        PortalRoutePaths.services,
        PortalRoutePaths.requests,
        PortalRoutePaths.profile,
        PortalRoutePaths.designSystem,
        PortalRoutePaths.signIn,
        PortalRoutePaths.authenticationLoading,
        PortalRoutePaths.notFound,
      ];

      expect(paths.every((path) => path.startsWith('/')), isTrue);
    });

    test('uses the root path for Home', () {
      expect(PortalRoutePaths.home, '/');
    });

    test('defines separate authentication paths', () {
      expect(PortalRoutePaths.signIn, '/sign-in');

      expect(PortalRoutePaths.authenticationLoading, '/auth-loading');

      expect(
        PortalRoutePaths.signIn,
        isNot(PortalRoutePaths.authenticationLoading),
      );
    });
  });
}
