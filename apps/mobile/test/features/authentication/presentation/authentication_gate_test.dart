import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/authentication/application/authentication_providers.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';
import 'package:portal_app/features/authentication/presentation/authentication_gate.dart';
import 'package:portal_app/features/authentication/presentation/signed_out_page.dart';

import '../application/fake_authentication_repository.dart';

void main() {
  const authenticatedUser = PortalUser(
    id: 'synthetic-user-id',
    displayName: 'Portal Employee',
    email: 'employee@example.invalid',
  );

  group('AuthenticationGate', () {
    testWidgets('displays loading while checking the session', (tester) async {
      final repository = _PendingAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          child: const AuthenticationGate(authenticatedChild: Text('Authenticated content')),
        ),
      );

      await tester.pump();

      expect(find.text('Checking your session'), findsOneWidget);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays signed-out page when no session exists', (tester) async {
      final repository = FakeAuthenticationRepository(restoredUser: null);

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          child: const AuthenticationGate(authenticatedChild: Text('Authenticated content')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(find.text('Sign in with Microsoft'), findsOneWidget);

      expect(repository.restoreSessionCallCount, 1);
    });

    testWidgets('displays authenticated content after restoration', (tester) async {
      final repository = FakeAuthenticationRepository(restoredUser: authenticatedUser);

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          child: const AuthenticationGate(authenticatedChild: Text('Authenticated content')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Authenticated content'), findsOneWidget);

      expect(find.byType(SignedOutPage), findsNothing);
    });

    testWidgets('signs in from the signed-out page', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoredUser: null,
        signedInUser: authenticatedUser,
      );

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          child: const AuthenticationGate(authenticatedChild: Text('Authenticated content')),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in with Microsoft'));

      await tester.pumpAndSettle();

      expect(repository.signInCallCount, 1);

      expect(find.text('Authenticated content'), findsOneWidget);
    });

    testWidgets('displays an error when session restoration fails', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoreSessionError: Exception('Synthetic restoration failure'),
      );

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          child: const AuthenticationGate(authenticatedChild: Text('Authenticated content')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Authentication failed'), findsOneWidget);

      expect(find.text('Unable to restore the authentication session.'), findsOneWidget);

      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('retries authentication after a failure', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoreSessionError: Exception('Synthetic restoration failure'),
        signedInUser: authenticatedUser,
      );

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          child: const AuthenticationGate(authenticatedChild: Text('Authenticated content')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Authentication failed'), findsOneWidget);

      repository.restoreSessionError = null;

      await tester.tap(find.text('Try again'));

      await tester.pumpAndSettle();

      expect(repository.signInCallCount, 1);

      expect(find.text('Authenticated content'), findsOneWidget);
    });

    testWidgets('can skip automatic initialization', (tester) async {
      final repository = FakeAuthenticationRepository();

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          child: const AuthenticationGate(
            initializeSession: false,
            authenticatedChild: Text('Authenticated content'),
          ),
        ),
      );

      await tester.pump();

      expect(repository.restoreSessionCallCount, 0);

      expect(find.text('Checking your session'), findsOneWidget);
    });

    testWidgets('does not overflow with increased text scaling', (tester) async {
      final repository = FakeAuthenticationRepository(restoredUser: null);

      await tester.pumpWidget(
        _buildTestApp(
          repository: repository,
          textScaler: const TextScaler.linear(2),
          child: const AuthenticationGate(authenticatedChild: Text('Authenticated content')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildTestApp({
  required FakeAuthenticationRepository repository,
  required Widget child,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [authenticationRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: PortalTheme.light,
      home: MediaQuery(
        data: MediaQueryData(size: const Size(390, 844), textScaler: textScaler),
        child: child,
      ),
    ),
  );
}

/// Test repository that never completes session restoration.
///
/// This keeps the gate in its initial loading state.
final class _PendingAuthenticationRepository extends FakeAuthenticationRepository {
  @override
  Future<PortalUser?> restoreSession() {
    restoreSessionCallCount++;

    return Future<PortalUser?>.delayed(const Duration(days: 1));
  }
}
