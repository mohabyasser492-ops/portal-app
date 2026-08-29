using PortalApp.Infrastructure.Graph;

namespace PortalApp.Api.FileSecurity;

public interface IFileSecurityValidator
{
    Task<string> ValidateDownloadAsync(
        GraphFileContent file,
        string fallbackFileName,
        CancellationToken cancellationToken);
}