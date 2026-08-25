import 'auth_service.dart';
import 'auth_session.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthSessionController {
  AuthSessionController(this._authService);

  final AuthService _authService;

  AuthSession? _session;
  AuthStatus _status = AuthStatus.unknown;

  AuthSession? get session => _session;

  AuthStatus get status => _status;

  Future<void> initialize() async {
    await _authService.initialize();

    final restoredSession = await _authService.acquireTokenSilently();

    _setSession(restoredSession);
  }

  Future<AuthSession> signIn() async {
    final newSession = await _authService.signIn();

    _setSession(newSession);

    return newSession;
  }

  Future<AuthSession?> refresh() async {
    final refreshedSession = await _authService.acquireTokenSilently();

    _setSession(refreshedSession);

    return refreshedSession;
  }

  Future<void> signOut() async {
    await _authService.signOut();

    _session = null;
    _status = AuthStatus.unauthenticated;
  }

  void _setSession(AuthSession? value) {
    if (value == null || value.isExpired) {
      _session = null;
      _status = AuthStatus.unauthenticated;
      return;
    }

    _session = value;
    _status = AuthStatus.authenticated;
  }
}
