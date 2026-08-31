namespace PortalApp.Api.Observability;

public sealed class ObservabilityOptions
{
    public const string SectionName = "Observability";
    public const int DefaultSlowRequestThresholdMilliseconds = 1000;

    public int SlowRequestThresholdMilliseconds { get; init; } =
        DefaultSlowRequestThresholdMilliseconds;

    public bool IncludeResponseHeaders { get; init; } = true;

    public bool IsValid =>
        SlowRequestThresholdMilliseconds is >= 100 and <= 60000;
}