import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/services/domain/portal_service.dart';
import 'package:portal_app/features/services/domain/service_category.dart';

void main() {
  group('ServiceCategory', () {
    test('defines every catalog category', () {
      expect(
        ServiceCategory.values,
        containsAll(const [
          ServiceCategory.humanResources,
          ServiceCategory.leave,
          ServiceCategory.payroll,
          ServiceCategory.documents,
          ServiceCategory.profile,
          ServiceCategory.general,
        ]),
      );

      expect(ServiceCategory.values, hasLength(6));
    });

    test('uses unique category names', () {
      final categoryNames = ServiceCategory.values
          .map((category) => category.name)
          .toSet();

      expect(categoryNames, hasLength(ServiceCategory.values.length));
    });
  });

  group('PortalService', () {
    const service = PortalService(
      id: 'service-001',
      name: 'Synthetic Employment Letter',
      description:
          'Request a synthetic employment letter for frontend development.',
      category: ServiceCategory.documents,
      iconName: 'description',
      isFeatured: true,
    );

    test('stores service information', () {
      expect(service.id, 'service-001');

      expect(service.name, 'Synthetic Employment Letter');

      expect(
        service.description,
        'Request a synthetic employment letter '
        'for frontend development.',
      );

      expect(service.category, ServiceCategory.documents);

      expect(service.iconName, 'description');

      expect(service.isFeatured, isTrue);
      expect(service.isAvailable, isTrue);
    });

    test('uses default boolean values', () {
      const defaultService = PortalService(
        id: 'service-002',
        name: 'Synthetic General Service',
        description: 'Synthetic service used to verify default values.',
        category: ServiceCategory.general,
        iconName: 'apps',
      );

      expect(defaultService.isFeatured, isFalse);
      expect(defaultService.isAvailable, isTrue);
    });

    test('supports equality for matching values', () {
      const matchingService = PortalService(
        id: 'service-001',
        name: 'Synthetic Employment Letter',
        description:
            'Request a synthetic employment letter '
            'for frontend development.',
        category: ServiceCategory.documents,
        iconName: 'description',
        isFeatured: true,
      );

      expect(service, matchingService);
      expect(service.hashCode, matchingService.hashCode);
    });

    test('detects a different identifier', () {
      const differentService = PortalService(
        id: 'service-different',
        name: 'Synthetic Employment Letter',
        description:
            'Request a synthetic employment letter '
            'for frontend development.',
        category: ServiceCategory.documents,
        iconName: 'description',
        isFeatured: true,
      );

      expect(service, isNot(differentService));
    });

    test('detects a different category', () {
      const differentService = PortalService(
        id: 'service-001',
        name: 'Synthetic Employment Letter',
        description:
            'Request a synthetic employment letter '
            'for frontend development.',
        category: ServiceCategory.humanResources,
        iconName: 'description',
        isFeatured: true,
      );

      expect(service, isNot(differentService));
    });

    test('detects different availability', () {
      const unavailableService = PortalService(
        id: 'service-001',
        name: 'Synthetic Employment Letter',
        description:
            'Request a synthetic employment letter '
            'for frontend development.',
        category: ServiceCategory.documents,
        iconName: 'description',
        isFeatured: true,
        isAvailable: false,
      );

      expect(service, isNot(unavailableService));
    });

    test('provides a readable string representation', () {
      final value = service.toString();

      expect(value, contains('service-001'));

      expect(value, contains('Synthetic Employment Letter'));

      expect(value, contains('ServiceCategory.documents'));

      expect(value, contains('isFeatured: true'));

      expect(value, contains('isAvailable: true'));
    });
  });
}
