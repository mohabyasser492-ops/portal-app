namespace PortalApp.Infrastructure.Graph;

public sealed class GraphFileContent
    : IDisposable,
      IAsyncDisposable
{
    private Stream? _content;
    private IDisposable? _owner;
    private int _disposed;

    public GraphFileContent(
        Stream content,
        string contentType,
        long? contentLength,
        string? eTag,
        string? fileName = null,
        DateTimeOffset? lastModified = null,
        IDisposable? owner = null)
    {
        ArgumentNullException.ThrowIfNull(content);

        if (!content.CanRead)
        {
            throw new ArgumentException(
                "The file content stream must be readable.",
                nameof(content));
        }

        if (string.IsNullOrWhiteSpace(contentType))
        {
            throw new ArgumentException(
                "A content type is required.",
                nameof(contentType));
        }

        if (contentLength is < 0)
        {
            throw new ArgumentOutOfRangeException(
                nameof(contentLength),
                "The content length cannot be negative.");
        }

        _content = content;
        _owner = owner;

        ContentType =
            NormalizeContentType(contentType);

        ContentLength = contentLength;

        ETag =
            NormalizeOptionalValue(eTag);

        FileName =
            NormalizeFileName(fileName);

        LastModified = lastModified;
    }

    public Stream Content
    {
        get
        {
            ObjectDisposedException.ThrowIf(
                IsDisposed,
                this);

            return _content!;
        }
    }

    public string ContentType { get; }

    public long? ContentLength { get; }

    public string? ETag { get; }

    public string? FileName { get; }

    public DateTimeOffset? LastModified { get; }

    public bool HasKnownLength =>
        ContentLength.HasValue;

    public bool IsEmpty =>
        ContentLength == 0;

    public bool IsPdf =>
        string.Equals(
            ContentType,
            "application/pdf",
            StringComparison.OrdinalIgnoreCase);

    public bool IsDisposed =>
        Volatile.Read(ref _disposed) != 0;

    public void Dispose()
    {
        if (Interlocked.Exchange(
                ref _disposed,
                1) != 0)
        {
            return;
        }

        var content =
            Interlocked.Exchange(
                ref _content,
                null);

        var owner =
            Interlocked.Exchange(
                ref _owner,
                null);

        try
        {
            content?.Dispose();
        }
        finally
        {
            owner?.Dispose();
        }

        GC.SuppressFinalize(this);
    }

    public async ValueTask DisposeAsync()
    {
        if (Interlocked.Exchange(
                ref _disposed,
                1) != 0)
        {
            return;
        }

        var content =
            Interlocked.Exchange(
                ref _content,
                null);

        var owner =
            Interlocked.Exchange(
                ref _owner,
                null);

        try
        {
            if (content is not null)
            {
                await content.DisposeAsync();
            }
        }
        finally
        {
            owner?.Dispose();
        }

        GC.SuppressFinalize(this);
    }

    private static string NormalizeContentType(
        string contentType)
    {
        var normalized =
            contentType.Trim();

        var separatorIndex =
            normalized.IndexOf(
                ';',
                StringComparison.Ordinal);

        if (separatorIndex >= 0)
        {
            normalized =
                normalized[..separatorIndex]
                    .Trim();
        }

        if (string.IsNullOrWhiteSpace(normalized))
        {
            throw new ArgumentException(
                "The content type is invalid.",
                nameof(contentType));
        }

        return normalized.ToLowerInvariant();
    }

    private static string? NormalizeFileName(
        string? fileName)
    {
        if (string.IsNullOrWhiteSpace(fileName))
        {
            return null;
        }

        var normalized =
            fileName
                .Trim()
                .Trim('"');

        if (normalized.Contains('/') ||
            normalized.Contains('\\') ||
            normalized.Contains(
                "..",
                StringComparison.Ordinal) ||
            normalized.Any(char.IsControl))
        {
            return null;
        }

        return normalized;
    }

    private static string? NormalizeOptionalValue(
        string? value)
    {
        return string.IsNullOrWhiteSpace(value)
            ? null
            : value.Trim();
    }
}