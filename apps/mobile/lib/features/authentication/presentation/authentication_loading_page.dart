import 'package:flutter/material.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_loading_state.dart';

/// Screen displayed while the application restores an existing session.
class AuthenticationLoadingPage extends StatelessWidget {
  const AuthenticationLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: PortalLoadingState(
            message: 'Checking your session',
            semanticLabel: 'Checking your authentication session',
            padding: EdgeInsetsDirectional.all(PortalSpacing.lg),
          ),
        ),
      ),
    );
  }
}
