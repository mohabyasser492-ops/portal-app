namespace PortalApp.Infrastructure.Graph;

public sealed record GraphRequestContext(
    string CorrelationId,
    string? UserObjectId,
    CancellationToken CancellationToken);