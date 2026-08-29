using PortalApp.Api.Authorization;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Leave;

namespace PortalApp.Api.Features.Leave;

public sealed class LeaveBalanceService
    : ILeaveBalanceService
{
    private readonly ICurrentUser _currentUser;
    private readonly CurrentEmployeeIdentifierResolver
        _employeeIdentifierResolver;
    private readonly ILeaveBalanceRepository
        _repository;

    public LeaveBalanceService(
        ICurrentUser currentUser,
        CurrentEmployeeIdentifierResolver
            employeeIdentifierResolver,
        ILeaveBalanceRepository repository)
    {
        _currentUser = currentUser;
        _employeeIdentifierResolver =
            employeeIdentifierResolver;
        _repository = repository;
    }

    public async Task<LeaveBalanceResponse>
        GetCurrentAsync(
            string correlationId,
            CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(
                correlationId))
        {
            throw new ArgumentException(
                "A correlation identifier is required.",
                nameof(correlationId));
        }

        var employeeId =
            _employeeIdentifierResolver.Resolve(
                _currentUser);

        var context =
            new GraphRequestContext(
                correlationId,
                _currentUser.ObjectId,
                cancellationToken);

        var records =
            await _repository.GetForEmployeeAsync(
                employeeId,
                context);

        var items =
            records
                .Select(
                    record =>
                        new LeaveBalanceItemResponse(
                            record.LeaveType,
                            record.EntitledDays,
                            record.UsedDays,
                            record.PendingDays,
                            record.RemainingDays,
                            record.BalanceYear,
                            record.LastUpdated))
                .ToArray();

        return new LeaveBalanceResponse(
            EmployeeId: employeeId,
            TotalEntitledDays:
                items.Sum(
                    item => item.EntitledDays),
            TotalUsedDays:
                items.Sum(
                    item => item.UsedDays),
            TotalPendingDays:
                items.Sum(
                    item => item.PendingDays),
            TotalRemainingDays:
                items.Sum(
                    item => item.RemainingDays),
            Balances: items);
    }
}