import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services_repository.dart';

/// Provides the active Services repository.
///
/// Application startup currently overrides this provider with a synthetic
/// fake repository. A future API repository can replace that implementation
/// without changing the controller or presentation layer.
final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  throw UnimplementedError(
    'servicesRepositoryProvider must be overridden before '
    'the Services catalog is loaded.',
  );
});
