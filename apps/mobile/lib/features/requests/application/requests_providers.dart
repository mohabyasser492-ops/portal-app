import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/requests_repository.dart';

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) {
  throw UnimplementedError(
    'requestsRepositoryProvider must be overridden before Requests are loaded.',
  );
});
