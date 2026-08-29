import 'package:flutter/foundation.dart';

import '../domain/authentication_status.dart';
import '../domain/portal_user.dart';

/// Immutable state describing the Portal App authentication session.
@immutable
final class AuthenticationState {
  const AuthenticationState({
    required this.status,
    this.user,
    this.errorMessage,
  }) : assert(
         status == AuthenticationStatus.signedIn || user == null,
         'A user may only be present when status is signedIn.',
       ),
       assert(
         status == AuthenticationStatus.failure || errorMessage == null,
         'An error message may only be present when status is failure.',
       );

  const AuthenticationState.initializing()
    : status = AuthenticationStatus.initializing,
      user = null,
      errorMessage = null;

  const AuthenticationState.signedOut()
    : status = AuthenticationStatus.signedOut,
      user = null,
      errorMessage = null;

  const AuthenticationState.signingIn()
    : status = AuthenticationStatus.signingIn,
      user = null,
      errorMessage = null;

  const AuthenticationState.signedIn(PortalUser authenticatedUser)
    : status = AuthenticationStatus.signedIn,
      user = authenticatedUser,
      errorMessage = null;

  const AuthenticationState.signingOut()
    : status = AuthenticationStatus.signingOut,
      user = null,
      errorMessage = null;

  const AuthenticationState.failure(String message)
    : status = AuthenticationStatus.failure,
      user = null,
      errorMessage = message;

  final AuthenticationStatus status;
  final PortalUser? user;
  final String? errorMessage;

  bool get isAuthenticated {
    return status == AuthenticationStatus.signedIn && user != null;
  }

  bool get isLoading {
    return status == AuthenticationStatus.initializing ||
        status == AuthenticationStatus.signingIn ||
        status == AuthenticationStatus.signingOut;
  }

  bool get hasFailure {
    return status == AuthenticationStatus.failure;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthenticationState &&
            other.status == status &&
            other.user == user &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(status, user, errorMessage);
  }

  @override
  String toString() {
    return 'AuthenticationState('
        'status: $status, '
        'user: $user, '
        'errorMessage: $errorMessage'
        ')';
  }
}
