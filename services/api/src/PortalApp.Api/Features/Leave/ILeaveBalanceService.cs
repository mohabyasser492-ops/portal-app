namespace PortalApp.Api.Features.Leave;

public interface ILeaveBalanceService
{
    Task<LeaveBalanceResponse> GetCurrentAsync(
        string correlationId,
        CancellationToken cancellationToken);
}