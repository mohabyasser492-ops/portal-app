using PortalApp.Infrastructure.Graph;

namespace PortalApp.Api.Configuration;

public static class GraphExtensions
{
    public static IServiceCollection AddPortalGraph(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services
            .AddOptions<GraphOptions>()
            .Bind(
                configuration.GetSection(
                    GraphOptions.SectionName))
            .Validate(
                options => options.IsConfigured,
                "The Microsoft Graph configuration is incomplete.")
            .ValidateOnStart();

        return services;
    }
}