namespace PortalApp.Infrastructure.Graph;

public interface IGraphAccessTokenProvider
{
    Task<string> GetAccessTokenAsync(
        IReadOnlyCollection<string> scopes,
        CancellationToken cancellationToken);
}