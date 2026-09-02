import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_skeleton.dart';

import '../application/profile_providers.dart';

import '../application/profile_status.dart';
import '../domain/employee_profile.dart';

/// Premium employee profile screen for Portal App.
///
/// The page intentionally consumes the existing EmployeeProfile domain model
/// and does not introduce backend-specific concerns into presentation.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
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
        child: switch (state.status) {
          ProfileStatus.initial => const _ProfileLoadingView(),
          ProfileStatus.loading => const _ProfileLoadingView(),
          ProfileStatus.success => _ProfileContent(profile: state.profile!),
          ProfileStatus.failure => _ProfileFailureView(
            message: state.errorMessage ?? 'Unable to load profile information.',
            onRetry: () {
              ref.read(profileControllerProvider.notifier).loadProfile();
            },
          ),
        },
      ),
    );
  }
}

/// Loading state designed to closely match the final profile layout.
class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey<String>('profile-loading'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            PortalSpacing.md,
            PortalSpacing.md,
            PortalSpacing.md,
            PortalSpacing.xl,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _ProfileHeaderSkeleton(),
              const SizedBox(height: PortalSpacing.lg),
              const _SectionSkeleton(),
              const SizedBox(height: PortalSpacing.md),
              const _SectionSkeleton(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.xl),
        border: Border.all(color: PortalColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(PortalSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          PortalSkeleton(width: 92, height: 92, shape: PortalSkeletonShape.circle, animate: false),
          SizedBox(height: PortalSpacing.md),
          PortalSkeleton(width: 180, height: 24, animate: false),
          SizedBox(height: PortalSpacing.sm),
          PortalSkeleton(width: 140, height: 18, animate: false),
          SizedBox(height: PortalSpacing.sm),
          PortalSkeleton(width: 200, height: 16, animate: false),
        ],
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175,
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.lg),
        border: Border.all(color: PortalColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(PortalSpacing.lg),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortalSkeleton(width: 160, height: 22, animate: false),
          SizedBox(height: PortalSpacing.lg),
          PortalSkeleton(width: double.infinity, height: 22, animate: false),
          SizedBox(height: PortalSpacing.md),
          PortalSkeleton(width: 240, height: 22, animate: false),
        ],
      ),
    );
  }
}

