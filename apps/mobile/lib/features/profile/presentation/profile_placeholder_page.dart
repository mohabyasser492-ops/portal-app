import 'package:flutter/material.dart';

import '../../../app/router/portal_route_paths.dart';
import '../../../core/widgets/navigation/portal_destination_placeholder.dart';

/// Temporary destination displayed for the Profile navigation branch.
class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalDestinationPlaceholder(
      title: 'Profile',
      description:
          'Personal, employment, contact, and account information will appear here.',
      icon: Icons.person_outline,
      routePath: PortalRoutePaths.profile,
    );
  }
}
