using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Identity.Web;
using PortalApp.Api.Authorization;
using PortalApp.Api.Authorization.Handlers;
using PortalApp.Api.Authorization.Policies;
using PortalApp.Api.Authorization.Requirements;

namespace PortalApp.Api.Configuration;

public static class ApiSecurityExtensions
{
    public static IServiceCollection AddPortalApiSecurity(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var entraSection = configuration.GetSection(
            EntraOptions.SectionName);

        services
            .AddOptions<EntraOptions>()
            .Bind(entraSection)
            .Validate(
                options => options.IsConfigured,
                "The Entra configuration is incomplete.")
            .ValidateOnStart();

        services
            .AddAuthentication(
                JwtBearerDefaults.AuthenticationScheme)
            .AddMicrosoftIdentityWebApi(
                entraSection,
                jwtBearerScheme:
                    JwtBearerDefaults.AuthenticationScheme);

        var requiredScope =
            entraSection[nameof(EntraOptions.RequiredScope)] ??
            "access_as_user";

        services.AddAuthorization(options =>
        {
            options.FallbackPolicy =
                new AuthorizationPolicyBuilder()
                    .RequireAuthenticatedUser()
                    .Build();

            options.AddPolicy(
                PortalPolicies.EmployeeAccess,
                policy =>
                {
                    policy.RequireAuthenticatedUser();
                    policy.AddRequirements(
                        new ScopeRequirement(requiredScope));
                });

            options.AddPolicy(
                PortalPolicies.ManagerAccess,
                policy =>
                {
                    policy.RequireAuthenticatedUser();
                    policy.RequireRole(
                        PortalRoles.Manager,
                        PortalRoles.Administrator);
                });

            options.AddPolicy(
                PortalPolicies.AdministratorAccess,
                policy =>
                {
                    policy.RequireAuthenticatedUser();
                    policy.RequireRole(
                        PortalRoles.Administrator);
                });

            options.AddPolicy(
                PortalPolicies.SecurityOperatorAccess,
                policy =>
                {
                    policy.RequireAuthenticatedUser();
                    policy.RequireRole(
                        PortalRoles.SecurityOperator,
                        PortalRoles.Administrator);
                });
        });

        services.AddSingleton<
            IAuthorizationHandler,
            ScopeAuthorizationHandler>();

        services.AddHttpContextAccessor();

        services.AddScoped<
            ICurrentUser,
            HttpCurrentUser>();

        return services;
    }
}