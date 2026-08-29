import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/app/theme/portal_design_system.dart';
import 'package:portal_app/features/authentication/presentation/signed_out_page.dart';

void main() {
  group('SignedOutPage', () {
    testWidgets('renders the sign-in content', (tester) async {
      await tester.pumpWidget(_buildTestApp(SignedOutPage(onSignIn: () {})));

      expect(find.text('Welcome to Portal App'), findsOneWidget);

      expect(find.text('Sign in with Microsoft'), findsOneWidget);

      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);

      expect(find.byIcon(Icons.login_outlined), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('calls the sign-in callback', (tester) async {
      var signInCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          SignedOutPage(
            onSignIn: () {
              signInCount++;
            },
          ),
        ),
      );

      await tester.tap(find.text('Sign in with Microsoft'));

      await tester.pump();

      expect(signInCount, 1);
    });

    testWidgets('renders the signing-in state', (tester) async {
      var signInCount = 0;

      await tester.pumpWidget(
        _buildTestApp(
          SignedOutPage(
            isSigningIn: true,
            onSignIn: () {
              signInCount++;
            },
          ),
        ),
      );

      expect(find.text('Signing in'), findsNothing);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      expect(find.byIcon(Icons.login_outlined), findsNothing);

      expect(signInCount, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow with increased text scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          SignedOutPage(onSignIn: () {}),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders correctly in Arabic RTL', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          SignedOutPage(onSignIn: () {}),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.byType(SignedOutPage), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildTestApp(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    theme: PortalTheme.light,
    home: MediaQuery(
      data: MediaQueryData(size: const Size(390, 844), textScaler: textScaler),
      child: Directionality(textDirection: textDirection, child: child),
    ),
  );
}
