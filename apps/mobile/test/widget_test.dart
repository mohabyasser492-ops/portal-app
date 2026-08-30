import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/portal_app.dart';
import 'package:portal_app/features/authentication/application/authentication_providers.dart';
import 'package:portal_app/features/authentication/domain/authentication_repository.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';
import 'package:portal_app/features/home/application/home_providers.dart';
import 'package:portal_app/features/home/data/fake_home_repository.dart';
import 'package:portal_app/features/home/presentation/home_page.dart';

void main() {
  testWidgets('Portal App starts on the Home dashboard', (tester) async {
    final authenticationRepository = _SignedInAuthenticationRepository();

    final homeRepository = FakeHomeRepository(operationDelay: Duration.zero);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticationRepositoryProvider.overrideWithValue(
            authenticationRepository,
          ),
          homeRepositoryProvider.overrideWithValue(homeRepository),
        ],
        child: const PortalApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);

    expect(find.text('Welcome, Portal Employee'), findsOneWidget);

    expect(find.text('Pending requests'), findsOneWidget);

    expect(find.text('Approved requests'), findsOneWidget);

    expect(find.text('Available services'), findsOneWidget);

    expect(homeRepository.loadDashboardCallCount, 1);

    expect(tester.takeException(), isNull);
  });
}

final class _SignedInAuthenticationRepository
    implements AuthenticationRepository {
  static const PortalUser _user = PortalUser(
    id: 'test-user',
    displayName: 'Test Employee',
    email: 'test@example.invalid',
  );

  @override
  Future<PortalUser?> restoreSession() async {
    return _user;
  }

  @override
  Future<PortalUser> signIn() async {
    return _user;
  }

  @override
  Future<void> signOut() async {}
}
