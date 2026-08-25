import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/core/auth/auth_config.dart';
import 'package:portal_app/core/auth/auth_exception.dart';
import 'package:portal_app/core/auth/msal_auth_service.dart';
import 'package:portal_app/core/auth/msal_client.dart';

import '../helpers/fake_msal_client.dart';

void main() {
  const config = AuthConfig(
    tenantId: 'synthetic-tenant',
    clientId: 'synthetic-client',
    redirectUri: 'synthetic-redirect',
    apiScope: 'api://synthetic/access_as_user',
  );

  MsalTokenData createToken() {
    return MsalTokenData(
      accessToken: 'synthetic-token',
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 30)),
      account: const MsalAccountData(
        identifier: 'synthetic-account',
        displayName: 'Test Employee',
        username: 'employee@example.test',
        tenantId: 'synthetic-tenant',
      ),
    );
  }

  test('rejects incomplete configuration', () async {
    const incompleteConfig = AuthConfig(
      tenantId: '',
      clientId: '',
      redirectUri: '',
      apiScope: '',
    );

    final service = MsalAuthService(
      config: incompleteConfig,
      client: FakeMsalClient(),
    );

    await expectLater(
      service.initialize(),
      throwsA(isA<AuthConfigurationException>()),
    );
  });

  test('initializes the MSAL client', () async {
    final client = FakeMsalClient();

    final service = MsalAuthService(config: config, client: client);

    await service.initialize();

    expect(client.initialized, isTrue);
  });

  test('initialization is idempotent', () async {
    final client = FakeMsalClient();

    final service = MsalAuthService(config: config, client: client);

    await service.initialize();
    await service.initialize();

    expect(client.initialized, isTrue);
  });

  test('maps an interactive token into an auth session', () async {
    final client = FakeMsalClient()..interactiveResult = createToken();

    final service = MsalAuthService(config: config, client: client);

    await service.initialize();

    final session = await service.signIn();

    expect(session.accessToken, 'synthetic-token');
    expect(session.user.accountId, 'synthetic-account');
    expect(session.user.displayName, 'Test Employee');
    expect(session.user.username, 'employee@example.test');
    expect(session.user.tenantId, 'synthetic-tenant');
    expect(session.isExpired, isFalse);
  });

  test('restores a silent session when available', () async {
    final client = FakeMsalClient()..silentResult = createToken();

    final service = MsalAuthService(config: config, client: client);

    await service.initialize();

    final session = await service.acquireTokenSilently();

    expect(session, isNotNull);
    expect(session!.accessToken, 'synthetic-token');
  });

  test('returns null when no silent session exists', () async {
    final service = MsalAuthService(config: config, client: FakeMsalClient());

    await service.initialize();

    final session = await service.acquireTokenSilently();

    expect(session, isNull);
  });

  test('returns null when interaction is required', () async {
    final client = FakeMsalClient()
      ..silentError = const AuthInteractionRequiredException();

    final service = MsalAuthService(config: config, client: client);

    await service.initialize();

    final session = await service.acquireTokenSilently();

    expect(session, isNull);
  });

  test('reports whether an active account exists', () async {
    final client = FakeMsalClient()..currentAccountExists = true;

    final service = MsalAuthService(config: config, client: client);

    await service.initialize();

    expect(await service.hasActiveAccount(), isTrue);
  });

  test('signs out through the MSAL client', () async {
    final client = FakeMsalClient()..currentAccountExists = true;

    final service = MsalAuthService(config: config, client: client);

    await service.initialize();
    await service.signOut();

    expect(client.signedOut, isTrue);
    expect(client.currentAccountExists, isFalse);
  });

  test('requires initialization before sign-in', () async {
    final service = MsalAuthService(config: config, client: FakeMsalClient());

    await expectLater(
      service.signIn(),
      throwsA(isA<AuthConfigurationException>()),
    );
  });

  test('maps unexpected interactive errors', () async {
    final client = FakeMsalClient()
      ..interactiveError = StateError('Synthetic failure');

    final service = MsalAuthService(config: config, client: client);

    await service.initialize();

    await expectLater(
      service.signIn(),
      throwsA(isA<AuthUnexpectedException>()),
    );
  });
}
