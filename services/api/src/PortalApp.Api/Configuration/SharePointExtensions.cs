using PortalApp.Infrastructure.SharePoint;

namespace PortalApp.Api.Configuration;

public static class SharePointExtensions
{
    public static IServiceCollection AddPortalSharePoint(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services
            .AddOptions<SharePointOptions>()
            .Bind(
                configuration.GetSection(
                    SharePointOptions.SectionName))
            .Validate(
                options => options.IsConfigured,
                "The SharePoint configuration is incomplete.")
            .ValidateOnStart();

        return services;
    }
}