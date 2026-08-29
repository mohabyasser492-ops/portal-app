import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';

void main() {
  group('PortalUser', () {
    test('stores identity information', () {
      const user = PortalUser(
        id: 'synthetic-user-id',
        displayName: 'Portal Employee',
        email: 'employee@example.invalid',
      );

      expect(user.id, 'synthetic-user-id');
      expect(user.displayName, 'Portal Employee');
      expect(user.email, 'employee@example.invalid');
    });

    test('supports equality for matching values', () {
      const first = PortalUser(
        id: 'synthetic-user-id',
        displayName: 'Portal Employee',
        email: 'employee@example.invalid',
      );

      const second = PortalUser(
        id: 'synthetic-user-id',
        displayName: 'Portal Employee',
        email: 'employee@example.invalid',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('detects different user values', () {
      const first = PortalUser(id: 'first-user', displayName: 'First Employee');

      const second = PortalUser(
        id: 'second-user',
        displayName: 'Second Employee',
      );

      expect(first, isNot(second));
    });

    test('copies user information', () {
      const user = PortalUser(
        id: 'synthetic-user-id',
        displayName: 'Portal Employee',
      );

      final updated = user.copyWith(
        displayName: 'Updated Employee',
        email: 'updated@example.invalid',
      );

      expect(updated.id, user.id);
      expect(updated.displayName, 'Updated Employee');
      expect(updated.email, 'updated@example.invalid');
    });

    test('can clear an email address', () {
      const user = PortalUser(
        id: 'synthetic-user-id',
        displayName: 'Portal Employee',
        email: 'employee@example.invalid',
      );

      final updated = user.copyWith(clearEmail: true);

      expect(updated.email, isNull);
    });
  });
}
