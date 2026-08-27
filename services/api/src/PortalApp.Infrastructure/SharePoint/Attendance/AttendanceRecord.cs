namespace PortalApp.Infrastructure.SharePoint.Attendance;

public sealed record AttendanceRecord(
    string SharePointItemId,
    string? ETag,
    string EmployeeId,
    DateOnly AttendanceDate,
    DateTimeOffset? CheckIn,
    DateTimeOffset? CheckOut,
    AttendanceStatus Status,
    int? WorkedMinutes,
    string? Notes,
    DateTimeOffset? LastUpdated)
{
    public TimeSpan? WorkedDuration =>
        WorkedMinutes is null
            ? null
            : TimeSpan.FromMinutes(
                WorkedMinutes.Value);
}