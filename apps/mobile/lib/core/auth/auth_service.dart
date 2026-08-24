import 'auth_session.dart';

abstract interface class AuthService {
  Future<void> initialize();

  Future<AuthSession> signIn();

  Future<AuthSession?> acquireTokenSilently();

  Future<bool> hasActiveAccount();

  Future<void> signOut();
}
