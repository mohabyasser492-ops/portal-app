import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/authentication/application/authentication_controller.dart';
import 'package:portal_app/features/authentication/application/authentication_providers.dart';
import 'package:portal_app/features/authentication/application/authentication_state.dart';
import 'package:portal_app/features/authentication/domain/authentication_status.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';

import 'fake_authentication_repository.dart';

void main() {
  const authenticatedUser = PortalUser(
    id: 'synthetic-user-id',
    displayName: 'Portal Employee',
    email: 'employee@example.invalid',
  );

  group('AuthenticationController', () {
    test('starts in the initializing state', () {
      final repository = FakeAuthenticationRepository();
      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final state = container.read(authenticationControllerProvider);

      expect(state, const AuthenticationState.initializing());

      expect(repository.restoreSessionCallCount, 0);
    });

    test('becomes signed out when no session can be restored', () async {
      final repository = FakeAuthenticationRepository(restoredUser: null);

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.initialize();

      final state = container.read(authenticationControllerProvider);

      expect(state, const AuthenticationState.signedOut());

      expect(repository.restoreSessionCallCount, 1);
    });

    test('restores an authenticated session', () async {
      final repository = FakeAuthenticationRepository(restoredUser: authenticatedUser);

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.initialize();

      final state = container.read(authenticationControllerProvider);

      expect(state, const AuthenticationState.signedIn(authenticatedUser));

      expect(state.isAuthenticated, isTrue);

      expect(repository.restoreSessionCallCount, 1);
    });

    test('reports a session restoration failure', () async {
      final repository = FakeAuthenticationRepository(
        restoreSessionError: Exception('Synthetic restoration failure'),
      );

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.initialize();

      final state = container.read(authenticationControllerProvider);

      expect(state.status, AuthenticationStatus.failure);

      expect(state.errorMessage, 'Unable to restore the authentication session.');

      expect(state.hasFailure, isTrue);

      expect(repository.restoreSessionCallCount, 1);
    });

    test('does not initialize more than once', () async {
      final repository = FakeAuthenticationRepository();

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.initialize();
      await controller.initialize();

      expect(repository.restoreSessionCallCount, 1);

      expect(
        container.read(authenticationControllerProvider),
        const AuthenticationState.signedOut(),
      );
    });

    test('signs in successfully', () async {
      final repository = FakeAuthenticationRepository(signedInUser: authenticatedUser);

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.signIn();

      final state = container.read(authenticationControllerProvider);

      expect(state, const AuthenticationState.signedIn(authenticatedUser));

      expect(state.isAuthenticated, isTrue);

      expect(repository.signInCallCount, 1);
    });

    test('reports an interactive sign-in failure', () async {
      final repository = FakeAuthenticationRepository(
        signInError: Exception('Synthetic sign-in failure'),
      );

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.signIn();

      final state = container.read(authenticationControllerProvider);

      expect(state.status, AuthenticationStatus.failure);

      expect(state.errorMessage, 'Unable to sign in. Please try again.');

      expect(repository.signInCallCount, 1);
    });

    test('signs out an authenticated user', () async {
      final repository = FakeAuthenticationRepository(signedInUser: authenticatedUser);

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.signIn();

      expect(container.read(authenticationControllerProvider).isAuthenticated, isTrue);

      await controller.signOut();

      expect(
        container.read(authenticationControllerProvider),
        const AuthenticationState.signedOut(),
      );

      expect(repository.signOutCallCount, 1);
    });

    test('does not sign out when no user is authenticated', () async {
      final repository = FakeAuthenticationRepository();

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.signOut();

      expect(repository.signOutCallCount, 0);

      expect(
        container.read(authenticationControllerProvider),
        const AuthenticationState.initializing(),
      );
    });

    test('reports a sign-out failure', () async {
      final repository = FakeAuthenticationRepository(
        signedInUser: authenticatedUser,
        signOutError: Exception('Synthetic sign-out failure'),
      );

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.signIn();
      await controller.signOut();

      final state = container.read(authenticationControllerProvider);

      expect(state.status, AuthenticationStatus.failure);

      expect(state.errorMessage, 'Unable to sign out. Please try again.');

      expect(repository.signOutCallCount, 1);
    });

    test('clears an authentication failure', () async {
      final repository = FakeAuthenticationRepository(
        signInError: Exception('Synthetic sign-in failure'),
      );

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      await controller.signIn();

      expect(container.read(authenticationControllerProvider).hasFailure, isTrue);

      controller.clearFailure();

      expect(
        container.read(authenticationControllerProvider),
        const AuthenticationState.signedOut(),
      );
    });

    test('ignores clearFailure outside the failure state', () {
      final repository = FakeAuthenticationRepository();

      final container = _createContainer(repository);

      addTearDown(container.dispose);

      final controller = container.read(authenticationControllerProvider.notifier);

      controller.clearFailure();

      expect(
        container.read(authenticationControllerProvider),
        const AuthenticationState.initializing(),
      );
    });
  });
}

ProviderContainer _createContainer(FakeAuthenticationRepository repository) {
  final container = ProviderContainer(
    overrides: [authenticationRepositoryProvider.overrideWithValue(repository)],
  );

  addTearDown(container.dispose);

  return container;
}
