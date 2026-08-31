namespace PortalApp.Api.Idempotency;

public sealed record IdempotencyRecord(
    string Fingerprint,
    int StatusCode,
    string? ContentType,
    byte[] Body,
    DateTimeOffset ExpiresAt);

public enum IdempotencyAcquireStatus
{
    Acquired,
    Replay,
    Conflict
}

public sealed record IdempotencyAcquireResult(
    IdempotencyAcquireStatus Status,
    IdempotencyRecord? Record,
    Task<IdempotencyRecord?>? Pending);