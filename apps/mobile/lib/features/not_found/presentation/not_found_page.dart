import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/portal_route_paths.dart';
import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/buttons/portal_button.dart';
import '../../../core/widgets/cards/portal_card.dart';

/// Safe fallback page displayed when no application route matches the URL.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({this.requestedLocation, super.key});

  /// The unmatched location requested by the user.
  final String? requestedLocation;

  @override
  Widget build(BuildContext context) {
    final location = requestedLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
          children: [
            PortalCard(
              semanticLabel: 'Page not found',
              child: Column(
                children: [
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.explore_off_outlined,
                      size: PortalIconSizes.display,
                      color: PortalColors.statusError,
                    ),
                  ),
                  const SizedBox(height: PortalSpacing.md),
                  Text(
                    'Page not found',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: PortalSpacing.sm),
                  Text(
                    location == null || location.trim().isEmpty
                        ? 'The requested page is not available.'
                        : 'The requested page "$location" is not available.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PortalColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: PortalSpacing.lg),
                  PortalButton(
                    label: 'Return home',
                    leadingIcon: Icons.home_outlined,
                    onPressed: () {
                      context.go(PortalRoutePaths.home);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
