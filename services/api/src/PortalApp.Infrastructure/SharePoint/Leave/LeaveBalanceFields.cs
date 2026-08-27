namespace PortalApp.Infrastructure.SharePoint.Leave;

public static class LeaveBalanceFields
{
    public const string EmployeeId = "EmployeeId";

    public const string LeaveType = "LeaveType";

    public const string EntitledDays = "EntitledDays";

    public const string UsedDays = "UsedDays";

    public const string PendingDays = "PendingDays";

    public const string RemainingDays = "RemainingDays";

    public const string BalanceYear = "BalanceYear";

    public const string LastUpdated = "LastUpdated";

    public static IReadOnlyCollection<string> All { get; } =
    [
        EmployeeId,
        LeaveType,
        EntitledDays,
        UsedDays,
        PendingDays,
        RemainingDays,
        BalanceYear,
        LastUpdated
    ];
}