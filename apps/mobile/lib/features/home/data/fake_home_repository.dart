import '../domain/announcement_summary.dart';
import '../domain/home_dashboard.dart';
import '../domain/home_repository.dart';
import '../domain/request_summary.dart';

/// Scenarios supported by [FakeHomeRepository].
enum FakeHomeScenario { populated, empty, failure }

/// Controlled exception used by [FakeHomeRepository] for failure scenarios.
final class HomeRepositoryException implements Exception {
  const HomeRepositoryException(this.message);

  /// Description of the controlled repository failure.
  final String message;

  @override
  String toString() {
    return 'HomeRepositoryException: $message';
  }
}

/// Frontend-only Home repository using synthetic dashboard information.
///
/// This implementation allows the Home dashboard to be developed and tested
/// before the backend API contract becomes available.
final class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.scenario = FakeHomeScenario.populated,
    this.operationDelay = const Duration(milliseconds: 300),
  });

  /// Current synthetic response scenario.
  FakeHomeScenario scenario;

  /// Artificial delay used to display loading states during development.
  final Duration operationDelay;

  /// Number of dashboard loading operations.
  int loadDashboardCallCount = 0;

  @override
  Future<HomeDashboard> loadDashboard() async {
    loadDashboardCallCount++;

    if (operationDelay > Duration.zero) {
      await Future<void>.delayed(operationDelay);
    }

    switch (scenario) {
      case FakeHomeScenario.populated:
        return _createPopulatedDashboard();

      case FakeHomeScenario.empty:
        return _createEmptyDashboard();

      case FakeHomeScenario.failure:
        throw const HomeRepositoryException(
          'Synthetic Home dashboard failure.',
        );
    }
  }

  HomeDashboard _createPopulatedDashboard() {
    return HomeDashboard(
      employeeDisplayName: 'Portal Employee',
      pendingRequestCount: 2,
      approvedRequestCount: 5,
      availableServiceCount: 8,
      recentRequests: [
        RequestSummary(
          id: 'request-1',
          title: 'Synthetic leave request',
          referenceNumber: 'REQ-00001',
          status: RequestSummaryStatus.pending,
          updatedAt: DateTime.utc(2026, 8, 30, 9, 30),
        ),
        RequestSummary(
          id: 'request-2',
          title: 'Synthetic employment letter request',
          referenceNumber: 'REQ-00002',
          status: RequestSummaryStatus.approved,
          updatedAt: DateTime.utc(2026, 8, 29, 13, 15),
        ),
        RequestSummary(
          id: 'request-3',
          title: 'Synthetic profile update request',
          referenceNumber: 'REQ-00003',
          status: RequestSummaryStatus.rejected,
          updatedAt: DateTime.utc(2026, 8, 28, 11),
        ),
      ],
      announcements: [
        AnnouncementSummary(
          id: 'announcement-1',
          title: 'Synthetic portal announcement',
          summary:
              'This is synthetic announcement content for frontend development.',
          publishedAt: DateTime.utc(2026, 8, 30, 8),
          isPinned: true,
        ),
        AnnouncementSummary(
          id: 'announcement-2',
          title: 'Synthetic services update',
          summary: 'Several synthetic employee services are now available.',
          publishedAt: DateTime.utc(2026, 8, 27, 10),
        ),
      ],
    );
  }

  HomeDashboard _createEmptyDashboard() {
    return HomeDashboard(
      employeeDisplayName: 'Portal Employee',
      pendingRequestCount: 0,
      approvedRequestCount: 0,
      availableServiceCount: 0,
      recentRequests: const [],
      announcements: const [],
    );
  }
}
