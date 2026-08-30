import '../domain/employee_profile.dart';
import '../domain/profile_repository.dart';

/// Scenarios supported by [FakeProfileRepository].
enum FakeProfileScenario { populated, failure }

/// Controlled exception used by [FakeProfileRepository] for failure scenarios.
final class ProfileRepositoryException implements Exception {
  const ProfileRepositoryException(this.message);

  /// Description of the controlled repository failure.
  final String message;

  @override
  String toString() {
    return 'ProfileRepositoryException: $message';
  }
}

/// Frontend-only Profile repository using synthetic employee information.
///
/// This implementation allows the Profile feature to be developed and tested
/// before the backend API contract becomes available.
final class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    this.scenario = FakeProfileScenario.populated,
    this.operationDelay = const Duration(milliseconds: 300),
  });

  /// Current synthetic response scenario.
  FakeProfileScenario scenario;

  /// Artificial delay used to display loading states during development.
  final Duration operationDelay;

  /// Number of profile loading operations.
  int loadProfileCallCount = 0;

  @override
  Future<EmployeeProfile> loadProfile() async {
    loadProfileCallCount++;

    if (operationDelay > Duration.zero) {
      await Future<void>.delayed(operationDelay);
    }

    switch (scenario) {
      case FakeProfileScenario.populated:
        return _createPopulatedProfile();

      case FakeProfileScenario.failure:
        throw const ProfileRepositoryException(
          'Synthetic Profile fetch failure.',
        );
    }
  }

  EmployeeProfile _createPopulatedProfile() {
    return const EmployeeProfile(
      id: 'test-user',
      displayName: 'Portal Employee',
      jobTitle: 'Senior Software Engineer',
      department: 'Engineering & Technology',
      email: 'employee@portal.local',
      mobilePhone: '+971 50 123 4567',
      employeeId: 'EMP-001024',
      managerName: 'Sarah Manager',
    );
  }
}
