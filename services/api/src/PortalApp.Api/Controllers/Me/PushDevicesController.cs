using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Authorization.Policies;
using PortalApp.Api.Notifications;

namespace PortalApp.Api.Controllers.Me;

[ApiController]
[Route("api/v1/me/push-devices")]
[Authorize(Policy = PortalPolicies.EmployeeAccess)]
public sealed class PushDevicesController : ControllerBase
{
    private readonly IPushDeviceService _service;

    public PushDevicesController(IPushDeviceService service)
    {
        _service = service;
    }

    [HttpGet]
    [ProducesResponseType<PushDevicesResponse>(StatusCodes.Status200OK)]
    public async Task<ActionResult<PushDevicesResponse>> Get(CancellationToken cancellationToken) =>
        Ok(await _service.GetCurrentAsync(cancellationToken));

    [HttpPost]
    [ProducesResponseType<PushDeviceResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<PushDeviceResponse>> Register(
        [FromBody] RegisterPushDeviceRequest request,
        CancellationToken cancellationToken) =>
        Ok(await _service.RegisterCurrentAsync(request, cancellationToken));

    [HttpDelete("{registrationId}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Remove(
        string registrationId,
        CancellationToken cancellationToken)
    {
        return await _service.RemoveCurrentAsync(registrationId, cancellationToken)
            ? NoContent()
            : NotFound();
    }
}