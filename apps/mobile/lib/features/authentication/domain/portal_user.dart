import 'package:flutter/foundation.dart';

/// Minimal authenticated-user information required by Portal App.
///
/// Access tokens and refresh tokens must never be stored in this model.
@immutable
final class PortalUser {
  const PortalUser({required this.id, required this.displayName, this.email})
    : assert(id != '', 'id cannot be empty.'),
      assert(displayName != '', 'displayName cannot be empty.');

  /// Stable account identifier supplied by the identity provider.
  final String id;

  /// Display name shown in the application interface.
  final String displayName;

  /// Optional account email or username.
  final String? email;

  PortalUser copyWith({
    String? id,
    String? displayName,
    String? email,
    bool clearEmail = false,
  }) {
    return PortalUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: clearEmail ? null : email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PortalUser &&
            other.id == id &&
            other.displayName == displayName &&
            other.email == email;
  }

  @override
  int get hashCode {
    return Object.hash(id, displayName, email);
  }

  @override
  String toString() {
    return 'PortalUser('
        'id: $id, '
        'displayName: $displayName, '
        'email: $email'
        ')';
  }
}
