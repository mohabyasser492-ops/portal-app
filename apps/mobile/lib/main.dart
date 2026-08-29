import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/portal_app.dart';
import 'features/authentication/application/authentication_providers.dart';
import 'features/authentication/data/development_authentication_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authenticationRepository = DevelopmentAuthenticationRepository();

  runApp(
    ProviderScope(
      overrides: [
        authenticationRepositoryProvider.overrideWithValue(
          authenticationRepository,
        ),
      ],
      child: const PortalApp(),
    ),
  );
}
