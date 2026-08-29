namespace PortalApp.Api.FileSecurity;

public sealed class FileSecurityOptions
{
    public const string SectionName =
        "Files";

    public const long DefaultMaximumSizeBytes =
        25L * 1024L * 1024L;

    public long MaximumSizeBytes
    {
        get;
        init;
    } = DefaultMaximumSizeBytes;

    public string[] AllowedExtensions
    {
        get;
        init;
    } =
    [
        ".pdf"
    ];

    public string[] AllowedContentTypes
    {
        get;
        init;
    } =
    [
        "application/pdf"
    ];

    public bool IsValid =>
        MaximumSizeBytes > 0 &&
        AllowedExtensions is
        {
            Length: > 0
        } &&
        AllowedContentTypes is
        {
            Length: > 0
        } &&
        AllowedExtensions.All(
            IsValidExtension) &&
        AllowedContentTypes.All(
            IsValidContentType);

    private static bool IsValidExtension(
        string? extension)
    {
        if (string.IsNullOrWhiteSpace(extension))
        {
            return false;
        }

        var normalized =
            extension.Trim();

        if (!normalized.StartsWith(
                ".",
                StringComparison.Ordinal))
        {
            return false;
        }

        if (normalized.Length < 2 ||
            normalized.Length > 16)
        {
            return false;
        }

        return normalized
            .Skip(1)
            .All(char.IsLetterOrDigit);
    }

    private static bool IsValidContentType(
        string? contentType)
    {
        if (string.IsNullOrWhiteSpace(contentType))
        {
            return false;
        }

        var normalized =
            contentType.Trim();

        if (normalized.Length > 128 ||
            normalized.Any(
                char.IsControl))
        {
            return false;
        }

        var separatorIndex =
            normalized.IndexOf(
                '/',
                StringComparison.Ordinal);

        return separatorIndex > 0 &&
               separatorIndex <
               normalized.Length - 1 &&
               normalized.IndexOf(
                   '/',
                   separatorIndex + 1) < 0;
    }
}