using Microsoft.AspNetCore.Authorization;

namespace PortalApp.Api.Authorization.Requirements;

public sealed class ScopeRequirement : IAuthorizationRequirement
{
    public ScopeRequirement(string scope)
    {
        if (string.IsNullOrWhiteSpace(scope))
        {
            throw new ArgumentException(
                "An authorization scope is required.",
                nameof(scope));
        }

        Scope = scope;
    }

    public string Scope { get; }
}