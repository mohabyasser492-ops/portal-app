import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/home_repository.dart';

/// Provides the active Home dashboard repository.
///
/// Production startup currently overrides this with [FakeHomeRepository].
/// A backend implementation can replace the fake repository later without
/// changing the controller or presentation layer.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  throw UnimplementedError(
    'homeRepositoryProvider must be overridden before '
    'the Home dashboard is loaded.',
  );
});
