namespace PortalApp.Api.FileSecurity;

public sealed class FileSecurityValidationException : Exception
{
    public FileSecurityValidationException(string message)
        : base(message)
    {
    }
}