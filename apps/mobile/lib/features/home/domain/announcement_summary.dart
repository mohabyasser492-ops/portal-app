import 'package:flutter/foundation.dart';

/// Minimal announcement information displayed on the Home dashboard.
///
/// The model remains independent from backend JSON field names.
@immutable
final class AnnouncementSummary {
  const AnnouncementSummary({
    required this.id,
    required this.title,
    required this.summary,
    required this.publishedAt,
    this.isPinned = false,
  }) : assert(id != '', 'id cannot be empty.'),
       assert(title != '', 'title cannot be empty.'),
       assert(summary != '', 'summary cannot be empty.');

  /// Stable announcement identifier.
  final String id;

  /// User-facing announcement title.
  final String title;

  /// Short announcement preview.
  final String summary;

  /// Publication date and time.
  final DateTime publishedAt;

  /// Whether the announcement should be prioritized visually.
  final bool isPinned;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnnouncementSummary &&
            other.id == id &&
            other.title == title &&
            other.summary == summary &&
            other.publishedAt == publishedAt &&
            other.isPinned == isPinned;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, summary, publishedAt, isPinned);
  }

  @override
  String toString() {
    return 'AnnouncementSummary('
        'id: $id, '
        'title: $title, '
        'summary: $summary, '
        'publishedAt: $publishedAt, '
        'isPinned: $isPinned'
        ')';
  }
}
