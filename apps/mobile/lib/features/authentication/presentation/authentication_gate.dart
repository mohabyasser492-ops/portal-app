import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/authentication_controller.dart';
import '../domain/authentication_status.dart';
import 'authentication_failure_page.dart';
import 'authentication_loading_page.dart';
import 'signed_out_page.dart';

/// Displays application content according to the authentication state.
///
/// This component remains available for focused authentication tests and for
/// hosts that want to protect a child widget without using router redirects.
///
/// The main Portal App router may use public authentication routes instead.
class AuthenticationGate extends ConsumerStatefulWidget {
  const AuthenticationGate({
    required this.authenticatedChild,
    this.initializeSession = true,
    super.key,
  });

  /// Application content displayed after authentication succeeds.
  final Widget authenticatedChild;

  /// Whether the gate should perform session restoration after mounting.
  ///
  /// Tests may disable initialization when authentication state is controlled
  /// manually.
  final bool initializeSession;

  @override
  ConsumerState<AuthenticationGate> createState() {
    return _AuthenticationGateState();
  }
}

class _AuthenticationGateState extends ConsumerState<AuthenticationGate> {
  @override
  void initState() {
    super.initState();

    if (widget.initializeSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _initializeAuthentication();
      });
    }
  }

  Future<void> _initializeAuthentication() async {
    await ref.read(authenticationControllerProvider.notifier).initialize();
  }

  Future<void> _signIn() async {
    await ref.read(authenticationControllerProvider.notifier).signIn();
  }

  void _clearFailure() {
    ref.read(authenticationControllerProvider.notifier).clearFailure();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationState = ref.watch(authenticationControllerProvider);

    return switch (authenticationState.status) {
      AuthenticationStatus.initializing => const AuthenticationLoadingPage(
        message: 'Checking your session',
        semanticLabel: 'Checking for an existing authentication session',
      ),
      AuthenticationStatus.signedOut => SignedOutPage(onSignIn: _signIn),
      AuthenticationStatus.signingIn => SignedOutPage(
        isSigningIn: true,
        onSignIn: _signIn,
      ),
      AuthenticationStatus.signedIn => widget.authenticatedChild,
      AuthenticationStatus.signingOut => const AuthenticationLoadingPage(
        message: 'Signing out',
        semanticLabel: 'Signing out of Portal App',
      ),
      AuthenticationStatus.failure => AuthenticationFailurePage(
        message:
            authenticationState.errorMessage ??
            'Authentication could not be completed.',
        onRetry: _signIn,
        onDismiss: _clearFailure,
      ),
    };
  }
}
