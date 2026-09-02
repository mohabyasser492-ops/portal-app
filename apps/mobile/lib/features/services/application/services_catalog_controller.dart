import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/service_category.dart';
import 'services_catalog_providers.dart';
import 'services_catalog_state.dart';
import 'services_catalog_status.dart';

/// Provides Services catalog state and user actions.
final servicesCatalogControllerProvider =
    NotifierProvider<ServicesCatalogController, ServicesCatalogState>(
      ServicesCatalogController.new,
    );

/// Coordinates service loading, searching, filtering, and retry behavior.
///
/// Widgets interact with this controller instead of reading the repository
/// directly.
class ServicesCatalogController extends Notifier<ServicesCatalogState> {
  @override
  ServicesCatalogState build() {
    return ServicesCatalogState.initial();
  }

  /// Loads the complete Services catalog.
  ///
  /// Repeated calls are ignored while another loading operation is running.
  Future<void> loadServices() async {
    if (state.status == ServicesCatalogStatus.loading) {
      return;
    }

    state = ServicesCatalogState.loading();

    try {
      final services = await ref
          .read(servicesRepositoryProvider)
          .loadServices();

      if (services.isEmpty) {
        state = ServicesCatalogState.empty();
        return;
      }

      state = ServicesCatalogState.success(services: services);
    } catch (_) {
      state = ServicesCatalogState.failure(
        'Unable to load services. Please try again.',
      );
    }
  }

  /// Updates the current service search query.
  void updateSearchQuery(String query) {
    state = state.withSearchQuery(query);
  }

  /// Updates the selected service category.
  ///
  /// A null category displays services from every category.
  void selectCategory(ServiceCategory? category) {
    state = state.withSelectedCategory(category);
  }

  /// Removes the active search query and category filter.
  void clearFilters() {
    state = state.clearFilters();
  }

  /// Retries loading the Services catalog.
  Future<void> retry() {
    return loadServices();
  }
}
