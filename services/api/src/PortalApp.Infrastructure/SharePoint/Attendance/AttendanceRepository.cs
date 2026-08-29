using Microsoft.Extensions.Options;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Mapping;

namespace PortalApp.Infrastructure.SharePoint.Attendance;

public sealed class AttendanceRepository
    : IAttendanceRepository
{
    private const int MaximumPages = 100;

    private readonly IPortalGraphClient _graphClient;
    private readonly SharePointOptions _options;
    private readonly AttendanceMapper _mapper;

    public AttendanceRepository(
        IPortalGraphClient graphClient,
        IOptions<SharePointOptions> options,
        AttendanceMapper mapper)
    {
        _graphClient = graphClient;
        _options = options.Value;
        _mapper = mapper;
    }

    public async Task<IReadOnlyList<AttendanceRecord>>
        GetForEmployeeAsync(
            string employeeId,
            DateOnly fromDate,
            DateOnly toDate,
            GraphRequestContext context)
    {
        if (string.IsNullOrWhiteSpace(employeeId))
        {
            throw new ArgumentException(
                "An employee identifier is required.",
                nameof(employeeId));
        }

        if (fromDate > toDate)
        {
            throw new ArgumentException(
                "The attendance start date cannot be later than the end date.",
                nameof(fromDate));
        }

        ArgumentNullException.ThrowIfNull(context);

        if (string.IsNullOrWhiteSpace(
                _options.AttendanceListId))
        {
            throw new InvalidOperationException(
                "The SharePoint attendance list identifier is not configured.");
        }

        var siteRequestPath =
            AttendanceGraphPaths.SiteByPath(
                _options.Hostname,
                _options.SitePath);

        var site =
            await _graphClient.GetAsync<
                AttendanceSiteLookup>(
                siteRequestPath,
                context);

        if (site is null ||
            string.IsNullOrWhiteSpace(site.Id))
        {
            throw new InvalidOperationException(
                "The configured SharePoint site could not be resolved.");
        }

        string? requestPath =
            AttendanceGraphPaths.ItemsForEmployee(
                site.Id,
                _options.AttendanceListId,
                employeeId);

        var records =
            new List<AttendanceRecord>();

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
                    "The attendance query exceeded the supported page limit.");
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

                if (!string.Equals(
                        record.EmployeeId,
                        employeeId,
                        StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                if (record.AttendanceDate < fromDate ||
                    record.AttendanceDate > toDate)
                {
                    continue;
                }

                records.Add(record);
            }

            requestPath =
                page.HasNextPage
                    ? SharePointGraphPaths.NextPage(
                        page.NextLink!)
                    : null;
        }

        return records
            .OrderByDescending(
                record =>
                    record.AttendanceDate)
            .ThenByDescending(
                record =>
                    record.CheckIn)
            .ToArray();
    }
}