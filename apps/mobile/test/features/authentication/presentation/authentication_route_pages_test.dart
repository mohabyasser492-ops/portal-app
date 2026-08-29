import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/authentication/application/authentication_providers.dart';
import 'package:portal_app/features/authentication/domain/authentication_repository.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';
import 'package:portal_app/features/authentication/presentation/authentication_loading_page.dart';
import 'package:portal_app/features/authentication/presentation/sign_in_route_page.dart';
import 'package:portal_app/features/authentication/presentation/signed_out_page.dart';
import 'package:portal_app/features/authentication/application/authentication_controller.dart';

void main() {
  group('AuthenticationLoadingPage', () {
    testWidgets('displays its default loading message', (tester) async {
      await tester.pumpWidget(
        _buildLoadingTestApp(const AuthenticationLoadingPage()),
      );

      expect(find.byType(AuthenticationLoadingPage), findsOneWidget);

      expect(find.text('Checking your session'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays a custom loading message', (tester) async {
      await tester.pumpWidget(
        _buildLoadingTestApp(
          const AuthenticationLoadingPage(
            message: 'Signing out',
            semanticLabel: 'Signing out of Portal App',
          ),
        ),
      );

      expect(find.text('Signing out'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });

  group('SignInRoutePage', () {
    testWidgets('displays the signed-out presentation', (tester) async {
      final repository = _RouteTestAuthenticationRepository(restoredUser: null);

      await tester.pumpWidget(_buildSignInTestApp(repository));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SignInRoutePage)),
      );

      await container
          .read(authenticationControllerProvider.notifier)
          .initialize();

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(find.text('Sign in with Microsoft'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('signs in after selecting the action', (tester) async {
      final repository = _RouteTestAuthenticationRepository(restoredUser: null);

      await tester.pumpWidget(_buildSignInTestApp(repository));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SignInRoutePage)),
      );

      await container
          .read(authenticationControllerProvider.notifier)
          .initialize();

      await tester.pump();
      await tester.pump();

      expect(find.byType(SignedOutPage), findsOneWidget);

      await tester.tap(find.text('Sign in with Microsoft'));

      await tester.pump();
      await tester.pump();

      expect(repository.signInCallCount, 1);

      expect(
        container.read(authenticationControllerProvider).isAuthenticated,
        isTrue,
      );

      expect(find.byType(AuthenticationLoadingPage), findsOneWidget);

      expect(find.text('Opening Portal App'), findsOneWidget);

      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());

      await tester.pump();
    });

    testWidgets('displays and clears a sign-in failure', (tester) async {
      final repository = _RouteTestAuthenticationRepository(
        restoredUser: null,
        signInError: Exception('Synthetic sign-in failure'),
      );

      await tester.pumpWidget(_buildSignInTestApp(repository));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SignInRoutePage)),
      );

      await container
          .read(authenticationControllerProvider.notifier)
          .initialize();

      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in with Microsoft'));

      await tester.pumpAndSettle();

      expect(find.text('Authentication unavailable'), findsOneWidget);

      expect(find.text('Unable to sign in. Please try again.'), findsOneWidget);

      await tester.tap(find.text('Back to sign in'));

      await tester.pump();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports increased text scaling', (tester) async {
      final repository = _RouteTestAuthenticationRepository(restoredUser: null);

      await tester.pumpWidget(
        _buildSignInTestApp(repository, textScaler: const TextScaler.linear(2)),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SignInRoutePage)),
      );

      await container
          .read(authenticationControllerProvider.notifier)
          .initialize();

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildLoadingTestApp(Widget child) {
  return MaterialApp(theme: PortalTheme.light, home: child);
}

Widget _buildSignInTestApp(
  AuthenticationRepository repository, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [authenticationRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: PortalTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          textScaler: textScaler,
        ),
        child: const SignInRoutePage(),
      ),
    ),
  );
}

final class _RouteTestAuthenticationRepository
    implements AuthenticationRepository {
  _RouteTestAuthenticationRepository({this.restoredUser, this.signInError});

  static const PortalUser _signedInUser = PortalUser(
    id: 'test-user',
    displayName: 'Test Employee',
    email: 'test@example.invalid',
  );

  final PortalUser? restoredUser;
  final Object? signInError;

  int signInCallCount = 0;

  @override
  Future<PortalUser?> restoreSession() async {
    return restoredUser;
  }

  @override
  Future<PortalUser> signIn() async {
    signInCallCount++;

    final error = signInError;

    if (error != null) {
      throw error;
    }

    return _signedInUser;
  }

  @override
  Future<void> signOut() async {}
}
