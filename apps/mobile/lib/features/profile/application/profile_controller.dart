import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_providers.dart';
import 'profile_state.dart';

/// Manages the state and operations for the Employee Profile feature.
class ProfileController extends AutoDisposeNotifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState.initial();
  }

  /// Loads the employee profile.
  ///
  /// Emits [ProfileState.loading] while the operation is in progress.
  Future<void> loadProfile() async {
    state = const ProfileState.loading();

    try {
      final repository = ref.read(profileRepositoryProvider);

      final profile = await repository.loadProfile();

      state = ProfileState.success(profile);
    } on Exception catch (_) {
      state = const ProfileState.failure(
        'Unable to load profile. Please try again later.',
      );
    }
  }
}
