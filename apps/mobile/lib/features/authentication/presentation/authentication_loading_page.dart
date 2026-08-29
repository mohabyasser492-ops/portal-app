import 'package:flutter/material.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_loading_state.dart';

/// Displays a full-page authentication loading state.
class AuthenticationLoadingPage extends StatelessWidget {
  const AuthenticationLoadingPage({
    this.message = 'Checking your session',
    this.semanticLabel = 'Checking for an existing authentication session',
    super.key,
  });

  /// User-facing loading message.
  final String message;

  /// Loading announcement exposed to assistive technologies.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: PortalLoadingState(
            message: message,
            semanticLabel: semanticLabel,
            padding: const EdgeInsetsDirectional.all(PortalSpacing.lg),
          ),
        ),
      ),
    );
  }
}
