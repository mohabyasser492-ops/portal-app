namespace PortalApp.Infrastructure.SharePoint.Attendance;

public static class AttendanceFields
{
    public const string EmployeeId = "EmployeeId";

    public const string AttendanceDate = "AttendanceDate";

    public const string CheckIn = "CheckIn";

    public const string CheckOut = "CheckOut";

    public const string Status = "Status";

    public const string WorkedMinutes = "WorkedMinutes";

    public const string Notes = "Notes";

    public const string LastUpdated = "LastUpdated";

    public static IReadOnlyCollection<string> All { get; } =
    [
        EmployeeId,
        AttendanceDate,
        CheckIn,
        CheckOut,
        Status,
        WorkedMinutes,
        Notes,
        LastUpdated
    ];
}