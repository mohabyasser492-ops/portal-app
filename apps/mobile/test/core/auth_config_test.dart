import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/core/auth/auth_config.dart';

void main() {
  test('creates the authority from the tenant ID', () {
    const config = AuthConfig(
      tenantId: 'synthetic-tenant',
      clientId: 'synthetic-client',
      redirectUri: 'synthetic-redirect',
      apiScope: 'api://synthetic/access_as_user',
    );

    expect(
      config.authority,
      'https://login.microsoftonline.com/synthetic-tenant',
    );
  });

  test('returns the configured API scope', () {
    const config = AuthConfig(
      tenantId: 'synthetic-tenant',
      clientId: 'synthetic-client',
      redirectUri: 'synthetic-redirect',
      apiScope: 'api://synthetic/access_as_user',
    );

    expect(config.scopes, ['api://synthetic/access_as_user']);
  });

  test('reports complete configuration as configured', () {
    const config = AuthConfig(
      tenantId: 'synthetic-tenant',
      clientId: 'synthetic-client',
      redirectUri: 'synthetic-redirect',
      apiScope: 'api://synthetic/access_as_user',
    );

    expect(config.isConfigured, isTrue);
  });

  test('reports blank configuration as incomplete', () {
    const config = AuthConfig(
      tenantId: '',
      clientId: '',
      redirectUri: '',
      apiScope: '',
    );

    expect(config.isConfigured, isFalse);
  });
}
