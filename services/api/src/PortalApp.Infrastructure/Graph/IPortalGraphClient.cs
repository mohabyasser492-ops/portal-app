namespace PortalApp.Infrastructure.Graph;

public interface IPortalGraphClient
{
    Task<GraphPage<T>> GetPageAsync<T>(
        string relativePath,
        GraphRequestContext context);

    Task<T?> GetAsync<T>(
        string relativePath,
        GraphRequestContext context);

    Task<GraphFileContent> DownloadAsync(
        string relativePath,
        GraphRequestContext context);
}