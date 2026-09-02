import '../domain/portal_service.dart';
import '../domain/service_category.dart';
import '../domain/services_repository.dart';

/// Synthetic response scenarios supported by [FakeServicesRepository].
enum FakeServicesScenario { populated, empty, failure }

/// Frontend-only repository containing synthetic Portal services.
///
/// This repository allows the Services catalog to be developed and tested
/// before the backend API contract is available.
///
/// A future API repository can replace this implementation without changing
/// the Services controller or presentation layer.
final class FakeServicesRepository implements ServicesRepository {
  FakeServicesRepository({
    this.scenario = FakeServicesScenario.populated,
    this.operationDelay = const Duration(milliseconds: 300),
  });

  /// Current synthetic repository scenario.
  FakeServicesScenario scenario;

  /// Artificial delay used to make loading states visible during development.
  final Duration operationDelay;

  /// Number of service-loading operations performed.
  int loadServicesCallCount = 0;

  @override
  Future<List<PortalService>> loadServices() async {
    loadServicesCallCount++;

    if (operationDelay > Duration.zero) {
      await Future<void>.delayed(operationDelay);
    }

    return switch (scenario) {
      FakeServicesScenario.populated => List<PortalService>.unmodifiable(
        _createSyntheticServices(),
      ),
      FakeServicesScenario.empty => const <PortalService>[],
      FakeServicesScenario.failure => throw const ServicesRepositoryException(
        'Synthetic Services catalog failure.',
      ),
    };
  }

  List<PortalService> _createSyntheticServices() {
    return const [
      PortalService(
        id: 'service-001',
        name: 'Employment Letter',
        description:
            'Request a synthetic employment letter for frontend development.',
        category: ServiceCategory.documents,
        iconName: 'description',
        isFeatured: true,
      ),
      PortalService(
        id: 'service-002',
        name: 'Leave Request',
        description: 'Create and track a synthetic employee leave request.',
        category: ServiceCategory.leave,
        iconName: 'event_available',
        isFeatured: true,
      ),
      PortalService(
        id: 'service-003',
        name: 'Payroll Statement',
        description: 'View a synthetic payroll statement and payment summary.',
        category: ServiceCategory.payroll,
        iconName: 'payments',
      ),
      PortalService(
        id: 'service-004',
        name: 'Profile Update',
        description:
            'Request synthetic changes to personal or contact information.',
        category: ServiceCategory.profile,
        iconName: 'person',
      ),
      PortalService(
        id: 'service-005',
        name: 'Benefits Information',
        description:
            'Review synthetic employee benefits and enrollment information.',
        category: ServiceCategory.humanResources,
        iconName: 'health_and_safety',
      ),
      PortalService(
        id: 'service-006',
        name: 'General Inquiry',
        description:
            'Send a synthetic general inquiry to the Portal support team.',
        category: ServiceCategory.general,
        iconName: 'help_outline',
      ),
      PortalService(
        id: 'service-007',
        name: 'Salary Certificate',
        description:
            'Request a synthetic salary certificate for development use.',
        category: ServiceCategory.documents,
        iconName: 'verified_user',
      ),
      PortalService(
        id: 'service-008',
        name: 'Leave Balance',
        description: 'Review a synthetic summary of available employee leave.',
        category: ServiceCategory.leave,
        iconName: 'calendar_month',
      ),
      PortalService(
        id: 'service-009',
        name: 'Bank Details Update',
        description: 'Request a synthetic update to payroll bank information.',
        category: ServiceCategory.payroll,
        iconName: 'account_balance',
        isAvailable: false,
      ),
    ];
  }
}

/// Controlled exception used by [FakeServicesRepository] in failure scenarios.
final class ServicesRepositoryException implements Exception {
  const ServicesRepositoryException(this.message);

  /// Description of the controlled repository failure.
  final String message;

  @override
  String toString() {
    return 'ServicesRepositoryException: $message';
  }
}
