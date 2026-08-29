import 'package:flutter/material.dart';

import '../../../app/router/portal_route_paths.dart';
import '../../../core/widgets/navigation/portal_destination_placeholder.dart';

/// Temporary destination displayed for the Services navigation branch.
class ServicesPlaceholderPage extends StatelessWidget {
  const ServicesPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalDestinationPlaceholder(
      title: 'Services',
      description:
          'Employee services and available self-service actions will appear here.',
      icon: Icons.apps_outlined,
      routePath: PortalRoutePaths.services,
    );
  }
}
