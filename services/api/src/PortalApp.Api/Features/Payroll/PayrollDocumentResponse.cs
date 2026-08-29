namespace PortalApp.Api.Features.Payroll;

public sealed record PayrollDocumentResponse(
    string Id,
    string FileName,
    string MimeType,
    long Size,
    string Period,
    DateTimeOffset? LastModifiedAt);

public sealed record PayrollDocumentsResponse(
    string EmployeeId,
    IReadOnlyList<PayrollDocumentResponse> Documents);

public sealed record PayrollDownload(
    Stream Content,
    string ContentType,
    string FileName,
    long? ContentLength,
    string? ETag,
    IAsyncDisposable Owner) : IAsyncDisposable
{
    public ValueTask DisposeAsync() => Owner.DisposeAsync();
}