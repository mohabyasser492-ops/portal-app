using System.Security.Claims;

namespace PortalApp.Api.Authorization;

public interface ICurrentUser
{
    bool IsAuthenticated { get; }

    string? ObjectId { get; }

    string? TenantId { get; }

    string? DisplayName { get; }

    string? Username { get; }

    IReadOnlyCollection<string> Roles { get; }

    ClaimsPrincipal Principal { get; }
}