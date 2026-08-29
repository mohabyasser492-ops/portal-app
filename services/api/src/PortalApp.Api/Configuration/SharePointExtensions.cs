using PortalApp.Api.Features.Leave;
using PortalApp.Infrastructure.SharePoint;
using PortalApp.Infrastructure.SharePoint.Leave;

namespace PortalApp.Api.Configuration;

public static class SharePointExtensions
{
    public static IServiceCollection
        AddPortalSharePoint(
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

        services.AddSingleton<
            LeaveBalanceMapper>();

        services.AddScoped<
            ILeaveBalanceRepository,
            LeaveBalanceRepository>();

        services.AddScoped<
            CurrentEmployeeIdentifierResolver>();

        services.AddScoped<
            ILeaveBalanceService,
            LeaveBalanceService>();

        return services;
    }
}