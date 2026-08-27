namespace PortalApp.Infrastructure.SharePoint.Payroll;

public sealed record PayrollDocumentRecord(
    string DriveItemId,
    string? ETag,
    string FileName,
    string MimeType,
    long Size,
    PayrollPeriod Period,
    DateTimeOffset? CreatedAt,
    DateTimeOffset? LastModifiedAt,
    string? Sha1Hash)
{
    public bool IsPdf =>
        string.Equals(
            MimeType,
            PayrollDocumentMapper.PdfMimeType,
            StringComparison.OrdinalIgnoreCase);
}