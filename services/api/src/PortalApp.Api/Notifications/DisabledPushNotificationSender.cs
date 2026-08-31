namespace PortalApp.Api.Notifications;

public sealed class DisabledPushNotificationSender : IPushNotificationSender
{
    private readonly ILogger<DisabledPushNotificationSender> _logger;

    public DisabledPushNotificationSender(ILogger<DisabledPushNotificationSender> logger)
    {
        _logger = logger;
    }

    public Task SendAsync(
        string userObjectId,
        string title,
        string body,
        IReadOnlyDictionary<string, string>? data,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        _logger.LogInformation(
            "Push delivery is disabled. Notification for user {UserObjectId} was not sent.",
            userObjectId);
        return Task.CompletedTask;
    }
}