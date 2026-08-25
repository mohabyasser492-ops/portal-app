namespace PortalApp.Infrastructure.Graph;

public sealed record GraphPage<T>(
    IReadOnlyList<T> Items,
    string? NextLink)
{
    public bool HasNextPage =>
        !string.IsNullOrWhiteSpace(NextLink);
}