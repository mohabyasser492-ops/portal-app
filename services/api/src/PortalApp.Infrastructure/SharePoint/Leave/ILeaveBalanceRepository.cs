using PortalApp.Infrastructure.Graph;

namespace PortalApp.Infrastructure.SharePoint.Leave;

public interface ILeaveBalanceRepository
{
    Task<IReadOnlyList<LeaveBalanceRecord>>
        GetForEmployeeAsync(
            string employeeId,
            GraphRequestContext context);
}