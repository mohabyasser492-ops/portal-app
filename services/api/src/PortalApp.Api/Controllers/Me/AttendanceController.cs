using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Authorization.Policies;
using PortalApp.Api.Features.Attendance;

namespace PortalApp.Api.Controllers.Me;

[ApiController]
[Route("api/v1/me/attendance")]
public sealed class AttendanceController
    : ControllerBase
{
    private readonly IAttendanceService
        _attendanceService;

    public AttendanceController(
        IAttendanceService attendanceService)
    {
        _attendanceService =
            attendanceService;
    }

    [HttpGet]
    [Authorize(
        Policy =
            PortalPolicies.EmployeeAccess)]
    [ProducesResponseType<AttendanceResponse>(
        StatusCodes.Status200OK)]
    [ProducesResponseType(
        StatusCodes.Status400BadRequest)]
    [ProducesResponseType(
        StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(
        StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<
        AttendanceResponse>> Get(
        [FromQuery] DateOnly? fromDate,
        [FromQuery] DateOnly? toDate,
        CancellationToken cancellationToken)
    {
        var result =
            await _attendanceService
                .GetCurrentAsync(
                    fromDate,
                    toDate,
                    HttpContext.TraceIdentifier,
                    cancellationToken);

        return Ok(result);
    }
}