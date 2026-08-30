import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/profile/application/profile_providers.dart';
import 'package:portal_app/features/profile/application/profile_state.dart';
import 'package:portal_app/features/profile/application/profile_status.dart';
import 'package:portal_app/features/profile/data/fake_profile_repository.dart';

void main() {
  group('ProfileController', () {
    ProviderContainer makeContainer({required FakeProfileScenario scenario}) {
      final repository = FakeProfileRepository(
        scenario: scenario,
        operationDelay: Duration.zero,
      );

      return ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
        ],
      );
    }

    test('initializes with initial state', () {
      final container = makeContainer(scenario: FakeProfileScenario.populated);
      final state = container.read(profileControllerProvider);

      expect(state, const ProfileState.initial());
    });

    test('loads profile successfully', () async {
      final container = makeContainer(scenario: FakeProfileScenario.populated);
      final controller = container.read(profileControllerProvider.notifier);

      await controller.loadProfile();

      final state = container.read(profileControllerProvider);

      expect(state.status, ProfileStatus.success);
      expect(state.profile, isNotNull);
      expect(state.profile?.displayName, 'Portal Employee');
    });

    test('handles profile loading failure', () async {
      final container = makeContainer(scenario: FakeProfileScenario.failure);
      final controller = container.read(profileControllerProvider.notifier);

      await controller.loadProfile();

      final state = container.read(profileControllerProvider);

      expect(state.status, ProfileStatus.failure);
      expect(state.profile, isNull);
      expect(state.errorMessage, isNotNull);
    });
  });
}
