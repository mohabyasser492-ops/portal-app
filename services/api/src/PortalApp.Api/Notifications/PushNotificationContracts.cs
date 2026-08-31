namespace PortalApp.Api.Notifications;

public interface IPushDeviceStore
{
    Task<IReadOnlyList<PushDeviceRegistration>> GetForUserAsync(
        string userObjectId,
        CancellationToken cancellationToken);

    Task<PushDeviceRegistration> UpsertAsync(
        PushDeviceRegistration registration,
        int maximumDevicesPerUser,
        CancellationToken cancellationToken);

    Task<bool> RemoveAsync(
        string userObjectId,
        string registrationId,
        CancellationToken cancellationToken);
}

public interface IPushDeviceService
{
    Task<PushDevicesResponse> GetCurrentAsync(CancellationToken cancellationToken);
    Task<PushDeviceResponse> RegisterCurrentAsync(
        RegisterPushDeviceRequest request,
        CancellationToken cancellationToken);
    Task<bool> RemoveCurrentAsync(
        string registrationId,
        CancellationToken cancellationToken);
}

public interface IPushNotificationSender
{
    Task SendAsync(
        string userObjectId,
        string title,
        string body,
        IReadOnlyDictionary<string, string>? data,
        CancellationToken cancellationToken);
}