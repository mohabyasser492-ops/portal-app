import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_skeleton.dart';

import '../application/profile_providers.dart';

import '../application/profile_status.dart';
import '../domain/employee_profile.dart';

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
      if (!mounted) return;
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(profileControllerProvider.notifier).loadProfile(),
        child: switch (state.status) {
          ProfileStatus.initial || ProfileStatus.loading => const _ProfileLoadingView(),
          ProfileStatus.success => _ProfileContent(profile: state.profile!),
          ProfileStatus.failure => _ProfileFailureView(
            message: state.errorMessage ?? 'Unable to load profile information.',
            onRetry: () => ref.read(profileControllerProvider.notifier).loadProfile(),
          ),
        },
      ),
    );
  }
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('profile-loading'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(PortalSpacing.md),
      children: const [
        PortalSkeleton(width: double.infinity, height: 260, animate: false),
        SizedBox(height: PortalSpacing.lg),
        PortalSkeleton(width: double.infinity, height: 160, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalSkeleton(width: double.infinity, height: 210, animate: false),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('profile-data'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(
        PortalSpacing.md,
        PortalSpacing.md,
        PortalSpacing.md,
        PortalSpacing.xl,
      ),
      children: [
        _ProfileHero(profile: profile),
        const SizedBox(height: PortalSpacing.xl),
        const _SectionHeading(
          title: 'المعلومات الشخصية',
          subtitle: 'بيانات التواصل الأساسية',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: PortalSpacing.sm),
        _SurfaceCard(
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'البريد الإلكتروني',
                value: profile.email,
              ),
              const Divider(height: 1),
              _InfoRow(icon: Icons.phone_outlined, label: 'رقم الهاتف', value: profile.mobilePhone),
            ],
          ),
        ),
        const SizedBox(height: PortalSpacing.xl),
        const _SectionHeading(
          title: 'بيانات الوظيفة',
          subtitle: 'المعلومات التنظيمية والوظيفية',
          icon: Icons.business_center_outlined,
        ),
        const SizedBox(height: PortalSpacing.sm),
        _EmploymentGrid(profile: profile),
        const SizedBox(height: PortalSpacing.xl),
        _SurfaceCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PortalColors.statusSuccessSurface,
                  borderRadius: BorderRadius.circular(PortalRadius.md),
                ),
                child: const Icon(Icons.verified_user_outlined, color: PortalColors.statusSuccess),
              ),
              const SizedBox(width: PortalSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحساب الوظيفي نشط', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: PortalSpacing.xs),
                    Text(
                      'الملف مرتبط بالمعرّف الوظيفي ${profile.employeeId}.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: PortalColors.statusSuccess),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PortalSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [PortalColors.brand800, PortalColors.brand600],
        ),
        borderRadius: BorderRadius.circular(PortalRadius.xl),
        boxShadow: const [
          BoxShadow(color: PortalColors.shadow, blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PortalColors.neutral0,
              border: Border.all(color: PortalColors.neutral0.withValues(alpha: 0.35), width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(profile.displayName),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: PortalColors.brand800,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: PortalSpacing.md),
          Text(
            profile.displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: PortalColors.neutral0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: PortalSpacing.xs),
          Text(
            profile.jobTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: PortalColors.neutral0.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: PortalSpacing.xs),
          Text(
            profile.department,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: PortalColors.neutral0.withValues(alpha: 0.82)),
          ),
          const SizedBox(height: PortalSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: PortalSpacing.sm,
            runSpacing: PortalSpacing.sm,
            children: [
              _Pill(icon: Icons.badge_outlined, text: profile.employeeId),
              const _Pill(icon: Icons.check_circle_outline, text: 'موظف نشط'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: PortalSpacing.md,
        vertical: PortalSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PortalColors.neutral0.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PortalRadius.full),
        border: Border.all(color: PortalColors.neutral0.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: PortalColors.neutral0, size: 16),
          const SizedBox(width: PortalSpacing.xs),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: PortalColors.neutral0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: PortalColors.brand50,
            borderRadius: BorderRadius.circular(PortalRadius.md),
          ),
          child: Icon(icon, color: PortalColors.brand700),
        ),
        const SizedBox(width: PortalSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: PortalSpacing.xxs),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.lg),
        border: Border.all(color: PortalColors.borderSubtle),
        boxShadow: const [
          BoxShadow(color: PortalColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(PortalSpacing.md),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PortalSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: PortalColors.brand50,
              borderRadius: BorderRadius.circular(PortalRadius.md),
            ),
            child: Icon(icon, color: PortalColors.brand700),
          ),
          const SizedBox(width: PortalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
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

class _EmploymentGrid extends StatelessWidget {
  const _EmploymentGrid({required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('المعرّف الوظيفي', profile.employeeId, Icons.badge_outlined),
      ('القسم', profile.department, Icons.apartment_outlined),
      ('المسمى الوظيفي', profile.jobTitle, Icons.work_outline),
      ('المدير المباشر', profile.managerName, Icons.person_outline),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 620;

        if (!wide) {
          return Column(
            children: items.map((item) {
              final widget = _EmploymentItem(label: item.$1, value: item.$2, icon: item.$3);
              return Padding(
                padding: const EdgeInsetsDirectional.only(bottom: PortalSpacing.sm),
                child: _SurfaceCard(child: widget),
              );
            }).toList(),
          );
        }

        final columnWidth = (constraints.maxWidth - PortalSpacing.sm) / 2;
        return Wrap(
          spacing: PortalSpacing.sm,
          runSpacing: PortalSpacing.sm,
          children: items.map((item) {
            return SizedBox(
              width: columnWidth,
              child: _SurfaceCard(
                child: _EmploymentItem(label: item.$1, value: item.$2, icon: item.$3),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _EmploymentItem extends StatelessWidget {
  const _EmploymentItem({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: PortalColors.iconSecondary),
        const SizedBox(width: PortalSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: PortalSpacing.xs),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileFailureView extends StatelessWidget {
  const _ProfileFailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('profile-failure'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(PortalSpacing.lg),
      children: [
        PortalErrorState(
          title: 'تعذر تحميل الملف الشخصي',
          description: message,
          retryLabel: 'حاول مرة أخرى',
          onRetry: onRetry,
          semanticLabel: 'تعذر تحميل الملف الشخصي. $message',
        ),
      ],
    );
  }
}

String _initials(String name) {
  final value = name.trim();
  if (value.isEmpty) return '';

  final parts = value.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.characters.first.toUpperCase();
  }

  return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
}
