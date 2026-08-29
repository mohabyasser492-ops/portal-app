import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_loading_state.dart';
import '../application/authentication_controller.dart';
import '../domain/authentication_status.dart';
import 'signed_out_page.dart';

/// Displays application content according to the current authentication state.
///
/// The gate performs the initial session restoration check when mounted.
///
/// State behavior:
///
/// - initializing: displays a session-loading state
/// - signedOut: displays the sign-in page
/// - signingIn: displays the sign-in page in loading mode
/// - signedIn: displays [authenticatedChild]
/// - signingOut: displays a sign-out loading state
/// - failure: displays a recoverable authentication error
class AuthenticationGate extends ConsumerStatefulWidget {
  const AuthenticationGate({
    required this.authenticatedChild,
    this.initializeSession = true,
    super.key,
  });

  /// Application content displayed after successful authentication.
  final Widget authenticatedChild;

  /// Whether the gate should perform the initial session restoration check.
  ///
  /// Tests may disable this when they need to inspect a manually controlled
  /// authentication state.
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
      Future<void>.microtask(_initializeAuthentication);
    }
  }

  Future<void> _initializeAuthentication() async {
    if (!mounted) {
      return;
    }

    await ref.read(authenticationControllerProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationState = ref.watch(authenticationControllerProvider);

    return switch (authenticationState.status) {
      AuthenticationStatus.initializing => const _AuthenticationLoadingPage(
        message: 'Checking your session',
        semanticLabel: 'Checking for an existing authentication session',
      ),
      AuthenticationStatus.signedOut => SignedOutPage(onSignIn: _signIn),
      AuthenticationStatus.signingIn => SignedOutPage(
        isSigningIn: true,
        onSignIn: _signIn,
      ),
      AuthenticationStatus.signedIn => widget.authenticatedChild,
      AuthenticationStatus.signingOut => const _AuthenticationLoadingPage(
        message: 'Signing out',
        semanticLabel: 'Signing out of Portal App',
      ),
      AuthenticationStatus.failure => _AuthenticationFailurePage(
        message:
            authenticationState.errorMessage ??
            'Authentication could not be completed.',
        onRetry: _signIn,
      ),
    };
  }

  Future<void> _signIn() async {
    await ref.read(authenticationControllerProvider.notifier).signIn();
  }
}

/// Full-page authentication loading presentation.
class _AuthenticationLoadingPage extends StatelessWidget {
  const _AuthenticationLoadingPage({
    required this.message,
    required this.semanticLabel,
  });

  final String message;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: PortalLoadingState(
            message: message,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}

/// Full-page recoverable authentication error.
class _AuthenticationFailurePage extends StatelessWidget {
  const _AuthenticationFailurePage({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: PortalErrorState(
              title: 'Authentication failed',
              description: message,
              retryLabel: 'Try again',
              onRetry: onRetry,
              semanticLabel: 'Authentication failed. $message',
            ),
          ),
        ),
      ),
    );
  }
}
