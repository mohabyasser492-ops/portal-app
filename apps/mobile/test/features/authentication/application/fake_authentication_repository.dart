import 'package:portal_app/features/authentication/domain/authentication_repository.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';

/// In-memory authentication repository used by tests.
final class FakeAuthenticationRepository implements AuthenticationRepository {
  FakeAuthenticationRepository({
    this.restoredUser,
    this.signedInUser = const PortalUser(
      id: 'synthetic-user-id',
      displayName: 'Portal Employee',
      email: 'employee@example.invalid',
    ),
    this.restoreSessionError,
    this.signInError,
    this.signOutError,
  });

  PortalUser? restoredUser;
  PortalUser signedInUser;

  Object? restoreSessionError;
  Object? signInError;
  Object? signOutError;

  int restoreSessionCallCount = 0;
  int signInCallCount = 0;
  int signOutCallCount = 0;

  @override
  Future<PortalUser?> restoreSession() async {
    restoreSessionCallCount++;

    final error = restoreSessionError;

    if (error != null) {
      throw error;
    }

    return restoredUser;
  }

  @override
  Future<PortalUser> signIn() async {
    signInCallCount++;

    final error = signInError;

    if (error != null) {
      throw error;
    }

    return signedInUser;
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;

    final error = signOutError;

    if (error != null) {
      throw error;
    }
  }
}
