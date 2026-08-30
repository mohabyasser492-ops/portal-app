import 'package:flutter/foundation.dart';

import '../domain/employee_profile.dart';
import 'profile_status.dart';

/// Immutable application state for the Employee Profile.
@immutable
final class ProfileState {
  const ProfileState({required this.status, this.profile, this.errorMessage})
      : assert(
          status == ProfileStatus.success || profile == null,
          'profile may only be present when status is success.',
        ),
        assert(
          status == ProfileStatus.failure || errorMessage == null,
          'errorMessage may only be present when status is failure.',
        );

  const ProfileState.initial()
      : status = ProfileStatus.initial,
        profile = null,
        errorMessage = null;

  const ProfileState.loading()
      : status = ProfileStatus.loading,
        profile = null,
        errorMessage = null;

  const ProfileState.success(EmployeeProfile loadedProfile)
      : status = ProfileStatus.success,
        profile = loadedProfile,
        errorMessage = null;

  const ProfileState.failure(String message)
      : status = ProfileStatus.failure,
        profile = null,
        errorMessage = message;

  /// Current profile status.
  final ProfileStatus status;

  /// Loaded profile data.
  ///
  /// This value is available only when [status] is [ProfileStatus.success].
  final EmployeeProfile? profile;

  /// Safe user-facing error message.
  ///
  /// This value is available only when [status] is [ProfileStatus.failure].
  final String? errorMessage;

  /// Whether profile information is being loaded.
  bool get isLoading {
    return status == ProfileStatus.loading;
  }

  /// Whether profile information loaded successfully.
  bool get hasData {
    return status == ProfileStatus.success && profile != null;
  }

  /// Whether profile loading failed.
  bool get hasFailure {
    return status == ProfileStatus.failure;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileState &&
            other.status == status &&
            other.profile == profile &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(status, profile, errorMessage);
  }

  @override
  String toString() {
    return 'ProfileState('
        'status: $status, '
        'profile: $profile, '
        'errorMessage: $errorMessage'
        ')';
  }
}
