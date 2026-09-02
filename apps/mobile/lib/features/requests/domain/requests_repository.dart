import 'portal_request.dart';
import 'request_type.dart';

abstract interface class RequestsRepository {
  Future<List<PortalRequest>> loadRequests();
  Future<PortalRequest> createRequest({required RequestType type, required String description});
  Future<PortalRequest> cancelRequest(String requestId);
}
