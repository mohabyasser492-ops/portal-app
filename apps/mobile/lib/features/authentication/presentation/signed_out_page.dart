import 'package:flutter/material.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/buttons/portal_button.dart';
import '../../../core/widgets/cards/portal_card.dart';

/// Page displayed when no authenticated Portal App session is available.
class SignedOutPage extends StatelessWidget {
  const SignedOutPage({
    required this.onSignIn,
    this.isSigningIn = false,
    super.key,
  });

  /// Starts the interactive sign-in process.
  final VoidCallback onSignIn;

  /// Whether an interactive sign-in operation is currently running.
  final bool isSigningIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(PortalSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: PortalCard(
                variant: PortalCardVariant.elevated,
                semanticLabel: 'Portal App sign in',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: PortalIconSizes.display,
                        color: PortalColors.actionPrimary,
                      ),
                    ),
                    const SizedBox(height: PortalSpacing.lg),
                    Text(
                      'Welcome to Portal App',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: PortalSpacing.sm),
                    Text(
                      'Sign in with your organization account to access '
                      'employee services, requests, and profile information.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PortalColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: PortalSpacing.xl),
                    PortalButton(
                      label: isSigningIn
                          ? 'Signing in'
                          : 'Sign in with Microsoft',
                      leadingIcon: isSigningIn ? null : Icons.login_outlined,
                      isLoading: isSigningIn,
                      expand: true,
                      semanticLabel: isSigningIn
                          ? 'Signing in with Microsoft'
                          : 'Sign in with Microsoft',
                      onPressed: isSigningIn ? null : onSignIn,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
