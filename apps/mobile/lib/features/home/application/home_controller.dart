import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_providers.dart';
import 'home_state.dart';
import 'home_status.dart';

/// Provides Home dashboard state and loading operations.
final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

/// Coordinates loading and retry behavior for the Home dashboard.
///
/// Widgets depend on this controller rather than directly accessing a
/// repository.
class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState.initial();
  }

  /// Loads the dashboard.
  ///
  /// Repeated calls are ignored while another load is already running.
  Future<void> loadDashboard() async {
    if (state.status == HomeStatus.loading) {
      return;
    }

    state = const HomeState.loading();

    try {
      final dashboard = await ref.read(homeRepositoryProvider).loadDashboard();

      final containsDashboardInformation =
          dashboard.pendingRequestCount > 0 ||
          dashboard.approvedRequestCount > 0 ||
          dashboard.availableServiceCount > 0 ||
          dashboard.hasRecentRequests ||
          dashboard.hasAnnouncements;

      if (!containsDashboardInformation) {
        state = const HomeState.empty();
        return;
      }

      state = HomeState.success(dashboard);
    } catch (_) {
      state = const HomeState.failure(
        'Unable to load the dashboard. Please try again.',
      );
    }
  }

  /// Retries dashboard loading after an empty or failed result.
  Future<void> retry() {
    return loadDashboard();
  }
}
