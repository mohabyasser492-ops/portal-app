import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/portal_request.dart';
import '../domain/portal_request_status.dart';
import '../domain/request_type.dart';
import 'requests_providers.dart';
import 'requests_state.dart';
import 'requests_status.dart';

final requestsControllerProvider = NotifierProvider<RequestsController, RequestsState>(
  RequestsController.new,
);

class RequestsController extends Notifier<RequestsState> {
  @override
  RequestsState build() => RequestsState.initial();

  Future<void> loadRequests() async {
    if (state.status == RequestsStatus.loading || state.status == RequestsStatus.submitting) {
      return;
    }
    state = RequestsState.loading(
      searchQuery: state.searchQuery,
      selectedStatus: state.selectedStatus,
      selectedType: state.selectedType,
    );
    try {
      final requests = await ref.read(requestsRepositoryProvider).loadRequests();
      if (requests.isEmpty) {
        state = RequestsState.empty();
      } else {
        state = RequestsState.success(
          requests: requests,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          selectedType: state.selectedType,
        );
      }
    } catch (_) {
      state = RequestsState.failure('Unable to load requests. Please try again.');
    }
  }

  void updateSearchQuery(String query) {
    if (state.requests.isEmpty) return;
    state = state.withFilters(searchQuery: query);
  }

  void selectStatus(PortalRequestStatus? status) {
    if (state.requests.isEmpty) return;
    state = state.withFilters(selectedStatus: status);
  }

  void selectType(RequestType? type) {
    if (state.requests.isEmpty) return;
    state = state.withFilters(selectedType: type);
  }

  void clearFilters() {
    if (state.requests.isEmpty) return;
    state = state.withFilters(selectedStatus: null, selectedType: null, searchQuery: '');
  }

  Future<void> retry() => loadRequests();

  Future<PortalRequest?> createRequest({
    required RequestType type,
    required String description,
  }) async {
    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) return null;

    final previous = state;
    state = RequestsState.submitting(requests: previous.requests);
    try {
      final created = await ref
          .read(requestsRepositoryProvider)
          .createRequest(type: type, description: trimmedDescription);
      final updated = [created, ...previous.requests];
      state = RequestsState.success(
        requests: updated,
        searchQuery: previous.searchQuery,
        selectedStatus: previous.selectedStatus,
        selectedType: previous.selectedType,
        operationMessage: 'Request ${created.referenceNumber} submitted successfully.',
      );
      return created;
    } catch (_) {
      state = RequestsState.success(
        requests: previous.requests,
        searchQuery: previous.searchQuery,
        selectedStatus: previous.selectedStatus,
        selectedType: previous.selectedType,
        operationMessage: 'Unable to submit the request. Please try again.',
      );
      return null;
    }
  }

  Future<PortalRequest?> cancelRequest(PortalRequest request) async {
    if (!request.canCancel) return null;
    try {
      final updated = await ref.read(requestsRepositoryProvider).cancelRequest(request.id);
      final requests = state.requests
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
      state = RequestsState.success(
        requests: requests,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        selectedType: state.selectedType,
        operationMessage: '${request.referenceNumber} was cancelled.',
      );
      return updated;
    } catch (_) {
      state = RequestsState.success(
        requests: state.requests,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        selectedType: state.selectedType,
        operationMessage: 'Unable to cancel the request. Please try again.',
      );
      return null;
    }
  }
}
