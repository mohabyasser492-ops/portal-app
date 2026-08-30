import 'home_dashboard.dart';

/// Defines the Home dashboard operations required by the Flutter application.
///
/// The frontend depends on this abstraction rather than directly depending on
/// fake data or backend HTTP implementation details.
abstract interface class HomeRepository {
  /// Loads the information required by the Home dashboard.
  Future<HomeDashboard> loadDashboard();
}
