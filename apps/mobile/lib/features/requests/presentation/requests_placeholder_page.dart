import 'package:flutter/material.dart';

import '../../../app/router/portal_route_paths.dart';
import '../../../core/widgets/navigation/portal_destination_placeholder.dart';

/// Temporary destination displayed for the Requests navigation branch.
class RequestsPlaceholderPage extends StatelessWidget {
  const RequestsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalDestinationPlaceholder(
      title: 'Requests',
      description:
          'Submitted, pending, approved, and rejected requests will appear here.',
      icon: Icons.description_outlined,
      routePath: PortalRoutePaths.requests,
    );
  }
}
