import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/core/auth/auth_session.dart';
import 'package:portal_app/core/auth/auth_session_controller.dart';
import 'package:portal_app/core/auth/authenticated_user.dart';

import '../helpers/fake_auth_service.dart';

void main() {
  const user = AuthenticatedUser(
    accountId: 'synthetic-account',
    displayName: 'Test Employee',
    username: 'employee@example.test',
    tenantId: 'synthetic-tenant',
  );

  AuthSession createActiveSession() {
    return AuthSession(
      accessToken: 'synthetic-token',
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 30)),
      user: user,
    );
  }

  test('restores an active session during initialization', () async {
    final service = FakeAuthService()..session = createActiveSession();

    final controller = AuthSessionController(service);

    await controller.initialize();

    expect(service.initialized, isTrue);
    expect(controller.status, AuthStatus.authenticated);
    expect(controller.session, isNotNull);
  });

  test('becomes unauthenticated when no session exists', () async {
    final service = FakeAuthService();
    final controller = AuthSessionController(service);

    await controller.initialize();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.session, isNull);
  });

  test('stores a session after sign-in', () async {
    final service = FakeAuthService()..session = createActiveSession();

    final controller = AuthSessionController(service);

    await controller.signIn();

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.session, isNotNull);
  });

  test('clears the session during sign-out', () async {
    final service = FakeAuthService()..session = createActiveSession();

    final controller = AuthSessionController(service);

    await controller.signIn();
    await controller.signOut();

    expect(service.signedOut, isTrue);
    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.session, isNull);
  });
}
