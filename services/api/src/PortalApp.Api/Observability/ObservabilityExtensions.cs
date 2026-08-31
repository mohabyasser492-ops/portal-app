using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace PortalApp.Api.Observability;

public static class ObservabilityExtensions
{
    public static IServiceCollection AddPortalObservability(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        services
            .AddOptions<ObservabilityOptions>()
            .Bind(configuration.GetSection(ObservabilityOptions.SectionName))
            .Validate(options => options.IsValid, "The observability configuration is invalid.")
            .ValidateOnStart();

        services.AddHealthChecks()
            .AddCheck(
                "self",
                () => HealthCheckResult.Healthy(),
                tags: ["live"])
            .AddCheck(
                "ready",
                () => HealthCheckResult.Healthy(),
                tags: ["ready"]);

        return services;
    }

    public static IApplicationBuilder UsePortalObservability(
        this IApplicationBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);
        return app.UseMiddleware<RequestObservabilityMiddleware>();
    }

    public static IEndpointRouteBuilder MapPortalHealthChecks(
        this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapHealthChecks(
            "/health/live",
            new HealthCheckOptions
            {
                Predicate = registration => registration.Tags.Contains("live")
            }).AllowAnonymous();

        endpoints.MapHealthChecks(
            "/health/ready",
            new HealthCheckOptions
            {
                Predicate = registration => registration.Tags.Contains("ready")
            }).AllowAnonymous();

        return endpoints;
    }
}