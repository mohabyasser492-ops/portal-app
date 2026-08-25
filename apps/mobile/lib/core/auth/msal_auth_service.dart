import 'auth_config.dart';
import 'auth_exception.dart';
import 'auth_service.dart';
import 'auth_session.dart';
import 'authenticated_user.dart';
import 'msal_client.dart';

class MsalAuthService implements AuthService {
  MsalAuthService({required AuthConfig config, required MsalClient client})
    : _config = config,
      _client = client;

  final AuthConfig _config;
  final MsalClient _client;

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (!_config.isConfigured) {
      throw const AuthConfigurationException(
        'Microsoft Entra authentication is not configured.',
      );
    }

    if (_initialized) {
      return;
    }

    try {
      await _client.initialize();
      _initialized = true;
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthUnavailableException(
        'Microsoft authentication could not be initialized.',
        error,
      );
    }
  }

  @override
  Future<AuthSession> signIn() async {
    _ensureInitialized();

    try {
      final result = await _client.acquireTokenInteractively(
        scopes: _config.scopes,
        authority: _config.authority,
      );

      return _mapSession(result);
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthUnexpectedException(
        'Microsoft sign-in could not be completed.',
        error,
      );
    }
  }

  @override
  Future<AuthSession?> acquireTokenSilently() async {
    _ensureInitialized();

    try {
      final result = await _client.acquireTokenSilently(
        scopes: _config.scopes,
        authority: _config.authority,
      );

      if (result == null) {
        return null;
      }

      return _mapSession(result);
    } on AuthInteractionRequiredException {
      return null;
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthUnexpectedException(
        'The Microsoft session could not be restored.',
        error,
      );
    }
  }

  @override
  Future<bool> hasActiveAccount() async {
    _ensureInitialized();

    try {
      return await _client.hasCurrentAccount();
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthUnexpectedException(
        'The Microsoft account state could not be checked.',
        error,
      );
    }
  }

  @override
  Future<void> signOut() async {
    _ensureInitialized();

    try {
      await _client.signOut();
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthUnexpectedException(
        'Microsoft sign-out could not be completed.',
        error,
      );
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw const AuthConfigurationException(
        'The authentication service has not been initialized.',
      );
    }
  }

  AuthSession _mapSession(MsalTokenData result) {
    return AuthSession(
      accessToken: result.accessToken,
      expiresAt: result.expiresAt,
      user: AuthenticatedUser(
        accountId: result.account.identifier,
        displayName: result.account.displayName,
        username: result.account.username,
        tenantId: result.account.tenantId,
      ),
    );
  }
}
