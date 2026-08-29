namespace PortalApp.Api.Features.Attendance;

public sealed record AttendanceQuery(
    DateOnly FromDate,
    DateOnly ToDate);