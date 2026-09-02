import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/services/application/services_catalog_state.dart';
import 'package:portal_app/features/services/application/services_catalog_status.dart';
import 'package:portal_app/features/services/domain/portal_service.dart';
import 'package:portal_app/features/services/domain/service_category.dart';

void main() {
  const employmentLetter = PortalService(
    id: 'service-001',
    name: 'Employment Letter',
    description: 'Request a synthetic employment letter.',
    category: ServiceCategory.documents,
    iconName: 'description',
    isFeatured: true,
  );

  const leaveRequest = PortalService(
    id: 'service-002',
    name: 'Leave Request',
    description: 'Create and track a synthetic employee leave request.',
    category: ServiceCategory.leave,
    iconName: 'event_available',
  );

  const payrollStatement = PortalService(
    id: 'service-003',
    name: 'Payroll Statement',
    description: 'View synthetic salary and payment information.',
    category: ServiceCategory.payroll,
    iconName: 'payments',
  );

  const services = <PortalService>[
    employmentLetter,
    leaveRequest,
    payrollStatement,
  ];

  group('ServicesCatalogState', () {
    test('creates an initial state', () {
      final state = ServicesCatalogState.initial();

      expect(state.status, ServicesCatalogStatus.initial);
      expect(state.services, isEmpty);
      expect(state.visibleServices, isEmpty);
      expect(state.searchQuery, isEmpty);
      expect(state.selectedCategory, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
      expect(state.hasServices, isFalse);
      expect(state.isEmpty, isFalse);
      expect(state.hasFailure, isFalse);
      expect(state.hasActiveFilters, isFalse);
      expect(state.hasNoMatchingServices, isFalse);
    });

    test('creates a loading state', () {
      final state = ServicesCatalogState.loading();

      expect(state.status, ServicesCatalogStatus.loading);
      expect(state.services, isEmpty);
      expect(state.visibleServices, isEmpty);
      expect(state.isLoading, isTrue);
      expect(state.hasServices, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('creates a successful state', () {
      final state = ServicesCatalogState.success(services: services);

      expect(state.status, ServicesCatalogStatus.success);
      expect(state.services, orderedEquals(services));
      expect(state.visibleServices, orderedEquals(services));
      expect(state.hasServices, isTrue);
      expect(state.isEmpty, isFalse);
      expect(state.hasFailure, isFalse);
      expect(state.hasActiveFilters, isFalse);
    });

    test('creates an empty state', () {
      final state = ServicesCatalogState.empty();

      expect(state.status, ServicesCatalogStatus.empty);
      expect(state.services, isEmpty);
      expect(state.visibleServices, isEmpty);
      expect(state.isEmpty, isTrue);
      expect(state.hasServices, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('creates a failure state', () {
      final state = ServicesCatalogState.failure('Unable to load services.');

      expect(state.status, ServicesCatalogStatus.failure);
      expect(state.services, isEmpty);
      expect(state.visibleServices, isEmpty);
      expect(state.errorMessage, 'Unable to load services.');
      expect(state.hasFailure, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.hasServices, isFalse);
    });

    test('creates unmodifiable service collections', () {
      final mutableServices = <PortalService>[employmentLetter, leaveRequest];

      final state = ServicesCatalogState.success(services: mutableServices);

      mutableServices.clear();

      expect(state.services, hasLength(2));

      expect(
        () => state.services.add(payrollStatement),
        throwsUnsupportedError,
      );

      expect(
        () => state.visibleServices.add(payrollStatement),
        throwsUnsupportedError,
      );
    });

    test('filters services by name', () {
      final state = ServicesCatalogState.success(
        services: services,
        searchQuery: 'leave',
      );

      expect(state.visibleServices, const [leaveRequest]);

      expect(state.searchQuery, 'leave');
      expect(state.hasSearchQuery, isTrue);
      expect(state.hasActiveFilters, isTrue);
      expect(state.hasNoMatchingServices, isFalse);
    });

    test('filters services by description', () {
      final state = ServicesCatalogState.success(
        services: services,
        searchQuery: 'salary',
      );

      expect(state.visibleServices, const [payrollStatement]);
    });

    test('uses case-insensitive search', () {
      final state = ServicesCatalogState.success(
        services: services,
        searchQuery: 'EMPLOYMENT',
      );

      expect(state.visibleServices, const [employmentLetter]);
    });

    test('trims the search query', () {
      final state = ServicesCatalogState.success(
        services: services,
        searchQuery: '  leave  ',
      );

      expect(state.searchQuery, 'leave');

      expect(state.visibleServices, const [leaveRequest]);
    });

    test('filters services by category', () {
      final state = ServicesCatalogState.success(
        services: services,
        selectedCategory: ServiceCategory.documents,
      );

      expect(state.visibleServices, const [employmentLetter]);

      expect(state.selectedCategory, ServiceCategory.documents);

      expect(state.hasCategoryFilter, isTrue);
      expect(state.hasActiveFilters, isTrue);
    });

    test('combines search and category filters', () {
      final state = ServicesCatalogState.success(
        services: services,
        searchQuery: 'request',
        selectedCategory: ServiceCategory.leave,
      );

      expect(state.visibleServices, const [leaveRequest]);

      expect(state.hasSearchQuery, isTrue);
      expect(state.hasCategoryFilter, isTrue);
    });

    test('returns no matches when filters conflict', () {
      final state = ServicesCatalogState.success(
        services: services,
        searchQuery: 'payroll',
        selectedCategory: ServiceCategory.documents,
      );

      expect(state.visibleServices, isEmpty);
      expect(state.services, hasLength(3));
      expect(state.hasServices, isTrue);
      expect(state.hasNoMatchingServices, isTrue);
    });

    test('updates the search query', () {
      final initialState = ServicesCatalogState.success(services: services);

      final updatedState = initialState.withSearchQuery('leave');

      expect(updatedState.searchQuery, 'leave');

      expect(updatedState.visibleServices, const [leaveRequest]);

      expect(updatedState.services, orderedEquals(services));
    });

    test('updates the category filter', () {
      final initialState = ServicesCatalogState.success(services: services);

      final updatedState = initialState.withSelectedCategory(
        ServiceCategory.payroll,
      );

      expect(updatedState.selectedCategory, ServiceCategory.payroll);

      expect(updatedState.visibleServices, const [payrollStatement]);
    });

    test('preserves category when search changes', () {
      final initialState = ServicesCatalogState.success(
        services: services,
        selectedCategory: ServiceCategory.leave,
      );

      final updatedState = initialState.withSearchQuery('request');

      expect(updatedState.selectedCategory, ServiceCategory.leave);

      expect(updatedState.visibleServices, const [leaveRequest]);
    });

    test('preserves search when category changes', () {
      final initialState = ServicesCatalogState.success(
        services: services,
        searchQuery: 'request',
      );

      final updatedState = initialState.withSelectedCategory(
        ServiceCategory.leave,
      );

      expect(updatedState.searchQuery, 'request');

      expect(updatedState.visibleServices, const [leaveRequest]);
    });

    test('clears all active filters', () {
      final filteredState = ServicesCatalogState.success(
        services: services,
        searchQuery: 'request',
        selectedCategory: ServiceCategory.leave,
      );

      final clearedState = filteredState.clearFilters();

      expect(clearedState.searchQuery, isEmpty);
      expect(clearedState.selectedCategory, isNull);
      expect(clearedState.hasActiveFilters, isFalse);

      expect(clearedState.visibleServices, orderedEquals(services));
    });

    test('does not update filters outside success state', () {
      final loadingState = ServicesCatalogState.loading();

      expect(
        identical(loadingState.withSearchQuery('leave'), loadingState),
        isTrue,
      );

      expect(
        identical(
          loadingState.withSelectedCategory(ServiceCategory.leave),
          loadingState,
        ),
        isTrue,
      );

      expect(identical(loadingState.clearFilters(), loadingState), isTrue);
    });

    test('supports equality for matching states', () {
      final first = ServicesCatalogState.success(
        services: services,
        searchQuery: 'leave',
        selectedCategory: ServiceCategory.leave,
      );

      final second = ServicesCatalogState.success(
        services: services,
        searchQuery: 'leave',
        selectedCategory: ServiceCategory.leave,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('detects different filter states', () {
      final first = ServicesCatalogState.success(services: services);

      final second = ServicesCatalogState.success(
        services: services,
        searchQuery: 'leave',
      );

      expect(first, isNot(second));
    });

    test('provides a readable string representation', () {
      final state = ServicesCatalogState.success(
        services: services,
        searchQuery: 'leave',
        selectedCategory: ServiceCategory.leave,
      );

      final value = state.toString();

      expect(value, contains('ServicesCatalogStatus.success'));

      expect(value, contains('searchQuery: leave'));

      expect(value, contains('ServiceCategory.leave'));
    });
  });
}
