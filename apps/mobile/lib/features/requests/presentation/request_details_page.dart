import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/portal_design_system.dart';
import '../application/requests_controller.dart';
import '../domain/portal_request.dart';
import '../domain/request_type.dart';
import 'widgets/request_status_badge.dart';

class RequestDetailsPage extends ConsumerWidget {
  const RequestDetailsPage({required this.requestId, super.key});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(
      requestsControllerProvider.select((state) {
        for (final item in state.requests) {
          if (item.id == requestId) return item;
        }
        return null;
      }),
    );

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request')),
        body: const Center(child: Text('Request not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(request.referenceNumber)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(PortalSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      RequestStatusBadge(status: request.status),
                    ],
                  ),
                  const SizedBox(height: PortalSpacing.sm),
                  Text(request.referenceNumber, style: Theme.of(context).textTheme.bodySmall),
                  const Divider(height: PortalSpacing.xl),
                  _InfoRow(label: 'Type', value: _typeLabel(request.type)),
                  const SizedBox(height: PortalSpacing.md),
                  _InfoRow(label: 'Created', value: _formatDate(request.createdAt)),
                  const SizedBox(height: PortalSpacing.md),
                  _InfoRow(label: 'Last updated', value: _formatDate(request.updatedAt)),
                  const SizedBox(height: PortalSpacing.lg),
                  Text('Description', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: PortalSpacing.xs),
                  Text(request.description, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          if (request.canCancel) ...[
            const SizedBox(height: PortalSpacing.md),
            OutlinedButton.icon(
              onPressed: () => _confirmCancel(context, ref, request),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel request'),
              style: OutlinedButton.styleFrom(foregroundColor: PortalColors.actionDestructive),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref, PortalRequest request) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel request?'),
        content: Text('This will cancel ${request.referenceNumber}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep request'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (shouldCancel != true || !context.mounted) return;
    final updated = await ref.read(requestsControllerProvider.notifier).cancelRequest(request);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated == null
              ? 'Unable to cancel the request.'
              : '${request.referenceNumber} cancelled.',
        ),
      ),
    );
  }

  static String _typeLabel(RequestType type) => switch (type) {
    RequestType.leave => 'Leave',
    RequestType.employmentLetter => 'Employment letter',
    RequestType.salaryCertificate => 'Salary certificate',
    RequestType.profileUpdate => 'Profile update',
    RequestType.payrollInquiry => 'Payroll inquiry',
    RequestType.generalInquiry => 'General inquiry',
  };

  static String _formatDate(DateTime value) {
    final d = value.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 110, child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
      Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
    ],
  );
}
