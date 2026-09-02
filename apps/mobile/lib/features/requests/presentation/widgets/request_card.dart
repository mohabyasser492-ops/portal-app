import 'package:flutter/material.dart';
import '../../../../app/theme/portal_design_system.dart';
import '../../domain/portal_request.dart';
import '../../domain/request_type.dart';
import 'request_status_badge.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({required this.request, this.onTap, super.key});
  final PortalRequest request;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(PortalSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: PortalColors.brand50,
                  borderRadius: BorderRadius.circular(PortalRadius.md),
                ),
                child: const Padding(
                  padding: EdgeInsetsDirectional.all(PortalSpacing.sm),
                  child: Icon(Icons.description_outlined, color: PortalColors.actionPrimary),
                ),
              ),
              const SizedBox(width: PortalSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            request.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        RequestStatusBadge(status: request.status),
                      ],
                    ),
                    const SizedBox(height: PortalSpacing.xs),
                    Text(
                      '${request.referenceNumber} • ${_typeLabel(request.type)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: PortalSpacing.sm),
                    Text(
                      request.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: PortalSpacing.sm),
                    Text(
                      'Updated ${_date(request.updatedAt)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: PortalSpacing.sm,
                    top: PortalSpacing.xs,
                  ),
                  child: Icon(Icons.chevron_right, color: PortalColors.textSecondary),
                ),
            ],
          ),
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

  static String _date(DateTime value) {
    final d = value.toLocal();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}
