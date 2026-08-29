import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/authentication/application/authentication_state.dart';
import 'package:portal_app/features/authentication/domain/authentication_status.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';

void main() {
  const user = PortalUser(
    id: 'synthetic-user-id',
    displayName: 'Portal Employee',
    email: 'employee@example.invalid',
  );

  group('AuthenticationState', () {
    test('creates an initializing state', () {
      const state = AuthenticationState.initializing();

      expect(state.status, AuthenticationStatus.initializing);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isTrue);
      expect(state.hasFailure, isFalse);
    });

    test('creates a signed-out state', () {
      const state = AuthenticationState.signedOut();

      expect(state.status, AuthenticationStatus.signedOut);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('creates a signing-in state', () {
      const state = AuthenticationState.signingIn();

      expect(state.status, AuthenticationStatus.signingIn);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isTrue);
      expect(state.hasFailure, isFalse);
    });

    test('creates a signed-in state', () {
      const state = AuthenticationState.signedIn(user);

      expect(state.status, AuthenticationStatus.signedIn);
      expect(state.user, user);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('creates a signing-out state', () {
      const state = AuthenticationState.signingOut();

      expect(state.status, AuthenticationStatus.signingOut);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isTrue);
      expect(state.hasFailure, isFalse);
    });

    test('creates a failure state', () {
      const state = AuthenticationState.failure('Unable to sign in.');

      expect(state.status, AuthenticationStatus.failure);
      expect(state.user, isNull);
      expect(state.errorMessage, 'Unable to sign in.');
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasFailure, isTrue);
    });

    test('supports equality for matching initializing states', () {
      const first = AuthenticationState.initializing();
      const second = AuthenticationState.initializing();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('supports equality for matching signed-out states', () {
      const first = AuthenticationState.signedOut();
      const second = AuthenticationState.signedOut();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('supports equality for matching signed-in states', () {
      const first = AuthenticationState.signedIn(user);
      const second = AuthenticationState.signedIn(user);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('supports equality for matching failure states', () {
      const first = AuthenticationState.failure('Unable to sign in.');
      const second = AuthenticationState.failure('Unable to sign in.');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('detects different authentication statuses', () {
      const signedOut = AuthenticationState.signedOut();
      const signedIn = AuthenticationState.signedIn(user);

      expect(signedOut, isNot(signedIn));
    });

    test('detects different signed-in users', () {
      const firstUser = PortalUser(
        id: 'first-user-id',
        displayName: 'First Employee',
      );

      const secondUser = PortalUser(
        id: 'second-user-id',
        displayName: 'Second Employee',
      );

      const firstState = AuthenticationState.signedIn(firstUser);

      const secondState = AuthenticationState.signedIn(secondUser);

      expect(firstState, isNot(secondState));
    });

    test('detects different failure messages', () {
      const first = AuthenticationState.failure(
        'First authentication failure.',
      );

      const second = AuthenticationState.failure(
        'Second authentication failure.',
      );

      expect(first, isNot(second));
    });

    test('provides a readable string representation', () {
      const state = AuthenticationState.signedIn(user);

      final value = state.toString();

      expect(value, contains('AuthenticationStatus.signedIn'));
      expect(value, contains('synthetic-user-id'));
      expect(value, contains('Portal Employee'));
    });
  });
}
