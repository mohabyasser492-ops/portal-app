import 'package:flutter/foundation.dart';

import 'announcement_summary.dart';
import 'request_summary.dart';

/// Frontend domain data required by the Home dashboard.
@immutable
final class HomeDashboard {
  HomeDashboard({
    required this.employeeDisplayName,
    required this.pendingRequestCount,
    required this.approvedRequestCount,
    required this.availableServiceCount,
    required List<RequestSummary> recentRequests,
    required List<AnnouncementSummary> announcements,
  }) : assert(
         employeeDisplayName != '',
         'employeeDisplayName cannot be empty.',
       ),
       assert(
         pendingRequestCount >= 0,
         'pendingRequestCount cannot be negative.',
       ),
       assert(
         approvedRequestCount >= 0,
         'approvedRequestCount cannot be negative.',
       ),
       assert(
         availableServiceCount >= 0,
         'availableServiceCount cannot be negative.',
       ),
       recentRequests = List.unmodifiable(recentRequests),
       announcements = List.unmodifiable(announcements);

  /// Name displayed in the dashboard welcome section.
  final String employeeDisplayName;

  /// Number of pending employee requests.
  final int pendingRequestCount;

  /// Number of approved employee requests.
  final int approvedRequestCount;

  /// Number of services currently available to the user.
  final int availableServiceCount;

  /// Most recently changed requests.
  final List<RequestSummary> recentRequests;

  /// Latest announcements.
  final List<AnnouncementSummary> announcements;

  bool get hasRecentRequests {
    return recentRequests.isNotEmpty;
  }

  bool get hasAnnouncements {
    return announcements.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HomeDashboard &&
            other.employeeDisplayName == employeeDisplayName &&
            other.pendingRequestCount == pendingRequestCount &&
            other.approvedRequestCount == approvedRequestCount &&
            other.availableServiceCount == availableServiceCount &&
            listEquals(other.recentRequests, recentRequests) &&
            listEquals(other.announcements, announcements);
  }

  @override
  int get hashCode {
    return Object.hash(
      employeeDisplayName,
      pendingRequestCount,
      approvedRequestCount,
      availableServiceCount,
      Object.hashAll(recentRequests),
      Object.hashAll(announcements),
    );
  }

  @override
  String toString() {
    return 'HomeDashboard('
        'employeeDisplayName: $employeeDisplayName, '
        'pendingRequestCount: $pendingRequestCount, '
        'approvedRequestCount: $approvedRequestCount, '
        'availableServiceCount: $availableServiceCount, '
        'recentRequests: $recentRequests, '
        'announcements: $announcements'
        ')';
  }
}
