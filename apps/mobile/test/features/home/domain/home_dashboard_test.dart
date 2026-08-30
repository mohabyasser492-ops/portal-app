import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/home/domain/announcement_summary.dart';
import 'package:portal_app/features/home/domain/home_dashboard.dart';
import 'package:portal_app/features/home/domain/request_summary.dart';

void main() {
  final request = RequestSummary(
    id: 'request-1',
    title: 'Synthetic leave request',
    referenceNumber: 'REQ-00001',
    status: RequestSummaryStatus.pending,
    updatedAt: DateTime.utc(2026, 8, 30),
  );

  final announcement = AnnouncementSummary(
    id: 'announcement-1',
    title: 'Synthetic portal announcement',
    summary: 'This announcement contains synthetic preview content.',
    publishedAt: DateTime.utc(2026, 8, 29),
    isPinned: true,
  );

  group('HomeDashboard', () {
    test('stores dashboard information', () {
      final dashboard = HomeDashboard(
        employeeDisplayName: 'Portal Employee',
        pendingRequestCount: 2,
        approvedRequestCount: 5,
        availableServiceCount: 8,
        recentRequests: [request],
        announcements: [announcement],
      );

      expect(dashboard.employeeDisplayName, 'Portal Employee');
      expect(dashboard.pendingRequestCount, 2);
      expect(dashboard.approvedRequestCount, 5);
      expect(dashboard.availableServiceCount, 8);
      expect(dashboard.recentRequests, [request]);
      expect(dashboard.announcements, [announcement]);
      expect(dashboard.hasRecentRequests, isTrue);
      expect(dashboard.hasAnnouncements, isTrue);
    });

    test('reports empty dashboard sections', () {
      final dashboard = HomeDashboard(
        employeeDisplayName: 'Portal Employee',
        pendingRequestCount: 0,
        approvedRequestCount: 0,
        availableServiceCount: 0,
        recentRequests: const [],
        announcements: const [],
      );

      expect(dashboard.hasRecentRequests, isFalse);
      expect(dashboard.hasAnnouncements, isFalse);
    });

    test('creates unmodifiable collections', () {
      final requests = <RequestSummary>[request];
      final announcements = <AnnouncementSummary>[announcement];

      final dashboard = HomeDashboard(
        employeeDisplayName: 'Portal Employee',
        pendingRequestCount: 1,
        approvedRequestCount: 0,
        availableServiceCount: 4,
        recentRequests: requests,
        announcements: announcements,
      );

      requests.clear();
      announcements.clear();

      expect(dashboard.recentRequests, [request]);
      expect(dashboard.announcements, [announcement]);

      expect(
        () => dashboard.recentRequests.add(request),
        throwsUnsupportedError,
      );

      expect(
        () => dashboard.announcements.add(announcement),
        throwsUnsupportedError,
      );
    });

    test('supports equality for matching values', () {
      final first = HomeDashboard(
        employeeDisplayName: 'Portal Employee',
        pendingRequestCount: 2,
        approvedRequestCount: 5,
        availableServiceCount: 8,
        recentRequests: [request],
        announcements: [announcement],
      );

      final second = HomeDashboard(
        employeeDisplayName: 'Portal Employee',
        pendingRequestCount: 2,
        approvedRequestCount: 5,
        availableServiceCount: 8,
        recentRequests: [request],
        announcements: [announcement],
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('detects different dashboard values', () {
      final first = HomeDashboard(
        employeeDisplayName: 'Portal Employee',
        pendingRequestCount: 2,
        approvedRequestCount: 5,
        availableServiceCount: 8,
        recentRequests: [request],
        announcements: [announcement],
      );

      final second = HomeDashboard(
        employeeDisplayName: 'Different Employee',
        pendingRequestCount: 2,
        approvedRequestCount: 5,
        availableServiceCount: 8,
        recentRequests: [request],
        announcements: [announcement],
      );

      expect(first, isNot(second));
    });
  });

  group('RequestSummary', () {
    test('stores request information', () {
      expect(request.id, 'request-1');
      expect(request.title, 'Synthetic leave request');
      expect(request.referenceNumber, 'REQ-00001');
      expect(request.status, RequestSummaryStatus.pending);
      expect(request.updatedAt, DateTime.utc(2026, 8, 30));
    });

    test('supports equality', () {
      final matchingRequest = RequestSummary(
        id: 'request-1',
        title: 'Synthetic leave request',
        referenceNumber: 'REQ-00001',
        status: RequestSummaryStatus.pending,
        updatedAt: DateTime.utc(2026, 8, 30),
      );

      expect(request, matchingRequest);
      expect(request.hashCode, matchingRequest.hashCode);
    });
  });

  group('AnnouncementSummary', () {
    test('stores announcement information', () {
      expect(announcement.id, 'announcement-1');
      expect(announcement.title, 'Synthetic portal announcement');
      expect(announcement.isPinned, isTrue);
      expect(announcement.publishedAt, DateTime.utc(2026, 8, 29));
    });

    test('supports equality', () {
      final matchingAnnouncement = AnnouncementSummary(
        id: 'announcement-1',
        title: 'Synthetic portal announcement',
        summary: 'This announcement contains synthetic preview content.',
        publishedAt: DateTime.utc(2026, 8, 29),
        isPinned: true,
      );

      expect(announcement, matchingAnnouncement);
      expect(announcement.hashCode, matchingAnnouncement.hashCode);
    });
  });
}
