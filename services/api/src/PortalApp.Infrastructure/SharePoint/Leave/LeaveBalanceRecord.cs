namespace PortalApp.Infrastructure.SharePoint.Leave;

public sealed record LeaveBalanceRecord(
    string SharePointItemId,
    string? ETag,
    string EmployeeId,
    string LeaveType,
    decimal EntitledDays,
    decimal UsedDays,
    decimal PendingDays,
    decimal RemainingDays,
    int BalanceYear,
    DateTimeOffset? LastUpdated);