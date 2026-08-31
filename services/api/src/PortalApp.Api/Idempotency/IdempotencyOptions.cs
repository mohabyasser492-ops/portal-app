namespace PortalApp.Api.Idempotency;

public sealed class IdempotencyOptions
{
    public const string SectionName = "Idempotency";
    public int RetentionMinutes { get; init; } = 60;
    public int MaximumKeyLength { get; init; } = 128;
    public int MaximumBodyBytes { get; init; } = 1_048_576;
    public bool IsValid =>
        RetentionMinutes is >= 1 and <= 1440 &&
        MaximumKeyLength is >= 16 and <= 256 &&
        MaximumBodyBytes is >= 1024 and <= 10_485_760;
}