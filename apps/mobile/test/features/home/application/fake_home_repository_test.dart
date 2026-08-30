import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/home/data/fake_home_repository.dart';

void main() {
  group('FakeHomeRepository', () {
    test('returns populated synthetic dashboard data', () async {
      final repository = FakeHomeRepository(operationDelay: Duration.zero);

      final dashboard = await repository.loadDashboard();

      expect(dashboard.employeeDisplayName, 'Portal Employee');
      expect(dashboard.pendingRequestCount, 2);
      expect(dashboard.approvedRequestCount, 5);
      expect(dashboard.availableServiceCount, 8);
      expect(dashboard.recentRequests, hasLength(3));
      expect(dashboard.announcements, hasLength(2));
      expect(repository.loadDashboardCallCount, 1);
    });

    test('returns an empty dashboard', () async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.empty,
        operationDelay: Duration.zero,
      );

      final dashboard = await repository.loadDashboard();

      expect(dashboard.pendingRequestCount, 0);
      expect(dashboard.approvedRequestCount, 0);
      expect(dashboard.availableServiceCount, 0);
      expect(dashboard.recentRequests, isEmpty);
      expect(dashboard.announcements, isEmpty);
      expect(repository.loadDashboardCallCount, 1);
    });

    test('throws a controlled failure', () async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.failure,
        operationDelay: Duration.zero,
      );

      expect(
        repository.loadDashboard(),
        throwsA(isA<HomeRepositoryException>()),
      );

      expect(repository.loadDashboardCallCount, 1);
    });

    test('can change scenarios during development', () async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.empty,
        operationDelay: Duration.zero,
      );

      final emptyDashboard = await repository.loadDashboard();

      expect(emptyDashboard.recentRequests, isEmpty);

      repository.scenario = FakeHomeScenario.populated;

      final populatedDashboard = await repository.loadDashboard();

      expect(populatedDashboard.recentRequests, isNotEmpty);

      expect(repository.loadDashboardCallCount, 2);
    });
  });
}
