import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/home/application/home_controller.dart';
import 'package:portal_app/features/home/application/home_providers.dart';
import 'package:portal_app/features/home/application/home_state.dart';
import 'package:portal_app/features/home/application/home_status.dart';
import 'package:portal_app/features/home/data/fake_home_repository.dart';
import 'package:portal_app/features/home/domain/home_dashboard.dart';
import 'package:portal_app/features/home/domain/home_repository.dart';

void main() {
  group('HomeController', () {
    test('starts in the initial state', () {
      final repository = FakeHomeRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      expect(container.read(homeControllerProvider), const HomeState.initial());

      expect(repository.loadDashboardCallCount, 0);
    });

    test('loads a populated dashboard', () async {
      final repository = FakeHomeRepository(operationDelay: Duration.zero);

      final container = _createContainer(repository);

      await container.read(homeControllerProvider.notifier).loadDashboard();

      final state = container.read(homeControllerProvider);

      expect(state.status, HomeStatus.success);
      expect(state.dashboard, isNotNull);
      expect(state.dashboard?.employeeDisplayName, 'Portal Employee');
      expect(state.dashboard?.pendingRequestCount, 2);
      expect(state.dashboard?.recentRequests, hasLength(3));
      expect(state.dashboard?.announcements, hasLength(2));
      expect(repository.loadDashboardCallCount, 1);
    });

    test('reports an empty dashboard', () async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.empty,
        operationDelay: Duration.zero,
      );

      final container = _createContainer(repository);

      await container.read(homeControllerProvider.notifier).loadDashboard();

      expect(container.read(homeControllerProvider), const HomeState.empty());

      expect(repository.loadDashboardCallCount, 1);
    });

    test('reports a repository failure', () async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.failure,
        operationDelay: Duration.zero,
      );

      final container = _createContainer(repository);

      await container.read(homeControllerProvider.notifier).loadDashboard();

      final state = container.read(homeControllerProvider);

      expect(state.status, HomeStatus.failure);

      expect(
        state.errorMessage,
        'Unable to load the dashboard. Please try again.',
      );

      expect(repository.loadDashboardCallCount, 1);
    });

    test('retries after a failure', () async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.failure,
        operationDelay: Duration.zero,
      );

      final container = _createContainer(repository);

      final controller = container.read(homeControllerProvider.notifier);

      await controller.loadDashboard();

      expect(container.read(homeControllerProvider).hasFailure, isTrue);

      repository.scenario = FakeHomeScenario.populated;

      await controller.retry();

      final state = container.read(homeControllerProvider);

      expect(state.status, HomeStatus.success);
      expect(state.dashboard, isNotNull);

      expect(repository.loadDashboardCallCount, 2);
    });

    test('retries after an empty result', () async {
      final repository = FakeHomeRepository(
        scenario: FakeHomeScenario.empty,
        operationDelay: Duration.zero,
      );

      final container = _createContainer(repository);

      final controller = container.read(homeControllerProvider.notifier);

      await controller.loadDashboard();

      expect(container.read(homeControllerProvider).isEmpty, isTrue);

      repository.scenario = FakeHomeScenario.populated;

      await controller.retry();

      expect(container.read(homeControllerProvider).status, HomeStatus.success);

      expect(repository.loadDashboardCallCount, 2);
    });

    test('does not start a second load while loading', () async {
      final dashboardCompleter = Completer<HomeDashboard>();

      final repository = _ControlledHomeRepository(
        loadCallback: () {
          return dashboardCompleter.future;
        },
      );

      final container = _createContainer(repository);

      final controller = container.read(homeControllerProvider.notifier);

      final firstLoad = controller.loadDashboard();

      expect(container.read(homeControllerProvider).status, HomeStatus.loading);

      final secondLoad = controller.loadDashboard();

      expect(repository.loadDashboardCallCount, 1);

      dashboardCompleter.complete(
        HomeDashboard(
          employeeDisplayName: 'Portal Employee',
          pendingRequestCount: 1,
          approvedRequestCount: 0,
          availableServiceCount: 0,
          recentRequests: const [],
          announcements: const [],
        ),
      );

      await firstLoad;
      await secondLoad;

      expect(container.read(homeControllerProvider).status, HomeStatus.success);

      expect(repository.loadDashboardCallCount, 1);
    });
  });
}

ProviderContainer _createContainer(HomeRepository repository) {
  final container = ProviderContainer(
    overrides: [homeRepositoryProvider.overrideWithValue(repository)],
  );

  addTearDown(container.dispose);

  return container;
}

final class _ControlledHomeRepository implements HomeRepository {
  _ControlledHomeRepository({required this.loadCallback});

  final Future<HomeDashboard> Function() loadCallback;

  int loadDashboardCallCount = 0;

  @override
  Future<HomeDashboard> loadDashboard() {
    loadDashboardCallCount++;

    return loadCallback();
  }
}
