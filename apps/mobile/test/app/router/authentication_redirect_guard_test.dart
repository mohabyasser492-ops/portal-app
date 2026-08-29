import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/router/authentication_redirect_guard.dart';
import 'package:portal_app/app/router/authentication_redirect_store.dart';
import 'package:portal_app/app/router/portal_route_paths.dart';
import 'package:portal_app/features/authentication/application/authentication_state.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';

void main() {
  const authenticatedUser = PortalUser(
    id: 'synthetic-user-id',
    displayName: 'Portal Employee',
    email: 'employee@example.invalid',
  );

  group('AuthenticationRedirectGuard', () {
    test('redirects an initializing session to loading', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.initializing(),
        currentLocation: PortalRoutePaths.home,
      );

      expect(redirect, PortalRoutePaths.authenticationLoading);

      expect(store.intendedLocation, PortalRoutePaths.home);
    });

    test('keeps an initializing session on loading', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.initializing(),
        currentLocation: PortalRoutePaths.authenticationLoading,
      );

      expect(redirect, isNull);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('remembers a protected route while initializing', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.initializing(),
        currentLocation: PortalRoutePaths.requests,
      );

      expect(redirect, PortalRoutePaths.authenticationLoading);

      expect(store.intendedLocation, PortalRoutePaths.requests);
    });

    test('preserves query parameters while initializing', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.initializing(),
        currentLocation: '/requests?status=pending',
      );

      expect(redirect, PortalRoutePaths.authenticationLoading);

      expect(store.intendedLocation, '/requests?status=pending');
    });

    test('redirects a signed-out user to sign in', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedOut(),
        currentLocation: PortalRoutePaths.services,
      );

      expect(redirect, PortalRoutePaths.signIn);

      expect(store.intendedLocation, PortalRoutePaths.services);
    });

    test('keeps a signed-out user on sign in', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedOut(),
        currentLocation: PortalRoutePaths.signIn,
      );

      expect(redirect, isNull);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('redirects signed out from loading to sign in', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedOut(),
        currentLocation: PortalRoutePaths.authenticationLoading,
      );

      expect(redirect, PortalRoutePaths.signIn);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('keeps a signing-in user on sign in', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signingIn(),
        currentLocation: PortalRoutePaths.signIn,
      );

      expect(redirect, isNull);
    });

    test('redirects signing-in user from protected route', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signingIn(),
        currentLocation: PortalRoutePaths.profile,
      );

      expect(redirect, PortalRoutePaths.signIn);

      expect(store.intendedLocation, PortalRoutePaths.profile);
    });

    test('allows a signed-in user to access Home', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.home,
      );

      expect(redirect, isNull);
    });

    test('allows a signed-in user to access Services', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.services,
      );

      expect(redirect, isNull);
    });

    test('allows a signed-in user to access Requests', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.requests,
      );

      expect(redirect, isNull);
    });

    test('allows a signed-in user to access Profile', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.profile,
      );

      expect(redirect, isNull);
    });

    test('allows a signed-in user to access design system', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.designSystem,
      );

      expect(redirect, isNull);
    });

    test('restores the intended route after sign in', () {
      final store = AuthenticationRedirectStore();

      store.remember(PortalRoutePaths.requests);

      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.signIn,
      );

      expect(redirect, PortalRoutePaths.requests);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('restores the intended route from loading after sign in', () {
      final store = AuthenticationRedirectStore();

      store.remember(PortalRoutePaths.profile);

      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.authenticationLoading,
      );

      expect(redirect, PortalRoutePaths.profile);

      expect(store.hasIntendedLocation, isFalse);
    });

    test('returns Home after sign in without an intended route', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.signIn,
      );

      expect(redirect, PortalRoutePaths.home);
    });

    test('redirects signing out to authentication loading', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signingOut(),
        currentLocation: PortalRoutePaths.requests,
      );

      expect(redirect, PortalRoutePaths.authenticationLoading);
    });

    test('keeps signing out on authentication loading', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signingOut(),
        currentLocation: PortalRoutePaths.authenticationLoading,
      );

      expect(redirect, isNull);
    });

    test('redirects a failure state to sign in', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.failure(
          'Unable to restore the session.',
        ),
        currentLocation: PortalRoutePaths.profile,
      );

      expect(redirect, PortalRoutePaths.signIn);

      expect(store.intendedLocation, PortalRoutePaths.profile);
    });

    test('keeps a failure state on sign in', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.failure(
          'Unable to sign in.',
        ),
        currentLocation: PortalRoutePaths.signIn,
      );

      expect(redirect, isNull);
    });

    test('normalizes an empty current location to Home', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedOut(),
        currentLocation: '   ',
      );

      expect(redirect, PortalRoutePaths.signIn);

      expect(store.intendedLocation, PortalRoutePaths.home);
    });

    test('does not overwrite intended route with sign-in route', () {
      final store = AuthenticationRedirectStore();

      store.remember(PortalRoutePaths.services);

      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedOut(),
        currentLocation: PortalRoutePaths.signIn,
      );

      expect(redirect, isNull);

      expect(store.intendedLocation, PortalRoutePaths.services);
    });

    test('does not store authentication loading as intended route', () {
      final store = AuthenticationRedirectStore();

      store.remember(PortalRoutePaths.requests);

      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final redirect = guard.redirect(
        authenticationState: const AuthenticationState.signedOut(),
        currentLocation: PortalRoutePaths.authenticationLoading,
      );

      expect(redirect, PortalRoutePaths.signIn);

      expect(store.intendedLocation, PortalRoutePaths.requests);
    });

    test('preserves intended route through authentication states', () {
      final store = AuthenticationRedirectStore();
      final guard = AuthenticationRedirectGuard(redirectStore: store);

      final initializingRedirect = guard.redirect(
        authenticationState: const AuthenticationState.initializing(),
        currentLocation: PortalRoutePaths.requests,
      );

      expect(initializingRedirect, PortalRoutePaths.authenticationLoading);

      expect(store.intendedLocation, PortalRoutePaths.requests);

      final signedOutRedirect = guard.redirect(
        authenticationState: const AuthenticationState.signedOut(),
        currentLocation: PortalRoutePaths.authenticationLoading,
      );

      expect(signedOutRedirect, PortalRoutePaths.signIn);

      expect(store.intendedLocation, PortalRoutePaths.requests);

      final signedInRedirect = guard.redirect(
        authenticationState: const AuthenticationState.signedIn(
          authenticatedUser,
        ),
        currentLocation: PortalRoutePaths.signIn,
      );

      expect(signedInRedirect, PortalRoutePaths.requests);

      expect(store.hasIntendedLocation, isFalse);
    });
  });
}
