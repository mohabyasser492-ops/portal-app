import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/profile_repository.dart';
import 'profile_controller.dart';
import 'profile_state.dart';

/// Provides the active Profile repository.
///
/// Production startup currently overrides this with [FakeProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError(
    'profileRepositoryProvider must be overridden before '
    'the Profile is loaded.',
  );
});

/// Provides access to the [ProfileController] and its active [ProfileState].
final profileControllerProvider =
    NotifierProvider.autoDispose<ProfileController, ProfileState>(
      ProfileController.new,
    );
