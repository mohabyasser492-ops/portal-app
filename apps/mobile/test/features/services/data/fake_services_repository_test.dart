import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/services/data/fake_services_repository.dart';
import 'package:portal_app/features/services/domain/portal_service.dart';
import 'package:portal_app/features/services/domain/service_category.dart';

void main() {
  group('FakeServicesRepository', () {
    test('returns synthetic services', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final services = await repository.loadServices();

      expect(services, hasLength(9));

      expect(services.every((service) => service.id.isNotEmpty), isTrue);

      expect(services.every((service) => service.name.isNotEmpty), isTrue);

      expect(repository.loadServicesCallCount, 1);
    });

    test('returns services from every category', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final services = await repository.loadServices();

      final returnedCategories = services
          .map((service) => service.category)
          .toSet();

      expect(returnedCategories, containsAll(ServiceCategory.values));
    });

    test('returns featured services', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final services = await repository.loadServices();

      final featuredServices = services
          .where((service) => service.isFeatured)
          .toList();

      expect(featuredServices, hasLength(2));

      expect(
        featuredServices.map((service) => service.name),
        containsAll(const ['Employment Letter', 'Leave Request']),
      );
    });

    test('returns an unavailable service', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final services = await repository.loadServices();

      final unavailableServices = services
          .where((service) => !service.isAvailable)
          .toList();

      expect(unavailableServices, hasLength(1));

      expect(unavailableServices.single.name, 'Bank Details Update');
    });

    test('returns an unmodifiable service collection', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final services = await repository.loadServices();

      const syntheticService = PortalService(
        id: 'service-test',
        name: 'Synthetic Test Service',
        description: 'Synthetic service used to test collection immutability.',
        category: ServiceCategory.general,
        iconName: 'apps',
      );

      expect(() => services.add(syntheticService), throwsUnsupportedError);
    });

    test('returns an empty service collection', () async {
      final repository = FakeServicesRepository(
        scenario: FakeServicesScenario.empty,
        operationDelay: Duration.zero,
      );

      final services = await repository.loadServices();

      expect(services, isEmpty);

      expect(repository.loadServicesCallCount, 1);
    });

    test('throws a controlled failure', () async {
      final repository = FakeServicesRepository(
        scenario: FakeServicesScenario.failure,
        operationDelay: Duration.zero,
      );

      expect(
        repository.loadServices(),
        throwsA(isA<ServicesRepositoryException>()),
      );

      expect(repository.loadServicesCallCount, 1);
    });

    test('can change scenarios during development', () async {
      final repository = FakeServicesRepository(
        scenario: FakeServicesScenario.empty,
        operationDelay: Duration.zero,
      );

      final emptyServices = await repository.loadServices();

      expect(emptyServices, isEmpty);

      repository.scenario = FakeServicesScenario.populated;

      final populatedServices = await repository.loadServices();

      expect(populatedServices, hasLength(9));

      expect(repository.loadServicesCallCount, 2);
    });

    test('returns a new collection for each request', () async {
      final repository = FakeServicesRepository(operationDelay: Duration.zero);

      final firstServices = await repository.loadServices();

      final secondServices = await repository.loadServices();

      expect(identical(firstServices, secondServices), isFalse);

      expect(firstServices, orderedEquals(secondServices));

      expect(repository.loadServicesCallCount, 2);
    });

    test('provides a readable repository exception', () {
      const exception = ServicesRepositoryException('Synthetic failure.');

      expect(exception.message, 'Synthetic failure.');

      expect(
        exception.toString(),
        'ServicesRepositoryException: Synthetic failure.',
      );
    });
  });
}
