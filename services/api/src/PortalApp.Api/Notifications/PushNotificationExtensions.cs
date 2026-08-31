using Microsoft.Extensions.Options;

namespace PortalApp.Api.Notifications;

public static class PushNotificationExtensions
{
    public static IServiceCollection AddPortalPushNotifications(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services
            .AddOptions<NotificationOptions>()
            .Bind(configuration.GetSection(NotificationOptions.SectionName))
            .Validate(options => options.IsValid, "The notification configuration is invalid.")
            .ValidateOnStart();

        services.AddSingleton(TimeProvider.System);
        services.AddSingleton<IPushDeviceStore, InMemoryPushDeviceStore>();
        services.AddScoped<IPushDeviceService, PushDeviceService>();
        services.AddSingleton<IPushNotificationSender, DisabledPushNotificationSender>();
        return services;
    }
}