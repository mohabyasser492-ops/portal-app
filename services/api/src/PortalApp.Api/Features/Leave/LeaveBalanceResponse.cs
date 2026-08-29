namespace PortalApp.Api.Features.Leave;

public sealed record LeaveBalanceItemResponse(
    string LeaveType,
    decimal EntitledDays,
    decimal UsedDays,
    decimal PendingDays,
    decimal RemainingDays,
    int BalanceYear,
    DateTimeOffset? LastUpdated);

public sealed record LeaveBalanceResponse(
    string EmployeeId,
    decimal TotalEntitledDays,
    decimal TotalUsedDays,
    decimal TotalPendingDays,
    decimal TotalRemainingDays,
    IReadOnlyList<LeaveBalanceItemResponse> Balances);