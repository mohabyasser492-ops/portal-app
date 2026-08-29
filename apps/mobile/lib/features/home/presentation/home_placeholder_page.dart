import 'package:flutter/material.dart';

import '../../../app/router/portal_route_paths.dart';
import '../../../core/widgets/navigation/portal_destination_placeholder.dart';

/// Temporary destination displayed for the Home navigation branch.
class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalDestinationPlaceholder(
      title: 'Home',
      description:
          'The employee dashboard and overview will be available here.',
      icon: Icons.home_outlined,
      routePath: PortalRoutePaths.home,
    );
  }
}
