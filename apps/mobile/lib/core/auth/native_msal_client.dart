import 'package:msal_auth/msal_auth.dart';

import 'auth_config.dart';
import 'auth_exception.dart';
import 'msal_client.dart';

class NativeMsalClient implements MsalClient {
  NativeMsalClient({
    required AuthConfig config,
    this.androidConfigFilePath = 'assets/msal_config.json',
  }) : _config = config;

  final AuthConfig _config;
  final String androidConfigFilePath;

  SingleAccountPca? _application;

  SingleAccountPca get _initializedApplication {
    final application = _application;

    if (application == null) {
      throw const AuthConfigurationException(
        'The native MSAL client has not been initialized.',
      );
    }

    return application;
  }

  @override
  Future<void> initialize() async {
    if (!_config.isConfigured) {
      throw const AuthConfigurationException(
        'Microsoft Entra authentication is not configured.',
      );
    }

    if (_application != null) {
      return;
    }

    try {
      _application = await SingleAccountPca.create(
        clientId: _config.clientId,
        androidConfig: AndroidConfig(
          configFilePath: androidConfigFilePath,
          redirectUri: _config.redirectUri,
        ),
        appleConfig: AppleConfig(
          authority: _config.authority,
          authorityType: AuthorityType.aad,
          broker: Broker.safariBrowser,
          redirectUri: _config.redirectUri,
        ),
      );
    } on MsalException catch (error) {
      throw _mapMsalException(
        error,
        fallbackMessage: 'Microsoft authentication could not be initialized.',
      );
    } catch (error) {
      throw AuthUnavailableException(
        'Microsoft authentication could not be initialized.',
        error,
      );
    }
  }

  @override
  Future<MsalTokenData> acquireTokenInteractively({
    required List<String> scopes,
    required String authority,
  }) async {
    try {
      final result = await _initializedApplication.acquireToken(
        scopes: scopes,
        authority: authority,
        prompt: Prompt.whenRequired,
      );

      return _mapToken(result);
    } on MsalException catch (error) {
      throw _mapMsalException(
        error,
        fallbackMessage: 'Microsoft sign-in could not be completed.',
      );
    } catch (error) {
      throw AuthUnexpectedException(
        'Microsoft sign-in could not be completed.',
        error,
      );
    }
  }

  @override
  Future<MsalTokenData?> acquireTokenSilently({
    required List<String> scopes,
    required String authority,
  }) async {
    try {
      final result = await _initializedApplication.acquireTokenSilent(
        scopes: scopes,
        authority: authority,
      );

      return _mapToken(result);
    } on MsalUiRequiredException catch (error) {
      throw AuthInteractionRequiredException(
        'Interactive Microsoft sign-in is required.',
        error,
      );
    } on MsalNoCurrentAccountException {
      return null;
    } on MsalException catch (error) {
      throw _mapMsalException(
        error,
        fallbackMessage: 'The Microsoft session could not be restored.',
      );
    } catch (error) {
      throw AuthUnexpectedException(
        'The Microsoft session could not be restored.',
        error,
      );
    }
  }

  @override
  Future<bool> hasCurrentAccount() async {
    try {
      await _initializedApplication.currentAccount;
      return true;
    } on MsalNoCurrentAccountException {
      return false;
    } on MsalException catch (error) {
      throw _mapMsalException(
        error,
        fallbackMessage: 'The Microsoft account state could not be checked.',
      );
    } catch (error) {
      throw AuthUnexpectedException(
        'The Microsoft account state could not be checked.',
        error,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _initializedApplication.signOut();
    } on MsalNoCurrentAccountException {
      return;
    } on MsalException catch (error) {
      throw _mapMsalException(
        error,
        fallbackMessage: 'Microsoft sign-out could not be completed.',
      );
    } catch (error) {
      throw AuthUnexpectedException(
        'Microsoft sign-out could not be completed.',
        error,
      );
    }
  }

  MsalTokenData _mapToken(AuthenticationResult result) {
    final account = result.account;

    return MsalTokenData(
      accessToken: result.accessToken,
      expiresAt: result.expiresOn.toUtc(),
      account: MsalAccountData(
        identifier: account.id,
        displayName: account.name?.trim().isNotEmpty == true
            ? account.name!.trim()
            : account.username?.trim() ?? '',
        username: account.username?.trim() ?? '',
        tenantId: result.tenantId?.trim() ?? _config.tenantId,
      ),
    );
  }

  AuthException _mapMsalException(
    MsalException error, {
    required String fallbackMessage,
  }) {
    if (error is MsalUiRequiredException) {
      return AuthInteractionRequiredException(
        'Interactive Microsoft sign-in is required.',
        error,
      );
    }

    if (error is MsalNoCurrentAccountException) {
      return AuthInteractionRequiredException(
        'No signed-in Microsoft account is available.',
        error,
      );
    }

    return AuthUnexpectedException(fallbackMessage, error);
  }
}
