import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/home/application/home_state.dart';
import 'package:portal_app/features/home/application/home_status.dart';
import 'package:portal_app/features/home/domain/home_dashboard.dart';

void main() {
  final dashboard = HomeDashboard(
    employeeDisplayName: 'Portal Employee',
    pendingRequestCount: 2,
    approvedRequestCount: 5,
    availableServiceCount: 8,
    recentRequests: const [],
    announcements: const [],
  );

  group('HomeState', () {
    test('creates an initial state', () {
      const state = HomeState.initial();

      expect(state.status, HomeStatus.initial);
      expect(state.dashboard, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
      expect(state.isEmpty, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('creates a loading state', () {
      const state = HomeState.loading();

      expect(state.status, HomeStatus.loading);
      expect(state.dashboard, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isTrue);
      expect(state.hasData, isFalse);
      expect(state.isEmpty, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('creates a successful state', () {
      final state = HomeState.success(dashboard);

      expect(state.status, HomeStatus.success);
      expect(state.dashboard, dashboard);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isTrue);
      expect(state.isEmpty, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('creates an empty state', () {
      const state = HomeState.empty();

      expect(state.status, HomeStatus.empty);
      expect(state.dashboard, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
      expect(state.isEmpty, isTrue);
      expect(state.hasFailure, isFalse);
    });

    test('creates a failure state', () {
      const state = HomeState.failure('Unable to load the dashboard.');

      expect(state.status, HomeStatus.failure);
      expect(state.dashboard, isNull);
      expect(state.errorMessage, 'Unable to load the dashboard.');
      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
      expect(state.isEmpty, isFalse);
      expect(state.hasFailure, isTrue);
    });

    test('supports equality for matching states', () {
      final first = HomeState.success(dashboard);
      final second = HomeState.success(dashboard);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('detects different states', () {
      const initial = HomeState.initial();
      const loading = HomeState.loading();

      expect(initial, isNot(loading));
    });

    test('provides a readable string representation', () {
      const state = HomeState.failure('Synthetic failure');

      final value = state.toString();

      expect(value, contains('HomeStatus.failure'));
      expect(value, contains('Synthetic failure'));
    });
  });
}
