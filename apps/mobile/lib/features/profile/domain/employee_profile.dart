import 'package:flutter/foundation.dart';

/// Comprehensive employee profile information.
@immutable
final class EmployeeProfile {
  const EmployeeProfile({
    required this.id,
    required this.displayName,
    required this.jobTitle,
    required this.department,
    required this.email,
    required this.mobilePhone,
    required this.employeeId,
    required this.managerName,
  })  : assert(id != '', 'id cannot be empty.'),
        assert(displayName != '', 'displayName cannot be empty.');

  /// Stable account identifier supplied by the identity provider.
  final String id;

  /// Display name shown in the application interface.
  final String displayName;

  /// The employee's official job title.
  final String jobTitle;

  /// The department the employee belongs to.
  final String department;

  /// The employee's work email address.
  final String email;

  /// The employee's contact mobile phone number.
  final String mobilePhone;

  /// The employee's internal HR identifier.
  final String employeeId;

  /// The display name of the employee's direct manager.
  final String managerName;

  EmployeeProfile copyWith({
    String? id,
    String? displayName,
    String? jobTitle,
    String? department,
    String? email,
    String? mobilePhone,
    String? employeeId,
    String? managerName,
  }) {
    return EmployeeProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      email: email ?? this.email,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      employeeId: employeeId ?? this.employeeId,
      managerName: managerName ?? this.managerName,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EmployeeProfile &&
            other.id == id &&
            other.displayName == displayName &&
            other.jobTitle == jobTitle &&
            other.department == department &&
            other.email == email &&
            other.mobilePhone == mobilePhone &&
            other.employeeId == employeeId &&
            other.managerName == managerName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      displayName,
      jobTitle,
      department,
      email,
      mobilePhone,
      employeeId,
      managerName,
    );
  }

  @override
  String toString() {
    return 'EmployeeProfile('
        'id: $id, '
        'displayName: $displayName, '
        'jobTitle: $jobTitle, '
        'department: $department, '
        'email: $email, '
        'mobilePhone: $mobilePhone, '
        'employeeId: $employeeId, '
        'managerName: $managerName'
        ')';
  }
}
