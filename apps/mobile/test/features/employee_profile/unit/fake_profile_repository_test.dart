import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/profile/data/fake_profile_repository.dart';

void main() {
  group('FakeProfileRepository', () {
    test('returns populated profile successfully', () async {
      final repository = FakeProfileRepository(operationDelay: Duration.zero);

      final profile = await repository.loadProfile();

      expect(profile.displayName, 'Portal Employee');
      expect(profile.id, 'test-user');
    });

    test('throws ProfileRepositoryException when scenario is failure', () async {
      final repository = FakeProfileRepository(
        scenario: FakeProfileScenario.failure,
        operationDelay: Duration.zero,
      );

      expect(
        () => repository.loadProfile(),
        throwsA(isA<ProfileRepositoryException>()),
      );
    });
  });
}
