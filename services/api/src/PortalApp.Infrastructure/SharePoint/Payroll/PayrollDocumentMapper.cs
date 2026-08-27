using PortalApp.Infrastructure.SharePoint.Mapping;

namespace PortalApp.Infrastructure.SharePoint.Payroll;

public sealed class PayrollDocumentMapper
{
    public const string PdfMimeType =
        "application/pdf";

    private const long MaximumFileSizeBytes =
        25L * 1024L * 1024L;

    public PayrollDocumentRecord Map(
        SharePointDriveItem item)
    {
        ArgumentNullException.ThrowIfNull(item);

        if (string.IsNullOrWhiteSpace(item.Id))
        {
            throw CreateException(
                string.Empty,
                "id",
                "The drive item identifier is missing.");
        }

        if (item.Folder is not null)
        {
            throw CreateException(
                item.Id,
                "folder",
                "A folder cannot be mapped as a payroll document.");
        }

        if (item.File is null)
        {
            throw CreateException(
                item.Id,
                "file",
                "The drive item does not contain a file facet.");
        }

        var fileName =
            NormalizeFileName(
                item.Id,
                item.Name);

        var mimeType =
            NormalizeMimeType(
                item.Id,
                item.File.MimeType);

        if (!string.Equals(
                mimeType,
                PdfMimeType,
                StringComparison.OrdinalIgnoreCase))
        {
            throw CreateException(
                item.Id,
                "mimeType",
                "Payroll documents must use the PDF content type.");
        }

        if (!fileName.EndsWith(
                ".pdf",
                StringComparison.OrdinalIgnoreCase))
        {
            throw CreateException(
                item.Id,
                "name",
                "Payroll document file names must use the PDF extension.");
        }

        var size = item.Size ?? 0;

        if (size <= 0)
        {
            throw CreateException(
                item.Id,
                "size",
                "The payroll document size must be greater than zero.");
        }

        if (size > MaximumFileSizeBytes)
        {
            throw CreateException(
                item.Id,
                "size",
                "The payroll document exceeds the supported size limit.");
        }

        var period =
            ParsePeriod(
                item.Id,
                fileName);

        return new PayrollDocumentRecord(
            DriveItemId: item.Id,
            ETag: item.ETag,
            FileName: fileName,
            MimeType: mimeType,
            Size: size,
            Period: period,
            CreatedAt: item.CreatedDateTime,
            LastModifiedAt: item.LastModifiedDateTime,
            Sha1Hash:
                NormalizeHash(
                    item.File.Hashes?.Sha1Hash));
    }

    private static string NormalizeFileName(
        string itemId,
        string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw CreateException(
                itemId,
                "name",
                "The payroll document file name is missing.");
        }

        var fileName = value.Trim();

        if (fileName.Contains('/') ||
            fileName.Contains('\\') ||
            fileName.Contains(
                "..",
                StringComparison.Ordinal))
        {
            throw CreateException(
                itemId,
                "name",
                "The payroll document file name contains an unsafe path.");
        }

        if (fileName.Any(char.IsControl))
        {
            throw CreateException(
                itemId,
                "name",
                "The payroll document file name contains control characters.");
        }

        return fileName;
    }

    private static string NormalizeMimeType(
        string itemId,
        string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw CreateException(
                itemId,
                "mimeType",
                "The payroll document MIME type is missing.");
        }

        return value
            .Trim()
            .ToLowerInvariant();
    }

    private static string? NormalizeHash(
        string? value)
    {
        return string.IsNullOrWhiteSpace(value)
            ? null
            : value.Trim().ToUpperInvariant();
    }

    private static PayrollPeriod ParsePeriod(
        string itemId,
        string fileName)
    {
        var fileNameWithoutExtension =
            Path.GetFileNameWithoutExtension(
                fileName);

        for (var index = 0;
             index <= fileNameWithoutExtension.Length - 7;
             index++)
        {
            var candidate =
                fileNameWithoutExtension.Substring(
                    index,
                    7);

            if (!HasValidPeriodStructure(candidate))
            {
                continue;
            }

            if (HasAdjacentDigit(
                    fileNameWithoutExtension,
                    index))
            {
                continue;
            }

            var normalizedCandidate =
                candidate[..4] +
                "-" +
                candidate[5..7];

            if (PayrollPeriod.TryParse(
                    normalizedCandidate,
                    out var period))
            {
                return period;
            }
        }

        throw CreateException(
            itemId,
            "name",
            "The payroll document file name does not contain a valid payroll period.");
    }

    private static bool HasValidPeriodStructure(
        string candidate)
    {
        if (candidate.Length != 7)
        {
            return false;
        }

        var separator = candidate[4];

        if (separator is not ('-' or '_' or ' '))
        {
            return false;
        }

        return char.IsDigit(candidate[0]) &&
               char.IsDigit(candidate[1]) &&
               char.IsDigit(candidate[2]) &&
               char.IsDigit(candidate[3]) &&
               char.IsDigit(candidate[5]) &&
               char.IsDigit(candidate[6]);
    }

    private static bool HasAdjacentDigit(
        string fileName,
        int candidateStart)
    {
        var beforeCandidate =
            candidateStart - 1;

        if (beforeCandidate >= 0 &&
            char.IsDigit(
                fileName[beforeCandidate]))
        {
            return true;
        }

        var afterCandidate =
            candidateStart + 7;

        return afterCandidate < fileName.Length &&
               char.IsDigit(
                   fileName[afterCandidate]);
    }

    private static SharePointMappingException
        CreateException(
            string itemId,
            string fieldName,
            string message)
    {
        return new SharePointMappingException(
            itemId,
            fieldName,
            message);
    }
}