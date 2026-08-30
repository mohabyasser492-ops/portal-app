import 'employee_profile.dart';

/// Provides access to the employee's profile information.
abstract interface class ProfileRepository {
  /// Fetches the profile for the currently authenticated user.
  Future<EmployeeProfile> loadProfile();
}
