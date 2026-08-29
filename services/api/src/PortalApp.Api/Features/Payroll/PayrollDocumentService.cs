using PortalApp.Api.Authorization;
using PortalApp.Api.Features.Leave;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Payroll;

namespace PortalApp.Api.Features.Payroll;

public sealed class PayrollDocumentService : IPayrollDocumentService
{
    private readonly ICurrentUser _currentUser;
    private readonly CurrentEmployeeIdentifierResolver _employeeResolver;
    private readonly IPayrollDocumentRepository _repository;

    public PayrollDocumentService(
        ICurrentUser currentUser,
        CurrentEmployeeIdentifierResolver employeeResolver,
        IPayrollDocumentRepository repository)
    {
        _currentUser = currentUser;
        _employeeResolver = employeeResolver;
        _repository = repository;
    }

    public async Task<PayrollDocumentsResponse> GetCurrentAsync(
        int? year,
        int? month,
        string correlationId,
        CancellationToken cancellationToken)
    {
        ValidateCorrelationId(correlationId);
        var period = CreateOptionalPeriod(year, month);
        var employeeId = _employeeResolver.Resolve(_currentUser);
        var context = new GraphRequestContext(correlationId, _currentUser.ObjectId, cancellationToken);
        var records = await _repository.GetForEmployeeAsync(employeeId, period, context);

        return new PayrollDocumentsResponse(
            employeeId,
            records.Select(record => new PayrollDocumentResponse(
                record.DriveItemId,
                record.FileName,
                record.MimeType,
                record.Size,
                record.Period.Value,
                record.LastModifiedAt)).ToArray());
    }

    public async Task<PayrollDownload?> DownloadCurrentAsync(
        string documentId,
        string correlationId,
        CancellationToken cancellationToken)
    {
        ValidateCorrelationId(correlationId);
        var employeeId = _employeeResolver.Resolve(_currentUser);
        var context = new GraphRequestContext(correlationId, _currentUser.ObjectId, cancellationToken);
        var file = await _repository.DownloadForEmployeeAsync(employeeId, documentId, context);

        if (file is null)
        {
            return null;
        }

        return new PayrollDownload(
            file.Content,
            file.ContentType,
            file.FileName ?? "payroll-document.pdf",
            file.ContentLength,
            file.ETag,
            file);
    }

    private static PayrollPeriod? CreateOptionalPeriod(int? year, int? month)
    {
        if (year is null && month is null)
        {
            return null;
        }

        if (year is null || month is null)
        {
            throw new ArgumentException("Both payroll year and month must be supplied together.");
        }

        return new PayrollPeriod(year.Value, month.Value);
    }

    private static void ValidateCorrelationId(string correlationId)
    {
        if (string.IsNullOrWhiteSpace(correlationId))
        {
            throw new ArgumentException("A correlation identifier is required.", nameof(correlationId));
        }
    }
}