using System.Security.Claims;

namespace PortalApp.Api.Authorization;

public sealed class HttpCurrentUser : ICurrentUser
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public HttpCurrentUser(
        IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public ClaimsPrincipal Principal =>
        _httpContextAccessor.HttpContext?.User ??
        new ClaimsPrincipal(
            new ClaimsIdentity());

    public bool IsAuthenticated =>
        Principal.Identity?.IsAuthenticated == true;

    public string? ObjectId =>
        FindFirstValue("oid") ??
        FindFirstValue(ClaimTypes.NameIdentifier) ??
        FindFirstValue("sub");

    public string? TenantId =>
        FindFirstValue("tid");

    public string? DisplayName =>
        FindFirstValue("name") ??
        FindFirstValue(ClaimTypes.Name);

    public string? Username =>
        FindFirstValue("preferred_username") ??
        FindFirstValue("upn") ??
        FindFirstValue(ClaimTypes.Upn) ??
        FindFirstValue(ClaimTypes.Email);

    public IReadOnlyCollection<string> Roles =>
        Principal
            .FindAll("roles")
            .Select(claim => claim.Value)
            .Concat(
                Principal
                    .FindAll(ClaimTypes.Role)
                    .Select(claim => claim.Value))
            .Where(role => !string.IsNullOrWhiteSpace(role))
            .Distinct(StringComparer.Ordinal)
            .ToArray();

    private string? FindFirstValue(string claimType)
    {
        return Principal.FindFirst(claimType)?.Value;
    }
}