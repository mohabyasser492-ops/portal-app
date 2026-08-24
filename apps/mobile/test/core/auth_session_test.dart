import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/core/auth/auth_session.dart';
import 'package:portal_app/core/auth/authenticated_user.dart';

void main() {
  const user = AuthenticatedUser(
    accountId: 'synthetic-account',
    displayName: 'Test Employee',
    username: 'employee@example.test',
    tenantId: 'synthetic-tenant',
  );

  test('reports a past session as expired', () {
    final session = AuthSession(
      accessToken: 'synthetic-token',
      expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      user: user,
    );

    expect(session.isExpired, isTrue);
  });

  test('reports a future session as active', () {
    final session = AuthSession(
      accessToken: 'synthetic-token',
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 30)),
      user: user,
    );

    expect(session.isExpired, isFalse);
  });
}
