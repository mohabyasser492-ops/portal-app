namespace PortalApp.Api.Cancellation;

public sealed class RequestCancellationOptions
{
    public const string SectionName = "RequestCancellation";
    public const int DefaultTimeoutSeconds = 30;
    public const int MaximumTimeoutSeconds = 300;

    public int TimeoutSeconds { get; init; } = DefaultTimeoutSeconds;

    public bool IsValid =>
        TimeoutSeconds is > 0 and <= MaximumTimeoutSeconds;
}