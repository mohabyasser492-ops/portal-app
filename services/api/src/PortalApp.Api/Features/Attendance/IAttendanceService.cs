namespace PortalApp.Api.Features.Attendance;

public interface IAttendanceService
{
    Task<AttendanceResponse> GetCurrentAsync(
        DateOnly? fromDate,
        DateOnly? toDate,
        string correlationId,
        CancellationToken cancellationToken);
}