using PortalApp.Api.Graph;
using PortalApp.Infrastructure.Graph;

namespace PortalApp.Api.Configuration;

public static class GraphExtensions
{
    public static IServiceCollection AddPortalGraph(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var section =
            configuration.GetSection(
                GraphOptions.SectionName);

        services
            .AddOptions<GraphOptions>()
            .Bind(section)
            .Validate(
                options => options.IsConfigured,
                "The Microsoft Graph configuration is incomplete.")
            .ValidateOnStart();

        var requestTimeoutSeconds =
            section.GetValue<int?>(
                nameof(
                    GraphOptions.RequestTimeoutSeconds)) ??
            30;

        services.AddHttpClient(
            PortalGraphClient.ClientName,
            client =>
            {
                client.Timeout =
                    TimeSpan.FromSeconds(
                        requestTimeoutSeconds);
            });

        services.AddScoped<
            IGraphAccessTokenProvider,
            DelegatedGraphAccessTokenProvider>();

        services.AddScoped<
            IPortalGraphClient,
            PortalGraphClient>();

        return services;
    }
}