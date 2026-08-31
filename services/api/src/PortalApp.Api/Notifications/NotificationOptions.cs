namespace PortalApp.Api.Notifications;

public sealed class NotificationOptions
{
    public const string SectionName = "Notifications";
    public bool Enabled { get; init; }
    public int MaximumDevicesPerUser { get; init; } = 10;
    public int MaximumTokenLength { get; init; } = 4096;
    public bool IsValid =>
        MaximumDevicesPerUser is > 0 and <= 25 &&
        MaximumTokenLength is >= 32 and <= 8192;
}