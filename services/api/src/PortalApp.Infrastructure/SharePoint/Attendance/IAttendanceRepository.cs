using PortalApp.Infrastructure.Graph;

namespace PortalApp.Infrastructure.SharePoint.Attendance;

public interface IAttendanceRepository
{
    Task<IReadOnlyList<AttendanceRecord>>
        GetForEmployeeAsync(
            string employeeId,
            DateOnly fromDate,
            DateOnly toDate,
            GraphRequestContext context);
}