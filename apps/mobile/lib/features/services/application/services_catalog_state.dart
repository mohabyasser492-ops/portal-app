import 'package:flutter/foundation.dart';

import '../domain/portal_service.dart';
import '../domain/service_category.dart';
import 'services_catalog_status.dart';

/// Immutable application state for the Services catalog.
///
/// The state stores the complete service collection and derives the visible
/// services from the active search query and category filter.
@immutable
final class ServicesCatalogState {
  ServicesCatalogState._({
    required this.status,
    required List<PortalService> services,
    required List<PortalService> visibleServices,
    required this.searchQuery,
    required this.selectedCategory,
    required this.errorMessage,
  }) : services = List<PortalService>.unmodifiable(services),
       visibleServices = List<PortalService>.unmodifiable(visibleServices);

  /// Creates the initial Services catalog state.
  factory ServicesCatalogState.initial() {
    return ServicesCatalogState._(
      status: ServicesCatalogStatus.initial,
      services: const [],
      visibleServices: const [],
      searchQuery: '',
      selectedCategory: null,
      errorMessage: null,
    );
  }

  /// Creates a loading Services catalog state.
  factory ServicesCatalogState.loading() {
    return ServicesCatalogState._(
      status: ServicesCatalogStatus.loading,
      services: const [],
      visibleServices: const [],
      searchQuery: '',
      selectedCategory: null,
      errorMessage: null,
    );
  }

  /// Creates a successful Services catalog state.
  ///
  /// The visible service collection is calculated using [searchQuery] and
  /// [selectedCategory].
  factory ServicesCatalogState.success({
    required List<PortalService> services,
    String searchQuery = '',
    ServiceCategory? selectedCategory,
  }) {
    final normalizedQuery = searchQuery.trim();

    final visibleServices = _filterServices(
      services: services,
      searchQuery: normalizedQuery,
      selectedCategory: selectedCategory,
    );

    return ServicesCatalogState._(
      status: ServicesCatalogStatus.success,
      services: services,
      visibleServices: visibleServices,
      searchQuery: normalizedQuery,
      selectedCategory: selectedCategory,
      errorMessage: null,
    );
  }

  /// Creates an empty Services catalog state.
  factory ServicesCatalogState.empty() {
    return ServicesCatalogState._(
      status: ServicesCatalogStatus.empty,
      services: const [],
      visibleServices: const [],
      searchQuery: '',
      selectedCategory: null,
      errorMessage: null,
    );
  }

  /// Creates a failed Services catalog state.
  factory ServicesCatalogState.failure(String message) {
    return ServicesCatalogState._(
      status: ServicesCatalogStatus.failure,
      services: const [],
      visibleServices: const [],
      searchQuery: '',
      selectedCategory: null,
      errorMessage: message,
    );
  }

  /// Current catalog status.
  final ServicesCatalogStatus status;

  /// Complete service collection returned by the repository.
  final List<PortalService> services;

  /// Services matching the active search and category filters.
  final List<PortalService> visibleServices;

  /// Current normalized search query.
  final String searchQuery;

  /// Current category filter.
  ///
  /// A null value means that every category is selected.
  final ServiceCategory? selectedCategory;

  /// Safe user-facing repository failure message.
  final String? errorMessage;

  /// Whether the service catalog is loading.
  bool get isLoading {
    return status == ServicesCatalogStatus.loading;
  }

  /// Whether the repository returned service information.
  bool get hasServices {
    return status == ServicesCatalogStatus.success && services.isNotEmpty;
  }

  /// Whether the repository returned an empty catalog.
  bool get isEmpty {
    return status == ServicesCatalogStatus.empty;
  }

  /// Whether the latest loading operation failed.
  bool get hasFailure {
    return status == ServicesCatalogStatus.failure;
  }

  /// Whether a search query is active.
  bool get hasSearchQuery {
    return searchQuery.isNotEmpty;
  }

  /// Whether a category filter is active.
  bool get hasCategoryFilter {
    return selectedCategory != null;
  }

  /// Whether any filter is currently active.
  bool get hasActiveFilters {
    return hasSearchQuery || hasCategoryFilter;
  }

  /// Whether the complete service catalog contains services but the current
  /// filters produce no matching results.
  bool get hasNoMatchingServices {
    return status == ServicesCatalogStatus.success &&
        services.isNotEmpty &&
        visibleServices.isEmpty;
  }

  /// Returns a successful state with an updated search query.
  ServicesCatalogState withSearchQuery(String query) {
    if (status != ServicesCatalogStatus.success) {
      return this;
    }

    return ServicesCatalogState.success(
      services: services,
      searchQuery: query,
      selectedCategory: selectedCategory,
    );
  }

  /// Returns a successful state with an updated category filter.
  ServicesCatalogState withSelectedCategory(ServiceCategory? category) {
    if (status != ServicesCatalogStatus.success) {
      return this;
    }

    return ServicesCatalogState.success(
      services: services,
      searchQuery: searchQuery,
      selectedCategory: category,
    );
  }

  /// Clears the search and category filters.
  ServicesCatalogState clearFilters() {
    if (status != ServicesCatalogStatus.success) {
      return this;
    }

    return ServicesCatalogState.success(services: services);
  }

  static List<PortalService> _filterServices({
    required List<PortalService> services,
    required String searchQuery,
    required ServiceCategory? selectedCategory,
  }) {
    final normalizedQuery = searchQuery.toLowerCase();

    return services
        .where((service) {
          final matchesCategory =
              selectedCategory == null || service.category == selectedCategory;

          final matchesSearch =
              normalizedQuery.isEmpty ||
              service.name.toLowerCase().contains(normalizedQuery) ||
              service.description.toLowerCase().contains(normalizedQuery);

          return matchesCategory && matchesSearch;
        })
        .toList(growable: false);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ServicesCatalogState &&
            other.status == status &&
            listEquals(other.services, services) &&
            listEquals(other.visibleServices, visibleServices) &&
            other.searchQuery == searchQuery &&
            other.selectedCategory == selectedCategory &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      Object.hashAll(services),
      Object.hashAll(visibleServices),
      searchQuery,
      selectedCategory,
      errorMessage,
    );
  }

  @override
  String toString() {
    return 'ServicesCatalogState('
        'status: $status, '
        'services: $services, '
        'visibleServices: $visibleServices, '
        'searchQuery: $searchQuery, '
        'selectedCategory: $selectedCategory, '
        'errorMessage: $errorMessage'
        ')';
  }
}
