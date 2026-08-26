using Microsoft.Identity.Web;
using PortalApp.Infrastructure.Graph;

namespace PortalApp.Api.Graph;

public sealed class DelegatedGraphAccessTokenProvider
    : IGraphAccessTokenProvider
{
    private readonly ITokenAcquisition _tokenAcquisition;

    public DelegatedGraphAccessTokenProvider(
        ITokenAcquisition tokenAcquisition)
    {
        _tokenAcquisition = tokenAcquisition;
    }

    public async Task<string> GetAccessTokenAsync(
        IReadOnlyCollection<string> scopes,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(scopes);

        if (scopes.Count == 0)
        {
            throw new GraphServiceException(
                "At least one Microsoft Graph scope is required.");
        }

        try
        {
            return await _tokenAcquisition
                .GetAccessTokenForUserAsync(
                    scopes)
                .WaitAsync(cancellationToken);
        }

        catch (OperationCanceledException)
            when (cancellationToken.IsCancellationRequested)
        {
            throw;
        }
        catch (Exception exception)
        {
            throw new GraphServiceException(
                "A delegated Microsoft Graph token could not be acquired.",
                innerException: exception);
        }
    }
}