/// Main profile content.
class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 900 ? PortalSpacing.xl : PortalSpacing.md;

        final contentMaxWidth = constraints.maxWidth >= 1200 ? 1120.0 : double.infinity;

        return CustomScrollView(
          key: const ValueKey<String>('profile-data'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      horizontalPadding,
                      PortalSpacing.md,
                      horizontalPadding,
                      PortalSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHero(profile: profile),
                        const SizedBox(height: PortalSpacing.xl),
                        _SectionTitle(
                          title: 'Personal information',
                          subtitle: 'Your contact information',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: PortalSpacing.sm),
                        _ContactSection(profile: profile),
                        const SizedBox(height: PortalSpacing.xl),
                        _SectionTitle(
                          title: 'Employment',
                          subtitle: 'Your organizational information',
                          icon: Icons.business_center_outlined,
                        ),
                        const SizedBox(height: PortalSpacing.sm),
                        _EmploymentSection(profile: profile),
                        const SizedBox(height: PortalSpacing.xl),
                        _SectionTitle(
                          title: 'Account',
                          subtitle: 'Portal account information',
                          icon: Icons.verified_user_outlined,
                        ),
                        const SizedBox(height: PortalSpacing.sm),
                        _AccountCard(profile: profile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Large profile header.
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(profile.displayName);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [PortalColors.brand800, PortalColors.brand600],
        ),
        borderRadius: BorderRadius.circular(PortalRadius.xl),
        boxShadow: const [
          BoxShadow(color: PortalColors.shadow, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -45,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PortalColors.neutral0.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -75,
            left: -40,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PortalColors.neutral0.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(PortalSpacing.xl),
            child: Column(
              children: [
                _Avatar(
                  initials: initials,
                  size: 96,
                  foregroundColor: PortalColors.brand700,
                  backgroundColor: PortalColors.neutral0,
                  borderColor: PortalColors.neutral0.withValues(alpha: 0.35),
                ),
                const SizedBox(height: PortalSpacing.md),
                Text(
                  profile.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: PortalColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PortalSpacing.xs),
                Text(
                  profile.jobTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PortalColors.neutral0.withValues(alpha: 0.90),
                  ),
                ),
                const SizedBox(height: PortalSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.apartment_outlined,
                      size: PortalIconSizes.sm,
                      color: PortalColors.neutral0,
                    ),
                    const SizedBox(width: PortalSpacing.xs),
                    Flexible(
                      child: Text(
                        profile.department,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PortalColors.neutral0.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PortalSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: PortalSpacing.sm,
                  runSpacing: PortalSpacing.sm,
                  children: [
                    _HeroChip(icon: Icons.badge_outlined, label: profile.employeeId),
                    _HeroChip(icon: Icons.verified_outlined, label: 'Active employee'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular avatar with initials.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.size,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String initials;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(color: foregroundColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PortalColors.neutral0.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PortalRadius.full),
        border: Border.all(color: PortalColors.neutral0.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: PortalSpacing.md,
          vertical: PortalSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: PortalIconSizes.sm, color: PortalColors.neutral0),
            const SizedBox(width: PortalSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: PortalColors.neutral0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: PortalColors.brand50,
            borderRadius: BorderRadius.circular(PortalRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PortalSpacing.sm),
            child: Icon(icon, color: PortalColors.actionPrimary, size: PortalIconSizes.md),
          ),
        ),
        const SizedBox(width: PortalSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: PortalSpacing.xxs),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: PortalColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Contact information section.
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Work email',
            value: profile.email,
            accentColor: PortalColors.actionPrimary,
          ),
          const _CardDivider(),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Mobile phone',
            value: profile.mobilePhone,
            accentColor: PortalColors.statusSuccess,
          ),
        ],
      ),
    );
  }
}

/// Employment details in a responsive grid.
class _EmploymentSection extends StatelessWidget {
  const _EmploymentSection({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 560;

          final items = [
            _EmploymentItem(
              icon: Icons.badge_outlined,
              label: 'Employee ID',
              value: profile.employeeId,
            ),
            _EmploymentItem(
              icon: Icons.apartment_outlined,
              label: 'Department',
              value: profile.department,
            ),
            _EmploymentItem(icon: Icons.work_outline, label: 'Job title', value: profile.jobTitle),
            _EmploymentItem(
              icon: Icons.person_outline,
              label: 'Manager',
              value: profile.managerName,
            ),
          ];

          if (!twoColumns) {
            return Column(
              children: List.generate(items.length, (index) {
                final item = items[index];

                return Column(
                  children: [
                    Padding(padding: const EdgeInsets.all(PortalSpacing.lg), child: item),
                    if (index != items.length - 1) const _CardDivider(),
                  ],
                );
              }),
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(PortalSpacing.lg),
                      child: items[0],
                    ),
                  ),
                  Container(width: 1, height: 86, color: PortalColors.borderSubtle),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(PortalSpacing.lg),
                      child: items[1],
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: PortalColors.borderSubtle),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(PortalSpacing.lg),
                      child: items[2],
                    ),
                  ),
                  Container(width: 1, height: 86, color: PortalColors.borderSubtle),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(PortalSpacing.lg),
                      child: items[3],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmploymentItem extends StatelessWidget {
  const _EmploymentItem({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: PortalColors.surfaceTertiary,
            borderRadius: BorderRadius.circular(PortalRadius.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PortalSpacing.sm),
            child: Icon(icon, size: PortalIconSizes.md, color: PortalColors.iconSecondary),
          ),
        ),
        const SizedBox(width: PortalSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: PortalColors.textSecondary),
              ),
              const SizedBox(height: PortalSpacing.xs),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PortalSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(PortalRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PortalSpacing.sm),
              child: Icon(icon, color: accentColor, size: PortalIconSizes.lg),
            ),
          ),
          const SizedBox(width: PortalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: PortalColors.textSecondary),
                ),
                const SizedBox(height: PortalSpacing.xs),
                SelectableText(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: PortalColors.statusSuccessSurface,
              borderRadius: BorderRadius.circular(PortalRadius.md),
            ),
            child: const Padding(
              padding: EdgeInsets.all(PortalSpacing.sm),
              child: Icon(
                Icons.check_circle_outline,
                color: PortalColors.statusSuccess,
                size: PortalIconSizes.lg,
              ),
            ),
          ),
          const SizedBox(width: PortalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee account active',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: PortalSpacing.xs),
                Text(
                  'Your Portal profile is associated with employee ID '
                  '${profile.employeeId}.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard surface container used by profile sections.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding = const EdgeInsets.all(PortalSpacing.lg)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.lg),
        border: Border.all(color: PortalColors.borderSubtle),
        boxShadow: const [
          BoxShadow(color: PortalColors.shadow, blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: PortalColors.borderSubtle);
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
        const SizedBox(height: PortalSpacing.xl),
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

String _getInitials(String name) {
  final normalized = name.trim();

  if (normalized.isEmpty) {
    return '';
  }

  final parts = normalized.split(RegExp(r'\s+'));

  if (parts.length == 1) {
    return parts.first.characters.first.toUpperCase();
  }

  return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
}
