using Microsoft.Extensions.Options;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Mapping;

namespace PortalApp.Infrastructure.SharePoint.Leave;

public sealed class LeaveBalanceRepository
    : ILeaveBalanceRepository
{
    private const int MaximumPages = 100;

    private readonly IPortalGraphClient _graphClient;
    private readonly SharePointOptions _options;
    private readonly LeaveBalanceMapper _mapper;

    public LeaveBalanceRepository(
        IPortalGraphClient graphClient,
        IOptions<SharePointOptions> options,
        LeaveBalanceMapper mapper)
    {
        _graphClient = graphClient;
        _options = options.Value;
        _mapper = mapper;
    }

    public async Task<IReadOnlyList<LeaveBalanceRecord>>
        GetForEmployeeAsync(
            string employeeId,
            GraphRequestContext context)
    {
        if (string.IsNullOrWhiteSpace(employeeId))
        {
            throw new ArgumentException(
                "An employee identifier is required.",
                nameof(employeeId));
        }

        ArgumentNullException.ThrowIfNull(context);

        if (string.IsNullOrWhiteSpace(
                _options.LeaveListId))
        {
            throw new InvalidOperationException(
                "The SharePoint leave list identifier is not configured.");
        }

        var siteRequestPath =
            LeaveBalanceGraphPaths.SiteByPath(
                _options.Hostname,
                _options.SitePath);

        var site =
            await _graphClient.GetAsync<
                SharePointSiteLookup>(
                siteRequestPath,
                context);

        if (site is null ||
            string.IsNullOrWhiteSpace(site.Id))
        {
            throw new InvalidOperationException(
                "The configured SharePoint site could not be resolved.");
        }

        string? requestPath =
            LeaveBalanceGraphPaths.ItemsForEmployee(
                site.Id,
                _options.LeaveListId,
                employeeId);

        var records =
            new List<LeaveBalanceRecord>();

        var pageCount = 0;

        while (!string.IsNullOrWhiteSpace(
                   requestPath))
        {
            context.CancellationToken
                .ThrowIfCancellationRequested();

            pageCount++;

            if (pageCount > MaximumPages)
            {
                throw new InvalidOperationException(
                    "The leave balance query exceeded the supported page limit.");
            }

            var page =
                await _graphClient.GetPageAsync<
                    SharePointListItem>(
                    requestPath,
                    context);

            foreach (var item in page.Items)
            {
                var record =
                    _mapper.Map(item);

                if (string.Equals(
                        record.EmployeeId,
                        employeeId,
                        StringComparison.OrdinalIgnoreCase))
                {
                    records.Add(record);
                }
            }

            requestPath =
                page.HasNextPage
                    ? SharePointGraphPaths.NextPage(
                        page.NextLink!)
                    : null;
        }

        return records
            .OrderByDescending(
                record => record.BalanceYear)
            .ThenBy(
                record => record.LeaveType,
                StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }
}