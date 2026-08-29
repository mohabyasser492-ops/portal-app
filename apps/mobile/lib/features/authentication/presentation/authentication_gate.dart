import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_loading_state.dart';
import '../application/authentication_controller.dart';
import '../domain/authentication_status.dart';
import 'signed_out_page.dart';

/// Displays application content according to the authentication state.
///
/// The initial session restoration check is performed after the first frame,
/// ensuring that Riverpod is fully available before the controller is read.
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
  /// Tests may disable initialization when manually controlling provider state.
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
        onDismiss: _clearFailure,
      ),
    };
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
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: PortalErrorState(
              title: 'Authentication unavailable',
              description: message,
              retryLabel: 'Try again',
              onRetry: onRetry,
              secondaryActionLabel: 'Back to sign in',
              onSecondaryAction: onDismiss,
              semanticLabel: 'Authentication unavailable. $message',
            ),
          ),
        ),
      ),
    );
  }
}
