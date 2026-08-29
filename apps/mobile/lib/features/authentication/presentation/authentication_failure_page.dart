import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/portal_error_state.dart';

/// Displays a recoverable authentication failure.
class AuthenticationFailurePage extends StatelessWidget {
  const AuthenticationFailurePage({
    required this.message,
    required this.onRetry,
    required this.onDismiss,
    super.key,
  });

  /// Safe user-facing authentication error message.
  final String message;

  /// Retries interactive authentication.
  final VoidCallback onRetry;

  /// Clears the failure and returns to the signed-out state.
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
