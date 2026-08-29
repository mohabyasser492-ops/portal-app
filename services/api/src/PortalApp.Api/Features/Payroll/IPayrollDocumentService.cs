namespace PortalApp.Api.Features.Payroll;

public interface IPayrollDocumentService
{
    Task<PayrollDocumentsResponse> GetCurrentAsync(
        int? year,
        int? month,
        string correlationId,
        CancellationToken cancellationToken);

    Task<PayrollDownload?> DownloadCurrentAsync(
        string documentId,
        string correlationId,
        CancellationToken cancellationToken);
}