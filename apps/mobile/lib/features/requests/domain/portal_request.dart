import 'package:flutter/foundation.dart';

import 'portal_request_status.dart';
import 'request_type.dart';

@immutable
final class PortalRequest {
  const PortalRequest({
    required this.id,
    required this.referenceNumber,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  })  : assert(id != '', 'id cannot be empty.'),
        assert(referenceNumber != '', 'referenceNumber cannot be empty.'),
        assert(title != '', 'title cannot be empty.'),
        assert(description != '', 'description cannot be empty.');

  final String id;
  final String referenceNumber;
  final RequestType type;
  final String title;
  final String description;
  final PortalRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get canCancel =>
      status == PortalRequestStatus.draft ||
      status == PortalRequestStatus.submitted ||
      status == PortalRequestStatus.inReview;

  PortalRequest copyWith({
    String? id,
    String? referenceNumber,
    RequestType? type,
    String? title,
    String? description,
    PortalRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortalRequest(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortalRequest &&
          other.id == id &&
          other.referenceNumber == referenceNumber &&
          other.type == type &&
          other.title == title &&
          other.description == description &&
          other.status == status &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        referenceNumber,
        type,
        title,
        description,
        status,
        createdAt,
        updatedAt,
      );
}
