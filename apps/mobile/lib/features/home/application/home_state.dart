import 'package:flutter/foundation.dart';

import '../domain/home_dashboard.dart';
import 'home_status.dart';

/// Immutable application state for the Home dashboard.
@immutable
final class HomeState {
  const HomeState({required this.status, this.dashboard, this.errorMessage})
    : assert(
        status == HomeStatus.success || dashboard == null,
        'dashboard may only be present when status is success.',
      ),
      assert(
        status == HomeStatus.failure || errorMessage == null,
        'errorMessage may only be present when status is failure.',
      );

  const HomeState.initial()
    : status = HomeStatus.initial,
      dashboard = null,
      errorMessage = null;

  const HomeState.loading()
    : status = HomeStatus.loading,
      dashboard = null,
      errorMessage = null;

  const HomeState.success(HomeDashboard loadedDashboard)
    : status = HomeStatus.success,
      dashboard = loadedDashboard,
      errorMessage = null;

  const HomeState.empty()
    : status = HomeStatus.empty,
      dashboard = null,
      errorMessage = null;

  const HomeState.failure(String message)
    : status = HomeStatus.failure,
      dashboard = null,
      errorMessage = message;

  /// Current dashboard status.
  final HomeStatus status;

  /// Loaded dashboard data.
  ///
  /// This value is available only when [status] is [HomeStatus.success].
  final HomeDashboard? dashboard;

  /// Safe user-facing error message.
  ///
  /// This value is available only when [status] is [HomeStatus.failure].
  final String? errorMessage;

  /// Whether dashboard information is being loaded.
  bool get isLoading {
    return status == HomeStatus.loading;
  }

  /// Whether dashboard information loaded successfully.
  bool get hasData {
    return status == HomeStatus.success && dashboard != null;
  }

  /// Whether the dashboard has no information to display.
  bool get isEmpty {
    return status == HomeStatus.empty;
  }

  /// Whether dashboard loading failed.
  bool get hasFailure {
    return status == HomeStatus.failure;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HomeState &&
            other.status == status &&
            other.dashboard == dashboard &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(status, dashboard, errorMessage);
  }

  @override
  String toString() {
    return 'HomeState('
        'status: $status, '
        'dashboard: $dashboard, '
        'errorMessage: $errorMessage'
        ')';
  }
}
