using PortalApp.Infrastructure.SharePoint.Attendance;

namespace PortalApp.Api.Features.Attendance;

public sealed record AttendanceItemResponse(
    DateOnly AttendanceDate,
    DateTimeOffset? CheckIn,
    DateTimeOffset? CheckOut,
    AttendanceStatus Status,
    int? WorkedMinutes,
    string? Notes,
    DateTimeOffset? LastUpdated);

public sealed record AttendanceSummaryResponse(
    int TotalRecords,
    int PresentDays,
    int AbsentDays,
    int LateDays,
    int RemoteDays,
    int LeaveDays,
    int HolidayDays,
    int TotalWorkedMinutes);

public sealed record AttendanceResponse(
    string EmployeeId,
    DateOnly FromDate,
    DateOnly ToDate,
    AttendanceSummaryResponse Summary,
    IReadOnlyList<AttendanceItemResponse> Records);