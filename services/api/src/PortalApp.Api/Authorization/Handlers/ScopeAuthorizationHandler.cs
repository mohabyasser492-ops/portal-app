using Microsoft.AspNetCore.Authorization;
using PortalApp.Api.Authorization.Requirements;

namespace PortalApp.Api.Authorization.Handlers;

public sealed class ScopeAuthorizationHandler
    : AuthorizationHandler<ScopeRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        ScopeRequirement requirement)
    {
        var grantedScopes = context.User
            .FindAll("scp")
            .SelectMany(claim => claim.Value.Split(
                ' ',
                StringSplitOptions.RemoveEmptyEntries |
                StringSplitOptions.TrimEntries));

        if (grantedScopes.Contains(
                requirement.Scope,
                StringComparer.Ordinal))
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}