import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/portal_route_paths.dart';
import '../../../app/theme/portal_design_system.dart';
import '../../../core/widgets/feedback/portal_empty_state.dart';
import '../../../core/widgets/feedback/portal_error_state.dart';
import '../../../core/widgets/feedback/portal_skeleton.dart';
import '../application/requests_controller.dart';
import '../application/requests_state.dart';
import '../application/requests_status.dart';
import '../domain/portal_request_status.dart';
import '../domain/request_type.dart';
import 'widgets/request_card.dart';
import 'widgets/requests_filter_bar.dart';

class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(requestsControllerProvider.notifier).loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestsControllerProvider);
    return SafeArea(
      child: switch (state.status) {
        RequestsStatus.initial || RequestsStatus.loading => const _RequestsLoadingView(),
        RequestsStatus.empty => _RequestsEmptyView(onCreate: _createRequest),
        RequestsStatus.failure => _RequestsFailureView(
          message: state.errorMessage ?? 'Unable to load requests.',
          onRetry: _retry,
        ),
        RequestsStatus.submitting || RequestsStatus.success => _RequestsContent(
          state: state,
          onRefresh: _refresh,
          onCreate: _createRequest,
          onOpen: _openRequest,
          onSearchChanged: _updateSearch,
          onStatusSelected: _selectStatus,
          onTypeSelected: _selectType,
          onClearFilters: _clearFilters,
        ),
      },
    );
  }

  Future<void> _refresh() => ref.read(requestsControllerProvider.notifier).loadRequests();
  void _retry() => ref.read(requestsControllerProvider.notifier).retry();

  Future<void> _createRequest() async {
    await context.push('${PortalRoutePaths.requests}/create');
  }

  void _openRequest(String id) {
    context.push('${PortalRoutePaths.requests}/$id');
  }

  void _updateSearch(String value) {
    ref.read(requestsControllerProvider.notifier).updateSearchQuery(value);
  }

  void _selectStatus(PortalRequestStatus? value) {
    ref.read(requestsControllerProvider.notifier).selectStatus(value);
  }

  void _selectType(RequestType? value) {
    ref.read(requestsControllerProvider.notifier).selectType(value);
  }

  void _clearFilters() {
    ref.read(requestsControllerProvider.notifier).clearFilters();
  }
}

class _RequestsContent extends StatelessWidget {
  const _RequestsContent({
    required this.state,
    required this.onRefresh,
    required this.onCreate,
    required this.onOpen,
    required this.onSearchChanged,
    required this.onStatusSelected,
    required this.onTypeSelected,
    required this.onClearFilters,
  });
  final RequestsState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreate;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PortalRequestStatus?> onStatusSelected;
  final ValueChanged<RequestType?> onTypeSelected;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Requests', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: PortalSpacing.xs),
                    Text(
                      'Track requests you have submitted through Portal.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: PortalColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PortalSpacing.sm),
              FilledButton.icon(
                onPressed: state.isSubmitting ? null : onCreate,
                icon: const Icon(Icons.add),
                label: const Text('New request'),
              ),
            ],
          ),
          const SizedBox(height: PortalSpacing.xl),
          TextField(
            key: const ValueKey('requests-search-field'),
            enabled: !state.isSubmitting,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              labelText: 'Search requests',
              hintText: 'Search by title, reference, or description',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: PortalSpacing.md),
          RequestsFilterBar(
            selectedStatus: state.selectedStatus,
            selectedType: state.selectedType,
            onStatusSelected: onStatusSelected,
            onTypeSelected: onTypeSelected,
            onClear: onClearFilters,
            enabled: !state.isSubmitting,
          ),
          const SizedBox(height: PortalSpacing.lg),
          Text(
            '${state.visibleRequests.length} of ${state.requests.length} requests',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: PortalSpacing.sm),
          if (state.hasNoMatchingRequests)
            PortalEmptyState(
              title: 'No matching requests',
              description: 'Try another search or remove one of the filters.',
              icon: Icons.search_off_outlined,
              actionLabel: 'Clear filters',
              onAction: onClearFilters,
            )
          else
            ...state.visibleRequests.map(
              (request) => Padding(
                padding: const EdgeInsetsDirectional.only(bottom: PortalSpacing.md),
                child: RequestCard(request: request, onTap: () => onOpen(request.id)),
              ),
            ),
        ],
      ),
    );
  }
}

class _RequestsLoadingView extends StatelessWidget {
  const _RequestsLoadingView();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
    children: const [
      PortalSkeleton(width: 180, height: 32, animate: false),
      SizedBox(height: PortalSpacing.sm),
      PortalSkeleton(width: 300, height: 20, animate: false),
      SizedBox(height: PortalSpacing.xl),
      PortalSkeleton(width: double.infinity, height: 56, animate: false),
      SizedBox(height: PortalSpacing.lg),
      PortalSkeleton(width: double.infinity, height: 120, animate: false),
      SizedBox(height: PortalSpacing.md),
      PortalSkeleton(width: double.infinity, height: 120, animate: false),
    ],
  );
}

class _RequestsEmptyView extends StatelessWidget {
  const _RequestsEmptyView({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
    children: [
      PortalEmptyState(
        title: 'No requests yet',
        description: 'Create your first employee request to start tracking it here.',
        icon: Icons.description_outlined,
        actionLabel: 'Create request',
        onAction: onCreate,
      ),
    ],
  );
}

class _RequestsFailureView extends StatelessWidget {
  const _RequestsFailureView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
    children: [
      PortalErrorState(
        title: 'Unable to load requests',
        description: message,
        retryLabel: 'Try again',
        onRetry: onRetry,
      ),
    ],
  );
}
