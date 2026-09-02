import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_empty_state.dart';
import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_skeleton.dart';
import '../application/services_catalog_controller.dart';
import '../application/services_catalog_state.dart';
import '../application/services_catalog_status.dart';
import '../domain/portal_service.dart';
import '../domain/service_category.dart';
import '../../requests/domain/request_type.dart';
import 'widgets/service_card.dart';
import 'widgets/service_category_filter.dart';
import 'widgets/services_search_field.dart';

/// Displays the Portal Services catalog.
///
/// The page uses frontend domain models and the Services catalog controller.
/// Backend endpoints, DTOs, and JSON structures remain outside the
/// presentation layer.
class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState<ServicesPage> createState() {
    return _ServicesPageState();
  }
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.read(servicesCatalogControllerProvider.notifier).loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesCatalogControllerProvider);

    return SafeArea(
      child: switch (state.status) {
        ServicesCatalogStatus.initial => const _ServicesLoadingView(),
        ServicesCatalogStatus.loading => const _ServicesLoadingView(),
        ServicesCatalogStatus.success => _ServicesCatalogView(
          state: state,
          onRefresh: _refresh,
          onSearchChanged: _updateSearchQuery,
          onCategorySelected: _selectCategory,
          onClearFilters: _clearFilters,
        ),
        ServicesCatalogStatus.empty => _ServicesEmptyView(onRefresh: _retry),
        ServicesCatalogStatus.failure => _ServicesFailureView(
          message: state.errorMessage ?? 'Unable to load services.',
          onRetry: _retry,
        ),
      },
    );
  }

  Future<void> _refresh() {
    return ref.read(servicesCatalogControllerProvider.notifier).loadServices();
  }

  void _updateSearchQuery(String query) {
    ref.read(servicesCatalogControllerProvider.notifier).updateSearchQuery(query);
  }

  void _selectCategory(ServiceCategory? category) {
    ref.read(servicesCatalogControllerProvider.notifier).selectCategory(category);
  }

  void _clearFilters() {
    ref.read(servicesCatalogControllerProvider.notifier).clearFilters();
  }

  void _retry() {
    ref.read(servicesCatalogControllerProvider.notifier).retry();
  }
}

/// Loading presentation displayed while services are requested.
class _ServicesLoadingView extends StatelessWidget {
  const _ServicesLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('services-loading'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
      children: const [
        PortalSkeleton(width: 180, height: 30, animate: false),
        SizedBox(height: PortalSpacing.sm),
        PortalSkeleton(width: 300, height: 18, animate: false),
        SizedBox(height: PortalSpacing.xl),
        PortalSkeleton(width: double.infinity, height: 56, animate: false),
        SizedBox(height: PortalSpacing.md),
        PortalSkeleton(width: double.infinity, height: 44, animate: false),
        SizedBox(height: PortalSpacing.xl),
        _ServicesLoadingGrid(),
      ],
    );
  }
}

/// Responsive loading placeholders for the Services catalog.
class _ServicesLoadingGrid extends StatelessWidget {
  const _ServicesLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _servicesColumnCount(constraints.maxWidth);

        final cardWidth = _servicesCardWidth(
          availableWidth: constraints.maxWidth,
          columnCount: columnCount,
        );

        return Wrap(
          spacing: PortalSpacing.md,
          runSpacing: PortalSpacing.md,
          children: List<Widget>.generate(6, (index) {
            return SizedBox(
              width: cardWidth,
              child: const PortalSkeleton(width: double.infinity, height: 190, animate: false),
            );
          }),
        );
      },
    );
  }
}

/// Populated Services catalog presentation.
class _ServicesCatalogView extends StatelessWidget {
  const _ServicesCatalogView({
    required this.state,
    required this.onRefresh,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onClearFilters,
  });

