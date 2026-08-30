import 'home_dashboard.dart';

/// Provides Home dashboard information.
///
/// The Flutter application depends on this abstraction. The fake repository
/// will be replaced by an API implementation after the backend contract is
/// available.
abstract interface class HomeRepository {
  /// Loads the information required by the Home dashboard.
  Future<HomeDashboard> loadDashboard();
}
