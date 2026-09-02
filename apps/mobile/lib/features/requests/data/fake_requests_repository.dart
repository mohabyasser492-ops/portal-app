import '../domain/portal_request.dart';
import '../domain/portal_request_status.dart';
import '../domain/request_type.dart';
import '../domain/requests_repository.dart';

final class FakeRequestsRepository implements RequestsRepository {
  FakeRequestsRepository({this.operationDelay = const Duration(milliseconds: 300)})
    : _requests = _seedRequests();

  final Duration operationDelay;
  final List<PortalRequest> _requests;
  int _sequence = 10;

  @override
  Future<List<PortalRequest>> loadRequests() async {
    await _delay();
    final copy = [..._requests]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(copy);
  }

  @override
  Future<PortalRequest> createRequest({
    required RequestType type,
    required String description,
  }) async {
    await _delay();
    final now = DateTime.now();
    final request = PortalRequest(
      id: 'request-$_sequence',
      referenceNumber: 'REQ-${10000 + _sequence}',
      type: type,
      title: _titleForType(type),
      description: description,
      status: PortalRequestStatus.submitted,
      createdAt: now,
      updatedAt: now,
    );
    _sequence++;
    _requests.insert(0, request);
    return request;
  }

  @override
  Future<PortalRequest> cancelRequest(String requestId) async {
    await _delay();
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index < 0) {
      throw const RequestsRepositoryException('Request not found.');
    }
    final current = _requests[index];
    if (!current.canCancel) {
      throw const RequestsRepositoryException('Request cannot be cancelled.');
    }
    final updated = current.copyWith(
      status: PortalRequestStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    _requests[index] = updated;
    return updated;
  }

  Future<void> _delay() async {
    if (operationDelay > Duration.zero) {
      await Future<void>.delayed(operationDelay);
    }
  }

  static String _titleForType(RequestType type) => switch (type) {
    RequestType.leave => 'Leave Request',
    RequestType.employmentLetter => 'Employment Letter',
    RequestType.salaryCertificate => 'Salary Certificate',
    RequestType.profileUpdate => 'Profile Update',
    RequestType.payrollInquiry => 'Payroll Inquiry',
    RequestType.generalInquiry => 'General Inquiry',
  };

  static List<PortalRequest> _seedRequests() {
    final now = DateTime.now();
    return [
      PortalRequest(
        id: 'request-001',
        referenceNumber: 'REQ-10001',
        type: RequestType.leave,
        title: 'Annual Leave Request',
        description: 'Annual leave for a planned family trip.',
        status: PortalRequestStatus.inReview,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      PortalRequest(
        id: 'request-002',
        referenceNumber: 'REQ-10002',
        type: RequestType.employmentLetter,
        title: 'Employment Letter',
        description: 'Employment verification letter for official use.',
        status: PortalRequestStatus.approved,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      PortalRequest(
        id: 'request-003',
        referenceNumber: 'REQ-10003',
        type: RequestType.salaryCertificate,
        title: 'Salary Certificate',
        description: 'Salary certificate for banking requirements.',
        status: PortalRequestStatus.submitted,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      PortalRequest(
        id: 'request-004',
        referenceNumber: 'REQ-10004',
        type: RequestType.profileUpdate,
        title: 'Profile Update',
        description: 'Update employee contact information.',
        status: PortalRequestStatus.rejected,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }
}

final class RequestsRepositoryException implements Exception {
  const RequestsRepositoryException(this.message);
  final String message;

  @override
  String toString() => 'RequestsRepositoryException: $message';
}
