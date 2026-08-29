import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/authentication_status.dart';
import '../domain/authentication_repository.dart';
import 'authentication_providers.dart';
import 'authentication_state.dart';

/// Provides the current authentication state and authentication operations.
final authenticationControllerProvider =
    NotifierProvider<AuthenticationController, AuthenticationState>(AuthenticationController.new);

/// Coordinates authentication state transitions.
///
/// Widgets should call this controller instead of calling an authentication
/// repository or Microsoft authentication library directly.
class AuthenticationController extends Notifier<AuthenticationState> {
  AuthenticationRepository get _repository {
    return ref.read(authenticationRepositoryProvider);
  }

  @override
  AuthenticationState build() {
    return const AuthenticationState.initializing();
  }

  /// Checks whether a valid existing session can be restored.
  Future<void> initialize() async {
    if (state.status != AuthenticationStatus.initializing) {
      return;
    }

    try {
      final user = await _repository.restoreSession();

      if (user == null) {
        state = const AuthenticationState.signedOut();
        return;
      }

      state = AuthenticationState.signedIn(user);
    } catch (_) {
      state = const AuthenticationState.failure('Unable to restore the authentication session.');
    }
  }

  /// Starts an interactive sign-in operation.
  Future<void> signIn() async {
    if (state.status == AuthenticationStatus.signingIn ||
        state.status == AuthenticationStatus.signingOut) {
      return;
    }

    state = const AuthenticationState.signingIn();

    try {
      final user = await _repository.signIn();

      state = AuthenticationState.signedIn(user);
    } catch (_) {
      state = const AuthenticationState.failure('Unable to sign in. Please try again.');
    }
  }

  /// Ends the current authenticated session.
  Future<void> signOut() async {
    if (!state.isAuthenticated || state.status == AuthenticationStatus.signingOut) {
      return;
    }

    state = const AuthenticationState.signingOut();

    try {
      await _repository.signOut();

      state = const AuthenticationState.signedOut();
    } catch (_) {
      state = const AuthenticationState.failure('Unable to sign out. Please try again.');
    }
  }

  /// Clears an authentication error and returns to the signed-out state.
  void clearFailure() {
    if (!state.hasFailure) {
      return;
    }

    state = const AuthenticationState.signedOut();
  }
}
