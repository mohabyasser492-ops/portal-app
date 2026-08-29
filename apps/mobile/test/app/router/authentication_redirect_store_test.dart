import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/router/authentication_redirect_store.dart';
import 'package:portal_app/app/router/portal_route_paths.dart';

void main() {
  group('AuthenticationRedirectStore', () {
    test('starts without an intended location', () {
      final store = AuthenticationRedirectStore();

      expect(store.intendedLocation, isNull);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('remembers a protected application location', () {
      final store = AuthenticationRedirectStore();

      store.remember(PortalRoutePaths.requests);

      expect(store.intendedLocation, PortalRoutePaths.requests);

      expect(store.hasIntendedLocation, isTrue);
    });

    test('preserves query parameters', () {
      final store = AuthenticationRedirectStore();

      store.remember('/requests?status=pending');

      expect(store.intendedLocation, '/requests?status=pending');
    });

    test('preserves URL fragments', () {
      final store = AuthenticationRedirectStore();

      store.remember('/profile#employment');

      expect(store.intendedLocation, '/profile#employment');
    });

    test('preserves query parameters and fragments together', () {
      final store = AuthenticationRedirectStore();

      store.remember('/requests?status=pending#latest');

      expect(store.intendedLocation, '/requests?status=pending#latest');
    });

    test('trims surrounding whitespace', () {
      final store = AuthenticationRedirectStore();

      store.remember('  /services  ');

      expect(store.intendedLocation, PortalRoutePaths.services);
    });

    test('ignores an empty location', () {
      final store = AuthenticationRedirectStore();

      store.remember('');

      expect(store.intendedLocation, isNull);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('ignores a whitespace-only location', () {
      final store = AuthenticationRedirectStore();

      store.remember('   ');

      expect(store.intendedLocation, isNull);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('ignores a relative location', () {
      final store = AuthenticationRedirectStore();

      store.remember('requests');

      expect(store.intendedLocation, isNull);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('ignores a protocol-relative URL', () {
      final store = AuthenticationRedirectStore();

      store.remember('//evil.com/phishing');

      expect(store.intendedLocation, isNull);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('ignores external absolute URLs', () {
      final store = AuthenticationRedirectStore();

      store.remember('https://malicious-site.com/requests');

      expect(store.intendedLocation, isNull);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('overwrites previous intended location with a new valid one', () {
      final store = AuthenticationRedirectStore();

      store.remember('/services');
      store.remember('/profile');

      expect(store.intendedLocation, '/profile');
    });

    test('consume returns stored location and resets state', () {
      final store = AuthenticationRedirectStore();

      store.remember('/requests');

      final consumed = store.consume();

      expect(consumed, '/requests');
      expect(store.intendedLocation, isNull);
      expect(store.hasIntendedLocation, isFalse);
    });

    test('clear removes the stored intended location', () {
      final store = AuthenticationRedirectStore();

      store.remember('/requests');
      store.clear();

      expect(store.intendedLocation, isNull);
      expect(store.hasIntendedLocation, isFalse);
    });
  });
}
