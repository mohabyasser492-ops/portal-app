using Microsoft.Extensions.Options;
using PortalApp.Infrastructure.Graph;

namespace PortalApp.Api.FileSecurity;

public sealed class FileSecurityValidator : IFileSecurityValidator
{
    private static readonly byte[] PdfSignature = [0x25, 0x50, 0x44, 0x46, 0x2D];
    private readonly FileSecurityOptions _options;

    public FileSecurityValidator(IOptions<FileSecurityOptions> options)
    {
        ArgumentNullException.ThrowIfNull(options);
        _options = options.Value;
    }

    public async Task<string> ValidateDownloadAsync(
        GraphFileContent file,
        string fallbackFileName,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(file);
        cancellationToken.ThrowIfCancellationRequested();

        var fileName = NormalizeFileName(file.FileName ?? fallbackFileName);
        var extension = Path.GetExtension(fileName);
        if (!_options.AllowedExtensions.Contains(extension, StringComparer.OrdinalIgnoreCase))
        {
            throw new FileSecurityValidationException("The file extension is not allowed.");
        }

        if (!_options.AllowedContentTypes.Contains(file.ContentType, StringComparer.OrdinalIgnoreCase))
        {
            throw new FileSecurityValidationException("The file content type is not allowed.");
        }

        if (file.ContentLength is <= 0)
        {
            throw new FileSecurityValidationException("The file content is empty.");
        }

        if (file.ContentLength is > 0 && file.ContentLength > _options.MaximumSizeBytes)
        {
            throw new FileSecurityValidationException("The file exceeds the configured size limit.");
        }

        var stream = file.Content;
        if (!stream.CanRead)
        {
            throw new FileSecurityValidationException("The file stream is not readable.");
        }

        var originalPosition = stream.CanSeek ? stream.Position : 0;
        var signature = new byte[PdfSignature.Length];
        var read = 0;
        while (read < signature.Length)
        {
            var count = await stream.ReadAsync(signature.AsMemory(read), cancellationToken);
            if (count == 0) { break; }
            read += count;
        }

        if (stream.CanSeek)
        {
            stream.Position = originalPosition;
        }
        else
        {
            throw new FileSecurityValidationException("The validated file stream must support seeking.");
        }

        if (read != PdfSignature.Length || !signature.SequenceEqual(PdfSignature))
        {
            throw new FileSecurityValidationException("The file signature does not match a PDF document.");
        }

        return fileName;
    }

    private static string NormalizeFileName(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new FileSecurityValidationException("A file name is required.");
        }

        var fileName = value.Trim().Trim('"');
        if (fileName.Length > 180 ||
            fileName.Contains('/') ||
            fileName.Contains('\\') ||
            fileName.Contains("..", StringComparison.Ordinal) ||
            fileName.Any(char.IsControl) ||
            !string.Equals(fileName, Path.GetFileName(fileName), StringComparison.Ordinal))
        {
            throw new FileSecurityValidationException("The file name is unsafe.");
        }

        return fileName;
    }
}