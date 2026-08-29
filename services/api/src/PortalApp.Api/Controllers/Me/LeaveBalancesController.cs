using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Authorization.Policies;
using PortalApp.Api.Features.Leave;

namespace PortalApp.Api.Controllers.Me;

[ApiController]
[Route("api/v1/me/leave-balances")]
public sealed class LeaveBalancesController
    : ControllerBase
{
    private readonly ILeaveBalanceService
        _leaveBalanceService;

    public LeaveBalancesController(
        ILeaveBalanceService leaveBalanceService)
    {
        _leaveBalanceService =
            leaveBalanceService;
    }

    [HttpGet]
    [Authorize(
        Policy =
            PortalPolicies.EmployeeAccess)]
    [ProducesResponseType<LeaveBalanceResponse>(
        StatusCodes.Status200OK)]
    [ProducesResponseType(
        StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(
        StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<
        LeaveBalanceResponse>> Get(
        CancellationToken cancellationToken)
    {
        var result =
            await _leaveBalanceService
                .GetCurrentAsync(
                    HttpContext.TraceIdentifier,
                    cancellationToken);

        return Ok(result);
    }
}