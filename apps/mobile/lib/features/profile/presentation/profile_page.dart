import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_skeleton.dart';
import '../application/profile_controller.dart';
import '../application/profile_providers.dart';
import '../application/profile_state.dart';
import '../application/profile_status.dart';
import '../domain/employee_profile.dart';
import 'widgets/profile_detail_card.dart';

/// Employee Profile page displaying user information and settings.
///
/// The page depends on [ProfileController] and displays the current employee's
/// profile information from the directory.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () {
          return ref.read(profileControllerProvider.notifier).loadProfile();
        },
        child: _buildContent(state),
      ),
    );
  }

  Widget _buildContent(ProfileState state) {
    return switch (state.status) {
      ProfileStatus.initial => const _ProfileLoadingView(),
      ProfileStatus.loading => const _ProfileLoadingView(),
      ProfileStatus.success => _ProfileDataView(profile: state.profile!),
      ProfileStatus.failure => _ProfileFailureView(
        message: state.errorMessage ?? 'Unable to load profile information.',
        onRetry: () {
          ref.read(profileControllerProvider.notifier).loadProfile();
        },
      ),
    };
  }
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('profile-loading'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.lg),
      children: [
        const Center(
          child: PortalSkeleton(
            width: 96,
            height: 96,
            shape: PortalSkeletonShape.circle,
            animate: false,
          ),
        ),
        const SizedBox(height: PortalSpacing.lg),
        const Center(child: PortalSkeleton(width: 200, height: 28, animate: false)),
        const SizedBox(height: PortalSpacing.sm),
        const Center(child: PortalSkeleton(width: 140, height: 16, animate: false)),
        const SizedBox(height: PortalSpacing.xl),
        const PortalSkeleton(width: double.infinity, height: 180, animate: false),
        const SizedBox(height: PortalSpacing.md),
        const PortalSkeleton(width: double.infinity, height: 180, animate: false),
      ],
    );
  }
}

class _ProfileDataView extends StatelessWidget {
  const _ProfileDataView({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('profile-data'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.lg),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: PortalColors.actionPrimary,
            foregroundColor: PortalColors.textOnPrimary,
            child: Text(
              _getInitials(profile.displayName),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: PortalColors.textOnPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: PortalSpacing.lg),
        Center(
          child: Text(
            profile.displayName,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: PortalSpacing.xs),
        Center(
          child: Text(
            profile.jobTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PortalColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: PortalSpacing.xs),
        Center(
          child: Text(
            profile.department,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PortalColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: PortalSpacing.xl),
        ProfileDetailCard(
          title: 'Contact Information',
          icon: Icons.contact_mail_outlined,
          children: [
            ProfileDetailRow(
              label: 'Email Address',
              value: profile.email,
              icon: Icons.email_outlined,
            ),
            ProfileDetailRow(
              label: 'Mobile Phone',
              value: profile.mobilePhone,
              icon: Icons.phone_android_outlined,
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: PortalSpacing.md),
        ProfileDetailCard(
          title: 'Employment Details',
          icon: Icons.badge_outlined,
          children: [
            ProfileDetailRow(
              label: 'Employee ID',
              value: profile.employeeId,
              icon: Icons.tag_outlined,
            ),
            ProfileDetailRow(
              label: 'Manager Name',
              value: profile.managerName,
              icon: Icons.person_outline,
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) {
      return '';
    }

    final parts = name.trim().split(RegExp(r'\s+'));
    
    if (parts.length == 1) {
      return parts[0].characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
  }
}

class _ProfileFailureView extends StatelessWidget {
  const _ProfileFailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('profile-failure'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.lg),
      children: [
        PortalErrorState(
          title: 'Unable to load profile',
          description: message,
          retryLabel: 'Try again',
          onRetry: onRetry,
          semanticLabel: 'Unable to load profile. $message',
        ),
      ],
    );
  }
}
