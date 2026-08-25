using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Authorization;
using PortalApp.Api.Authorization.Policies;

namespace PortalApp.Api.Controllers.Me;

[ApiController]
[Route("api/v1/security/session")]
public sealed class SecuritySessionController : ControllerBase
{
    private readonly ICurrentUser _currentUser;

    public SecuritySessionController(
        ICurrentUser currentUser)
    {
        _currentUser = currentUser;
    }

    [HttpGet]
    [Authorize(Policy = PortalPolicies.EmployeeAccess)]
    [ProducesResponseType<SecuritySessionResponse>(
        StatusCodes.Status200OK)]
    [ProducesResponseType(
        StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(
        StatusCodes.Status403Forbidden)]
    public ActionResult<SecuritySessionResponse> Get()
    {
        return Ok(new SecuritySessionResponse(
            ObjectId: _currentUser.ObjectId,
            TenantId: _currentUser.TenantId,
            DisplayName: _currentUser.DisplayName,
            Username: _currentUser.Username,
            Roles: _currentUser.Roles));
    }
}

public sealed record SecuritySessionResponse(
    string? ObjectId,
    string? TenantId,
    string? DisplayName,
    string? Username,
    IReadOnlyCollection<string> Roles);