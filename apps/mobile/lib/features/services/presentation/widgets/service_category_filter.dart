import 'package:flutter/material.dart';

import '../../../../app/theme/portal_design_system.dart';
import '../../domain/service_category.dart';

/// Horizontally scrollable category filter for the Services catalog.
///
/// A null [selectedCategory] represents the "All" filter.
class ServiceCategoryFilter extends StatelessWidget {
  const ServiceCategoryFilter({
    required this.selectedCategory,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  /// Currently selected category.
  ///
  /// A null value means that all categories are selected.
  final ServiceCategory? selectedCategory;

  /// Called when the user selects a category.
  ///
  /// The callback receives null when the "All" filter is selected.
  final ValueChanged<ServiceCategory?> onSelected;

  /// Whether category selection is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Service categories',
      child: SingleChildScrollView(
        key: const ValueKey<String>('service-category-filter'),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: PortalSpacing.xs),
          child: Row(
            children: [
              _CategoryChoiceChip(
                key: const ValueKey<String>('service-category-all'),
                label: 'All',
                icon: Icons.apps_outlined,
                selected: selectedCategory == null,
                enabled: enabled,
                onSelected: () {
                  onSelected(null);
                },
              ),
              ...ServiceCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: PortalSpacing.sm),
                  child: _CategoryChoiceChip(
                    key: ValueKey<String>('service-category-${category.name}'),
                    label: _categoryLabel(category),
                    icon: _categoryIcon(category),
                    selected: selectedCategory == category,
                    enabled: enabled,
                    onSelected: () {
                      onSelected(category);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(ServiceCategory category) {
    return switch (category) {
      ServiceCategory.humanResources => 'Human Resources',
      ServiceCategory.leave => 'Leave',
      ServiceCategory.payroll => 'Payroll',
      ServiceCategory.documents => 'Documents',
      ServiceCategory.profile => 'Profile',
      ServiceCategory.general => 'General',
    };
  }

  IconData _categoryIcon(ServiceCategory category) {
    return switch (category) {
      ServiceCategory.humanResources => Icons.people_outline,
      ServiceCategory.leave => Icons.event_available_outlined,
      ServiceCategory.payroll => Icons.payments_outlined,
      ServiceCategory.documents => Icons.description_outlined,
      ServiceCategory.profile => Icons.person_outline,
      ServiceCategory.general => Icons.apps_outlined,
    };
  }
}

/// Individual category selection chip.
class _CategoryChoiceChip extends StatelessWidget {
  const _CategoryChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: enabled
          ? (_) {
              onSelected();
            }
          : null,
      avatar: Icon(
        icon,
        size: PortalIconSizes.sm,
        color: selected ? PortalColors.actionPrimary : PortalColors.textSecondary,
      ),
      label: Text(label),
      tooltip: 'Filter by $label',
      showCheckmark: false,
    );
  }
}
