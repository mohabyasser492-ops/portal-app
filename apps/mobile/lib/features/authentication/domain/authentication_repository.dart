import 'portal_user.dart';

/// Defines the authentication operations required by Portal App.
///
/// The presentation and application layers depend on this abstraction rather
/// than directly depending on Microsoft Authentication Library APIs.
abstract interface class AuthenticationRepository {
  /// Restores an existing authenticated session when one is available.
  ///
  /// Returns the authenticated user when a valid session exists.
  /// Returns null when no valid session is available.
  Future<PortalUser?> restoreSession();

  /// Starts an interactive authentication operation.
  ///
  /// Returns the authenticated user after successful sign-in.
  Future<PortalUser> signIn();

  /// Ends the current authenticated session.
  Future<void> signOut();
}
