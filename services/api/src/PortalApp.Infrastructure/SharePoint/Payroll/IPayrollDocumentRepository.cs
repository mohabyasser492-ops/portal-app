using PortalApp.Infrastructure.Graph;

namespace PortalApp.Infrastructure.SharePoint.Payroll;

public interface IPayrollDocumentRepository
{
    Task<IReadOnlyList<PayrollDocumentRecord>> GetForEmployeeAsync(
        string employeeId,
        PayrollPeriod? period,
        GraphRequestContext context);

    Task<GraphFileContent?> DownloadForEmployeeAsync(
        string employeeId,
        string documentId,
        GraphRequestContext context);
}