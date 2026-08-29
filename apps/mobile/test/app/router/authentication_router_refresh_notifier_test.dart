import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/router/authentication_router_refresh_notifier.dart';
import 'package:portal_app/features/authentication/application/authentication_state.dart';
import 'package:portal_app/features/authentication/domain/authentication_status.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';

void main() {
  const authenticatedUser = PortalUser(
    id: 'synthetic-user-id',
    displayName: 'Portal Employee',
    email: 'employee@example.invalid',
  );

  group('AuthenticationRouterRefreshNotifier', () {
    test('stores the initial authentication state', () {
      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.initializing(),
      );

      addTearDown(notifier.dispose);

      expect(
        notifier.authenticationState,
        const AuthenticationState.initializing(),
      );

      expect(
        notifier.authenticationState.status,
        AuthenticationStatus.initializing,
      );
    });

    test('updates the authentication state', () {
      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.initializing(),
      );

      addTearDown(notifier.dispose);

      notifier.update(const AuthenticationState.signedOut());

      expect(
        notifier.authenticationState,
        const AuthenticationState.signedOut(),
      );

      expect(
        notifier.authenticationState.status,
        AuthenticationStatus.signedOut,
      );
    });

    test('notifies listeners when authentication changes', () {
      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.initializing(),
      );

      addTearDown(notifier.dispose);

      var notificationCount = 0;

      notifier.addListener(() {
        notificationCount++;
      });

      notifier.update(const AuthenticationState.signedOut());

      expect(notificationCount, 1);
    });

    test('does not notify listeners for an equal state', () {
      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedOut(),
      );

      addTearDown(notifier.dispose);

      var notificationCount = 0;

      notifier.addListener(() {
        notificationCount++;
      });

      notifier.update(const AuthenticationState.signedOut());

      expect(notificationCount, 0);
    });

    test('notifies for each different authentication state', () {
      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.initializing(),
      );

      addTearDown(notifier.dispose);

      var notificationCount = 0;

      notifier.addListener(() {
        notificationCount++;
      });

      notifier.update(const AuthenticationState.signedOut());

      notifier.update(const AuthenticationState.signingIn());

      notifier.update(const AuthenticationState.signedIn(authenticatedUser));

      expect(notificationCount, 3);

      expect(
        notifier.authenticationState,
        const AuthenticationState.signedIn(authenticatedUser),
      );
    });

    test('notifies when the authenticated user changes', () {
      const firstUser = PortalUser(
        id: 'first-user',
        displayName: 'First Employee',
      );

      const secondUser = PortalUser(
        id: 'second-user',
        displayName: 'Second Employee',
      );

      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(firstUser),
      );

      addTearDown(notifier.dispose);

      var notificationCount = 0;

      notifier.addListener(() {
        notificationCount++;
      });

      notifier.update(const AuthenticationState.signedIn(secondUser));

      expect(notificationCount, 1);

      expect(notifier.authenticationState.user, secondUser);
    });

    test('notifies when the failure message changes', () {
      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.failure(
          'First authentication failure.',
        ),
      );

      addTearDown(notifier.dispose);

      var notificationCount = 0;

      notifier.addListener(() {
        notificationCount++;
      });

      notifier.update(
        const AuthenticationState.failure('Second authentication failure.'),
      );

      expect(notificationCount, 1);

      expect(
        notifier.authenticationState.errorMessage,
        'Second authentication failure.',
      );
    });

    test('can transition from signed in to signing out', () {
      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signedIn(authenticatedUser),
      );

      addTearDown(notifier.dispose);

      var notificationCount = 0;

      notifier.addListener(() {
        notificationCount++;
      });

      notifier.update(const AuthenticationState.signingOut());

      expect(notificationCount, 1);

      expect(
        notifier.authenticationState.status,
        AuthenticationStatus.signingOut,
      );

      expect(notifier.authenticationState.user, isNull);
    });

    test('can transition from signing out to signed out', () {
      final notifier = AuthenticationRouterRefreshNotifier(
        initialState: const AuthenticationState.signingOut(),
      );

      addTearDown(notifier.dispose);

      var notificationCount = 0;

      notifier.addListener(() {
        notificationCount++;
      });

      notifier.update(const AuthenticationState.signedOut());

      expect(notificationCount, 1);

      expect(
        notifier.authenticationState,
        const AuthenticationState.signedOut(),
      );
    });
  });
}
