import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/authentication/application/authentication_providers.dart';
import 'package:portal_app/features/authentication/domain/authentication_repository.dart';
import 'package:portal_app/features/authentication/domain/portal_user.dart';
import 'package:portal_app/features/authentication/presentation/authentication_failure_page.dart';
import 'package:portal_app/features/authentication/presentation/authentication_gate.dart';
import 'package:portal_app/features/authentication/presentation/authentication_loading_page.dart';
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
      final sessionCompleter = Completer<PortalUser?>();

      final repository = _ControlledAuthenticationRepository(
        restoreSessionCallback: () {
          return sessionCompleter.future;
        },
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pump();

      expect(find.byType(AuthenticationLoadingPage), findsOneWidget);

      expect(find.text('Checking your session'), findsOneWidget);

      sessionCompleter.complete(null);

      await tester.pump();
      await tester.pump();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays signed-out page when no session exists', (tester) async {
      final repository = FakeAuthenticationRepository(restoredUser: null);

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(find.text('Welcome to Portal App'), findsOneWidget);

      expect(find.text('Sign in with Microsoft'), findsOneWidget);

      expect(repository.restoreSessionCallCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays authenticated content after restoration', (tester) async {
      final repository = FakeAuthenticationRepository(restoredUser: authenticatedUser);

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.text('Authenticated content'), findsOneWidget);

      expect(find.byType(SignedOutPage), findsNothing);

      expect(repository.restoreSessionCallCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('signs in from the signed-out page', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoredUser: null,
        signedInUser: authenticatedUser,
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(find.text('Sign in with Microsoft'), findsOneWidget);

      await tester.tap(find.text('Sign in with Microsoft'));

      await tester.pumpAndSettle();

      expect(repository.signInCallCount, 1);

      expect(find.text('Authenticated content'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays a failure when session restoration fails', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoreSessionError: Exception('Synthetic restoration failure'),
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byType(AuthenticationFailurePage), findsOneWidget);

      expect(find.text('Authentication unavailable'), findsOneWidget);

      expect(find.text('Unable to restore the authentication session.'), findsOneWidget);

      expect(find.text('Try again'), findsOneWidget);

      expect(find.text('Back to sign in'), findsOneWidget);

      expect(repository.restoreSessionCallCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('retries sign in after a restoration failure', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoreSessionError: Exception('Synthetic restoration failure'),
        signedInUser: authenticatedUser,
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byType(AuthenticationFailurePage), findsOneWidget);

      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));

      await tester.pumpAndSettle();

      expect(repository.signInCallCount, 1);

      expect(find.text('Authenticated content'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('returns to sign in after dismissing a failure', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoreSessionError: Exception('Synthetic restoration failure'),
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byType(AuthenticationFailurePage), findsOneWidget);

      await tester.tap(find.text('Back to sign in'));

      await tester.pump();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(find.text('Sign in with Microsoft'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays a failure when interactive sign in fails', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoredUser: null,
        signInError: Exception('Synthetic sign-in failure'),
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      await tester.tap(find.text('Sign in with Microsoft'));

      await tester.pumpAndSettle();

      expect(find.byType(AuthenticationFailurePage), findsOneWidget);

      expect(find.text('Authentication unavailable'), findsOneWidget);

      expect(find.text('Unable to sign in. Please try again.'), findsOneWidget);

      expect(repository.signInCallCount, 1);

      expect(tester.takeException(), isNull);
    });

    testWidgets('retries sign in after an interactive failure', (tester) async {
      final repository = FakeAuthenticationRepository(
        restoredUser: null,
        signInError: Exception('Synthetic sign-in failure'),
        signedInUser: authenticatedUser,
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in with Microsoft'));

      await tester.pumpAndSettle();

      expect(find.byType(AuthenticationFailurePage), findsOneWidget);

      repository.signInError = null;

      await tester.tap(find.text('Try again'));

      await tester.pumpAndSettle();

      expect(repository.signInCallCount, 2);

      expect(find.text('Authenticated content'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('prevents repeated sign-in actions while signing in', (tester) async {
      final signInCompleter = Completer<PortalUser>();

      final repository = _ControlledAuthenticationRepository(
        restoreSessionCallback: () async {
          return null;
        },
        signInCallback: () {
          return signInCompleter.future;
        },
      );

      await tester.pumpWidget(_buildTestApp(repository: repository));

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      await tester.tap(find.text('Sign in with Microsoft'));

      await tester.pump();

      expect(repository.signInCallCount, 1);

      expect(find.byType(SignedOutPage), findsOneWidget);

      signInCompleter.complete(authenticatedUser);

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Authenticated content'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (tester) async {
      final repository = FakeAuthenticationRepository(restoredUser: null);

      await tester.pumpWidget(
        _buildTestApp(repository: repository, textScaler: const TextScaler.linear(2)),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(find.text('Welcome to Portal App'), findsOneWidget);

      expect(find.text('Sign in with Microsoft'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders signed-out content in Arabic RTL', (tester) async {
      final repository = FakeAuthenticationRepository(restoredUser: null);

      await tester.pumpWidget(
        _buildTestApp(repository: repository, textDirection: TextDirection.rtl),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SignedOutPage), findsOneWidget);

      final directionalityFinder = find.ancestor(
        of: find.byType(SignedOutPage),
        matching: find.byType(Directionality),
      );

      expect(directionalityFinder, findsWidgets);

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildTestApp({
  required AuthenticationRepository repository,
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ProviderScope(
    overrides: [authenticationRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: PortalTheme.light,
      home: MediaQuery(
        data: MediaQueryData(size: const Size(390, 844), textScaler: textScaler),
        child: Directionality(
          textDirection: textDirection,
          child: const AuthenticationGate(
            authenticatedChild: Scaffold(body: Center(child: Text('Authenticated content'))),
          ),
        ),
      ),
    ),
  );
}

final class _ControlledAuthenticationRepository implements AuthenticationRepository {
  _ControlledAuthenticationRepository({required this.restoreSessionCallback, this.signInCallback});

  final Future<PortalUser?> Function() restoreSessionCallback;
  final Future<PortalUser> Function()? signInCallback;

  int restoreSessionCallCount = 0;
  int signInCallCount = 0;
  int signOutCallCount = 0;

  @override
  Future<PortalUser?> restoreSession() {
    restoreSessionCallCount++;

    return restoreSessionCallback();
  }

  @override
  Future<PortalUser> signIn() {
    signInCallCount++;

    final callback = signInCallback;

    if (callback == null) {
      return Future<PortalUser>.error(StateError('No sign-in callback was configured.'));
    }

    return callback();
  }

  @override
  Future<void> signOut() {
    signOutCallCount++;

    return Future<void>.value();
  }
}
