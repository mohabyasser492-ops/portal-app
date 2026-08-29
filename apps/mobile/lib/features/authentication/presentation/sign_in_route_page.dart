import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/feedback/portal_error_state.dart';
import '../application/authentication_controller.dart';
import '../domain/authentication_status.dart';
import 'authentication_loading_page.dart';
import 'signed_out_page.dart';

/// Public sign-in route displayed by GoRouter.
class SignInRoutePage extends ConsumerWidget {
  const SignInRoutePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticationState = ref.watch(authenticationControllerProvider);

    return switch (authenticationState.status) {
      AuthenticationStatus.initializing => const AuthenticationLoadingPage(),
      AuthenticationStatus.signedOut => SignedOutPage(
        onSignIn: () {
          _signIn(ref);
        },
      ),
      AuthenticationStatus.signingIn => SignedOutPage(
        isSigningIn: true,
        onSignIn: () {
          _signIn(ref);
        },
      ),
      AuthenticationStatus.signedIn => const AuthenticationLoadingPage(
        message: 'Opening Portal App',
        semanticLabel: 'Authentication completed. Opening Portal App.',
      ),
      AuthenticationStatus.signingOut => const AuthenticationLoadingPage(
        message: 'Signing out',
        semanticLabel: 'Signing out of Portal App',
      ),
      AuthenticationStatus.failure => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: PortalErrorState(
                title: 'Authentication unavailable',
                description:
                    authenticationState.errorMessage ?? 'Authentication could not be completed.',
                retryLabel: 'Try again',
                onRetry: () {
                  _signIn(ref);
                },
                secondaryActionLabel: 'Back to sign in',
                onSecondaryAction: () {
                  ref.read(authenticationControllerProvider.notifier).clearFailure();
                },
                semanticLabel:
                    'Authentication unavailable. '
                    '${authenticationState.errorMessage ?? 'Authentication could not be completed.'}',
              ),
            ),
          ),
        ),
      ),
    };
  }

  void _signIn(WidgetRef ref) {
    ref.read(authenticationControllerProvider.notifier).signIn();
  }
}
