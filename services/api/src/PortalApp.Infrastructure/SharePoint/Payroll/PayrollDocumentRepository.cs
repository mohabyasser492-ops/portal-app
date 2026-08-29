using Microsoft.Extensions.Options;
using PortalApp.Infrastructure.Graph;

namespace PortalApp.Infrastructure.SharePoint.Payroll;

public sealed class PayrollDocumentRepository : IPayrollDocumentRepository
{
    private const int MaximumPages = 100;
    private readonly IPortalGraphClient _graphClient;
    private readonly SharePointOptions _options;
    private readonly PayrollDocumentMapper _mapper;

    public PayrollDocumentRepository(
        IPortalGraphClient graphClient,
        IOptions<SharePointOptions> options,
        PayrollDocumentMapper mapper)
    {
        _graphClient = graphClient;
        _options = options.Value;
        _mapper = mapper;
    }

    public async Task<IReadOnlyList<PayrollDocumentRecord>> GetForEmployeeAsync(
        string employeeId,
        PayrollPeriod? period,
        GraphRequestContext context)
    {
        ValidateEmployeeId(employeeId);
        ArgumentNullException.ThrowIfNull(context);
        EnsureDriveConfigured();

        string? path = PayrollDrivePaths.EmployeeChildren(
            _options.PayrollDriveId,
            employeeId);

        var records = new List<PayrollDocumentRecord>();
        var pages = 0;

        while (!string.IsNullOrWhiteSpace(path))
        {
            context.CancellationToken.ThrowIfCancellationRequested();
            pages++;
            if (pages > MaximumPages)
            {
                throw new InvalidOperationException("The payroll document query exceeded the supported page limit.");
            }

            var page = await _graphClient.GetPageAsync<SharePointDriveItem>(path, context);
            foreach (var item in page.Items)
            {
                if (item.Folder is not null || item.File is null)
                {
                    continue;
                }

                PayrollDocumentRecord record;
                try
                {
                    record = _mapper.Map(item);
                }
                catch (Mapping.SharePointMappingException)
                {
                    continue;
                }

                if (period is null || record.Period == period)
                {
                    records.Add(record);
                }
            }

            path = page.HasNextPage
                ? SharePointGraphPaths.NextPage(page.NextLink!)
                : null;
        }

        return records
            .OrderByDescending(record => record.Period.Year)
            .ThenByDescending(record => record.Period.Month)
            .ThenBy(record => record.FileName, StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }

    public async Task<GraphFileContent?> DownloadForEmployeeAsync(
        string employeeId,
        string documentId,
        GraphRequestContext context)
    {
        ValidateEmployeeId(employeeId);
        ValidateDocumentId(documentId);
        ArgumentNullException.ThrowIfNull(context);
        EnsureDriveConfigured();

        var documents = await GetForEmployeeAsync(employeeId, null, context);
        var document = documents.SingleOrDefault(item =>
            string.Equals(item.DriveItemId, documentId, StringComparison.Ordinal));

        if (document is null)
        {
            return null;
        }

        var file = await _graphClient.DownloadAsync(
            PayrollDrivePaths.Content(_options.PayrollDriveId, documentId),
            context);

        if (!file.IsPdf)
        {
            await file.DisposeAsync();
            throw new InvalidOperationException("The payroll document download is not a PDF file.");
        }

        if (file.ContentLength is > 25L * 1024L * 1024L)
        {
            await file.DisposeAsync();
            throw new InvalidOperationException("The payroll document download exceeds the supported size limit.");
        }

        return file;
    }

    private void EnsureDriveConfigured()
    {
        if (string.IsNullOrWhiteSpace(_options.PayrollDriveId))
        {
            throw new InvalidOperationException("The SharePoint payroll drive identifier is not configured.");
        }
    }

    private static void ValidateEmployeeId(string employeeId)
    {
        if (string.IsNullOrWhiteSpace(employeeId))
        {
            throw new ArgumentException("An employee identifier is required.", nameof(employeeId));
        }
    }

    private static void ValidateDocumentId(string documentId)
    {
        if (string.IsNullOrWhiteSpace(documentId) ||
            documentId.Contains('/') ||
            documentId.Contains('\\') ||
            documentId.Contains("..", StringComparison.Ordinal))
        {
            throw new ArgumentException("A valid payroll document identifier is required.", nameof(documentId));
        }
    }
}