  final ServicesCatalogState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ServiceCategory?> onCategorySelected;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const ValueKey<String>('services-catalog'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
        children: [
          Text('Services', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: PortalSpacing.sm),
          Text(
            'Browse services available through Portal App.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
          ),
          const SizedBox(height: PortalSpacing.xl),
          ServicesSearchField(query: state.searchQuery, onChanged: onSearchChanged),
          const SizedBox(height: PortalSpacing.md),
          ServiceCategoryFilter(
            selectedCategory: state.selectedCategory,
            onSelected: onCategorySelected,
          ),
          const SizedBox(height: PortalSpacing.xl),
          _ServicesResultSummary(
            visibleCount: state.visibleServices.length,
            totalCount: state.services.length,
            hasActiveFilters: state.hasActiveFilters,
          ),
          const SizedBox(height: PortalSpacing.md),
          if (state.hasNoMatchingServices)
            _NoMatchingServicesView(onClearFilters: onClearFilters)
          else
            _ServicesGrid(
              services: state.visibleServices,
              onServiceSelected: (service) {
                context.push('/requests/create', extra: _requestTypeForService(service));
              },
            ),
        ],
      ),
    );
  }
}

/// Text summary of the currently visible service results.
class _ServicesResultSummary extends StatelessWidget {
  const _ServicesResultSummary({
    required this.visibleCount,
    required this.totalCount,
    required this.hasActiveFilters,
  });

  final int visibleCount;
  final int totalCount;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final message = hasActiveFilters
        ? '$visibleCount of $totalCount services'
        : '$totalCount services';

    return Semantics(
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Text(
          message,
          key: const ValueKey<String>('services-result-summary'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

/// Responsive collection of visible service cards.
class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.services, required this.onServiceSelected});

  final List<PortalService> services;
  final ValueChanged<PortalService> onServiceSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _servicesColumnCount(constraints.maxWidth);

        final cardWidth = _servicesCardWidth(
          availableWidth: constraints.maxWidth,
          columnCount: columnCount,
        );

        return Wrap(
          key: const ValueKey<String>('services-grid'),
          spacing: PortalSpacing.md,
          runSpacing: PortalSpacing.md,
          children: services
              .map((service) {
                return SizedBox(
                  key: ValueKey<String>('service-card-${service.id}'),
                  width: cardWidth,
                  child: ServiceCard(service: service, onTap: () => onServiceSelected(service)),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

/// Presentation displayed when active filters return no matches.
class _NoMatchingServicesView extends StatelessWidget {
  const _NoMatchingServicesView({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return PortalEmptyState(
      key: const ValueKey<String>('services-no-results'),
      title: 'No matching services',
      description: 'Try changing the search query or selected category.',
      icon: Icons.search_off_outlined,
      actionLabel: 'Clear filters',
      onAction: onClearFilters,
    );
  }
}

/// Presentation displayed when the repository returns no services.
class _ServicesEmptyView extends StatelessWidget {
  const _ServicesEmptyView({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('services-empty'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
      children: [
        PortalEmptyState(
          title: 'No services available',
          description: 'Services will appear here when they become available.',
          icon: Icons.apps_outlined,
          actionLabel: 'Refresh',
          onAction: onRefresh,
        ),
      ],
    );
  }
}

/// Presentation displayed when loading services fails.
class _ServicesFailureView extends StatelessWidget {
  const _ServicesFailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('services-failure'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
      children: [
        PortalErrorState(
          title: 'Unable to load services',
          description: message,
          retryLabel: 'Try again',
          onRetry: onRetry,
          semanticLabel: 'Unable to load services. $message',
        ),
      ],
    );
  }
}

RequestType _requestTypeForService(PortalService service) {
  return switch (service.id) {
    'service-001' => RequestType.employmentLetter,
    'service-002' => RequestType.leave,
    'service-003' => RequestType.payrollInquiry,
    'service-004' => RequestType.profileUpdate,
    'service-007' => RequestType.salaryCertificate,
    'service-008' => RequestType.leave,
    _ => RequestType.generalInquiry,
  };
}

/// Returns the number of service columns for the available width.
int _servicesColumnCount(double width) {
  if (width >= 1000) {
    return 3;
  }

  if (width >= 650) {
    return 2;
  }

  return 1;
}

/// Calculates the width of each service card.
double _servicesCardWidth({required double availableWidth, required int columnCount}) {
  final totalSpacing = PortalSpacing.md * (columnCount - 1);

  return (availableWidth - totalSpacing) / columnCount;
}
