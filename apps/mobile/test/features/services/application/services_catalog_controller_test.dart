import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/services/application/services_catalog_controller.dart';
import 'package:portal_app/features/services/application/services_catalog_providers.dart';
import 'package:portal_app/features/services/application/services_catalog_status.dart';
import 'package:portal_app/features/services/data/fake_services_repository.dart';
import 'package:portal_app/features/services/domain/portal_service.dart';
import 'package:portal_app/features/services/domain/service_category.dart';
import 'package:portal_app/features/services/domain/services_repository.dart';

void main() {
  group('ServicesCatalogController', () {
    test('starts in the initial state', () {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.status, ServicesCatalogStatus.initial);

      expect(state.services, isEmpty);

      expect(repository.loadServicesCallCount, 0);
    });

    test('loads a populated Services catalog', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      await container.read(servicesCatalogControllerProvider.notifier).loadServices();

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.status, ServicesCatalogStatus.success);

      expect(state.services, hasLength(9));

      expect(state.visibleServices, hasLength(9));

      expect(state.hasServices, isTrue);

      expect(repository.loadServicesCallCount, 1);
    });

    test('reports an empty Services catalog', () async {
      final repository = FakeServicesRepository(
        scenario: FakeServicesScenario.empty,
        operationDelay: Duration.zero,
      );

      final container = _createContainer(repository);

      await container.read(servicesCatalogControllerProvider.notifier).loadServices();

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.status, ServicesCatalogStatus.empty);

      expect(state.services, isEmpty);

      expect(state.visibleServices, isEmpty);

      expect(repository.loadServicesCallCount, 1);
    });

    test('reports a repository failure', () async {
      final repository = FakeServicesRepository(
        scenario: FakeServicesScenario.failure,
        operationDelay: Duration.zero,
      );

      final container = _createContainer(repository);

      await container.read(servicesCatalogControllerProvider.notifier).loadServices();

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.status, ServicesCatalogStatus.failure);

      expect(state.errorMessage, 'Unable to load services. Please try again.');

      expect(state.hasFailure, isTrue);

      expect(repository.loadServicesCallCount, 1);
    });

    test('retries after a repository failure', () async {
      final repository = FakeServicesRepository(
        scenario: FakeServicesScenario.failure,
        operationDelay: Duration.zero,
      );

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      expect(container.read(servicesCatalogControllerProvider).hasFailure, isTrue);

      repository.scenario = FakeServicesScenario.populated;

      await controller.retry();

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.status, ServicesCatalogStatus.success);

      expect(state.services, hasLength(9));

      expect(repository.loadServicesCallCount, 2);
    });

    test('retries after an empty catalog', () async {
      final repository = FakeServicesRepository(
        scenario: FakeServicesScenario.empty,
        operationDelay: Duration.zero,
      );

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      expect(container.read(servicesCatalogControllerProvider).isEmpty, isTrue);

      repository.scenario = FakeServicesScenario.populated;

      await controller.retry();

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.status, ServicesCatalogStatus.success);

      expect(repository.loadServicesCallCount, 2);
    });

    test('does not start another load while loading', () async {
      final servicesCompleter = Completer<List<PortalService>>();

      final repository = _ControlledServicesRepository(
        loadCallback: () {
          return servicesCompleter.future;
        },
      );

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      final firstLoad = controller.loadServices();

      expect(
        container.read(servicesCatalogControllerProvider).status,
        ServicesCatalogStatus.loading,
      );

      final secondLoad = controller.loadServices();

      expect(repository.loadServicesCallCount, 1);

      servicesCompleter.complete(const [
        PortalService(
          id: 'service-controlled',
          name: 'Controlled Synthetic Service',
          description: 'Synthetic service used by the controlled repository.',
          category: ServiceCategory.general,
          iconName: 'apps',
        ),
      ]);

      await firstLoad;
      await secondLoad;

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.status, ServicesCatalogStatus.success);

      expect(state.services, hasLength(1));

      expect(repository.loadServicesCallCount, 1);
    });

    test('filters services by search query', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      controller.updateSearchQuery('payroll');

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.searchQuery, 'payroll');

      // 1. Update the expected length to 2
      expect(state.visibleServices, hasLength(2));

      // 2. Verify both expected services are in the filtered list
      final serviceNames = state.visibleServices.map((s) => s.name);
      expect(serviceNames, containsAll(['Payroll Statement', 'Bank Details Update']));

      expect(state.hasSearchQuery, isTrue);
    });

    test('filters services by description', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      controller.updateSearchQuery('support team');

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.visibleServices, hasLength(1));

      expect(state.visibleServices.single.name, 'General Inquiry');
    });

    test('filters services by category', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      controller.selectCategory(ServiceCategory.documents);

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.selectedCategory, ServiceCategory.documents);

      expect(state.visibleServices, hasLength(2));

      expect(
        state.visibleServices.every((service) => service.category == ServiceCategory.documents),
        isTrue,
      );
    });

    test('combines search and category filters', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      controller.selectCategory(ServiceCategory.leave);

      controller.updateSearchQuery('balance');

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.visibleServices, hasLength(1));

      expect(state.visibleServices.single.name, 'Leave Balance');

      expect(state.hasActiveFilters, isTrue);
    });

    test('reports no matches for conflicting filters', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      controller.selectCategory(ServiceCategory.documents);

      controller.updateSearchQuery('payroll');

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.services, hasLength(9));

      expect(state.visibleServices, isEmpty);

      expect(state.hasNoMatchingServices, isTrue);
    });

    test('clears search and category filters', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      controller.selectCategory(ServiceCategory.leave);

      controller.updateSearchQuery('balance');

      expect(container.read(servicesCatalogControllerProvider).hasActiveFilters, isTrue);

      controller.clearFilters();

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.searchQuery, isEmpty);

      expect(state.selectedCategory, isNull);

      expect(state.visibleServices, hasLength(9));

      expect(state.hasActiveFilters, isFalse);
    });

    test('selecting null clears the category filter', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      await controller.loadServices();

      controller.selectCategory(ServiceCategory.payroll);

      expect(
        container.read(servicesCatalogControllerProvider).selectedCategory,
        ServiceCategory.payroll,
      );

      controller.selectCategory(null);

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.selectedCategory, isNull);

      expect(state.visibleServices, hasLength(9));
    });

    test('ignores filter updates before loading succeeds', () {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      final controller = container.read(servicesCatalogControllerProvider.notifier);

      controller.updateSearchQuery('leave');

      controller.selectCategory(ServiceCategory.leave);

      controller.clearFilters();

      final state = container.read(servicesCatalogControllerProvider);

      expect(state.status, ServicesCatalogStatus.initial);

      expect(state.searchQuery, isEmpty);

      expect(state.selectedCategory, isNull);

      expect(repository.loadServicesCallCount, 0);
    });
  });
}

ProviderContainer _createContainer(ServicesRepository repository) {
  final container = ProviderContainer(
    overrides: [servicesRepositoryProvider.overrideWithValue(repository)],
  );

  addTearDown(container.dispose);

  return container;
}

final class _ControlledServicesRepository implements ServicesRepository {
  _ControlledServicesRepository({required this.loadCallback});

  final Future<List<PortalService>> Function() loadCallback;

  int loadServicesCallCount = 0;

  @override
  Future<List<PortalService>> loadServices() {
    loadServicesCallCount++;

    return loadCallback();
  }
}
