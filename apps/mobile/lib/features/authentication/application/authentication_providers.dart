import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/authentication_repository.dart';

/// Provides the active authentication repository.
///
/// The production application will override this provider with the future
/// Microsoft authentication repository.
///
/// Tests override it with an in-memory fake repository.
final authenticationRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  throw UnimplementedError(
    'authenticationRepositoryProvider must be overridden '
    'before authentication operations are used.',
  );
});
