import 'package:flutter/material.dart';

import '../../../app/theme/portal_design_system.dart';

class AmocPageHeader extends StatelessWidget {
  const AmocPageHeader({
    required this.title,
    required this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PortalColors.brand50,
              borderRadius: BorderRadius.circular(PortalRadius.md),
            ),
            child: Icon(icon, color: PortalColors.brand700),
          ),
          const SizedBox(width: PortalSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: PortalSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PortalColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AmocSurfaceCard extends StatelessWidget {
  const AmocSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(PortalSpacing.md),
    this.borderColor = PortalColors.borderSubtle,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surfacePrimary,
        borderRadius: BorderRadius.circular(PortalRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: PortalColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class AmocStatusPill extends StatelessWidget {
  const AmocStatusPill({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: PortalSpacing.sm,
        vertical: PortalSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PortalRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AmocMetricCard extends StatelessWidget {
  const AmocMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.helper,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return AmocSurfaceCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: PortalColors.brand800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (helper != null)
                  Text(
                    helper!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
