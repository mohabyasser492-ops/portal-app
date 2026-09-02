import 'portal_service.dart';

/// Provides the services available through the Portal catalog.
///
/// The application and presentation layers depend on this abstraction rather
/// than directly depending on fake data or backend HTTP implementation details.
///
/// A future API repository can implement this interface after the shared
/// backend contract is available.
abstract interface class ServicesRepository {
  /// Loads all services available to the current user.
  Future<List<PortalService>> loadServices();
}
