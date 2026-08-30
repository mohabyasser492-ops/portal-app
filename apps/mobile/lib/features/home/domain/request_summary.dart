import 'package:flutter/foundation.dart';

/// Status displayed for a recent employee request.
enum RequestSummaryStatus { draft, pending, approved, rejected }

/// Minimal request information displayed on the Home dashboard.
///
/// This is a frontend domain model. It intentionally contains no JSON parsing
/// because the backend API contract has not been finalized.
@immutable
final class RequestSummary {
  const RequestSummary({
    required this.id,
    required this.title,
    required this.referenceNumber,
    required this.status,
    required this.updatedAt,
  }) : assert(id != '', 'id cannot be empty.'),
       assert(title != '', 'title cannot be empty.'),
       assert(referenceNumber != '', 'referenceNumber cannot be empty.');

  /// Stable frontend identifier.
  final String id;

  /// User-facing request title.
  final String title;

  /// User-facing synthetic or backend reference number.
  final String referenceNumber;

  /// Current request status.
  final RequestSummaryStatus status;

  /// Last time the request changed.
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RequestSummary &&
            other.id == id &&
            other.title == title &&
            other.referenceNumber == referenceNumber &&
            other.status == status &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, referenceNumber, status, updatedAt);
  }

  @override
  String toString() {
    return 'RequestSummary('
        'id: $id, '
        'title: $title, '
        'referenceNumber: $referenceNumber, '
        'status: $status, '
        'updatedAt: $updatedAt'
        ')';
  }
}
