namespace PortalApp.Api.Notifications;

public enum PushPlatform
{
    Android = 1,
    Ios = 2
}

public sealed record RegisterPushDeviceRequest(
    string Token,
    PushPlatform Platform,
    string? DeviceId);

public sealed record PushDeviceResponse(
    string Id,
    PushPlatform Platform,
    string? DeviceId,
    DateTimeOffset RegisteredAt,
    DateTimeOffset LastSeenAt);

public sealed record PushDevicesResponse(
    IReadOnlyList<PushDeviceResponse> Devices);

public sealed record PushDeviceRegistration(
    string Id,
    string UserObjectId,
    string Token,
    PushPlatform Platform,
    string? DeviceId,
    DateTimeOffset RegisteredAt,
    DateTimeOffset LastSeenAt);