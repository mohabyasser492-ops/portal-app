import '../../core/auth/auth_config.dart';

class Environment {
  const Environment._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:7047',
  );

  static const entraTenantId = String.fromEnvironment('ENTRA_TENANT_ID');

  static const entraMobileClientId = String.fromEnvironment(
    'ENTRA_MOBILE_CLIENT_ID',
  );

  static const entraRedirectUri = String.fromEnvironment('ENTRA_REDIRECT_URI');

  static const entraApiScope = String.fromEnvironment('ENTRA_API_SCOPE');

  static const authConfig = AuthConfig(
    tenantId: entraTenantId,
    clientId: entraMobileClientId,
    redirectUri: entraRedirectUri,
    apiScope: entraApiScope,
  );
}
