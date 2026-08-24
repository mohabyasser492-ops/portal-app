import 'package:portal_app/core/auth/auth_service.dart';
import 'package:portal_app/core/auth/auth_session.dart';

class FakeAuthService implements AuthService {
  AuthSession? session;
  bool initialized = false;
  bool signedOut = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<AuthSession> signIn() async {
    final currentSession = session;

    if (currentSession == null) {
      throw StateError('A synthetic session must be assigned before sign-in.');
    }

    return currentSession;
  }

  @override
  Future<AuthSession?> acquireTokenSilently() async {
    return session;
  }

  @override
  Future<bool> hasActiveAccount() async {
    return session != null;
  }

  @override
  Future<void> signOut() async {
    session = null;
    signedOut = true;
  }
}
