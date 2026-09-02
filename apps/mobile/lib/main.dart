import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/portal_app.dart';
import 'features/authentication/application/authentication_providers.dart';
import 'features/authentication/data/development_authentication_repository.dart';
import 'features/home/application/home_providers.dart';
import 'features/home/data/fake_home_repository.dart';
import 'features/profile/application/profile_providers.dart';
import 'features/profile/data/fake_profile_repository.dart';
import 'features/services/application/services_catalog_providers.dart';
import 'features/services/data/fake_services_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authenticationRepository = DevelopmentAuthenticationRepository();

  final homeRepository = FakeHomeRepository();
  final servicesRepository = FakeServicesRepository();

  runApp(
    ProviderScope(
      overrides: [
        authenticationRepositoryProvider.overrideWithValue(
          authenticationRepository,
        ),
        homeRepositoryProvider.overrideWithValue(homeRepository),
        profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
      ],
      child: const PortalApp(),
    ),
  );
}
