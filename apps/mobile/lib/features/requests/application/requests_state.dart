import 'package:flutter/foundation.dart';

import '../domain/portal_request.dart';
import '../domain/portal_request_status.dart';
import '../domain/request_type.dart';
import 'requests_status.dart';

@immutable
final class RequestsState {
  RequestsState._({
    required this.status,
    required List<PortalRequest> requests,
    required List<PortalRequest> visibleRequests,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedType,
    required this.errorMessage,
    required this.operationMessage,
  }) : requests = List.unmodifiable(requests),
       visibleRequests = List.unmodifiable(visibleRequests);

  factory RequestsState.initial() => RequestsState._(
    status: RequestsStatus.initial,
    requests: const [],
    visibleRequests: const [],
    searchQuery: '',
    selectedStatus: null,
    selectedType: null,
    errorMessage: null,
    operationMessage: null,
  );

  factory RequestsState.loading({
    String searchQuery = '',
    PortalRequestStatus? selectedStatus,
    RequestType? selectedType,
  }) => RequestsState._(
    status: RequestsStatus.loading,
    requests: const [],
    visibleRequests: const [],
    searchQuery: searchQuery,
    selectedStatus: selectedStatus,
    selectedType: selectedType,
    errorMessage: null,
    operationMessage: null,
  );

  factory RequestsState.success({
    required List<PortalRequest> requests,
    String searchQuery = '',
    PortalRequestStatus? selectedStatus,
    RequestType? selectedType,
    String? operationMessage,
  }) {
    final query = searchQuery.trim().toLowerCase();
    final visible = requests
        .where((request) {
          final matchesQuery =
              query.isEmpty ||
              request.title.toLowerCase().contains(query) ||
              request.referenceNumber.toLowerCase().contains(query) ||
              request.description.toLowerCase().contains(query);
          final matchesStatus = selectedStatus == null || request.status == selectedStatus;
          final matchesType = selectedType == null || request.type == selectedType;
          return matchesQuery && matchesStatus && matchesType;
        })
        .toList(growable: false);

    return RequestsState._(
      status: RequestsStatus.success,
      requests: requests,
      visibleRequests: visible,
      searchQuery: query,
      selectedStatus: selectedStatus,
      selectedType: selectedType,
      errorMessage: null,
      operationMessage: operationMessage,
    );
  }

  factory RequestsState.empty() => RequestsState._(
    status: RequestsStatus.empty,
    requests: const [],
    visibleRequests: const [],
    searchQuery: '',
    selectedStatus: null,
    selectedType: null,
    errorMessage: null,
    operationMessage: null,
  );

  factory RequestsState.failure(String message) => RequestsState._(
    status: RequestsStatus.failure,
    requests: const [],
    visibleRequests: const [],
    searchQuery: '',
    selectedStatus: null,
    selectedType: null,
    errorMessage: message,
    operationMessage: null,
  );

  factory RequestsState.submitting({
    required List<PortalRequest> requests,
    String searchQuery = '',
    PortalRequestStatus? selectedStatus,
    RequestType? selectedType,
  }) => RequestsState._(
    status: RequestsStatus.submitting,
    requests: requests,
    visibleRequests: requests,
    searchQuery: searchQuery,
    selectedStatus: selectedStatus,
    selectedType: selectedType,
    errorMessage: null,
    operationMessage: null,
  );

  final RequestsStatus status;
  final List<PortalRequest> requests;
  final List<PortalRequest> visibleRequests;
  final String searchQuery;
  final PortalRequestStatus? selectedStatus;
  final RequestType? selectedType;
  final String? errorMessage;
  final String? operationMessage;

  bool get isLoading => status == RequestsStatus.loading;
  bool get isSubmitting => status == RequestsStatus.submitting;
  bool get isEmpty => status == RequestsStatus.empty;
  bool get hasFailure => status == RequestsStatus.failure;
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty || selectedStatus != null || selectedType != null;
  bool get hasNoMatchingRequests => status == RequestsStatus.success && visibleRequests.isEmpty;

  RequestsState withFilters({
    String? searchQuery,
    PortalRequestStatus? selectedStatus,
    RequestType? selectedType,
  }) {
    return RequestsState.success(
      requests: requests,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus,
      selectedType: selectedType,
      operationMessage: operationMessage,
    );
  }
}
