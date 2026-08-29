using System.Text.Json;
using Microsoft.Extensions.Options;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint;
using PortalApp.Infrastructure.SharePoint.Attendance;
using PortalApp.Infrastructure.SharePoint.Mapping;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Attendance;

public sealed class AttendanceRepositoryTests
{
    [Fact]
    public async Task MapsRequestedEmployeeInsideDateRange()
    {
        var graphClient =
            new FakeGraphClient(
                new AttendanceSiteLookup
                {
                    Id = "site-id"
                },
                [
                    new GraphPage<
                        SharePointListItem>(
                        [
                            CreateItem(
                                "employee-001",
                                "2026-08-20",
                                "Present"),
                            CreateItem(
                                "employee-002",
                                "2026-08-20",
                                "Present"),
                            CreateItem(
                                "employee-001",
                                "2026-07-01",
                                "Present")
                        ],
                        null)
                ]);

        var repository =
            CreateRepository(
                graphClient);

        var result =
            await repository
                .GetForEmployeeAsync(
                    "employee-001",
                    new DateOnly(
                        2026,
                        8,
                        1),
                    new DateOnly(
                        2026,
                        8,
                        31),
                    CreateContext());

        var record =
            Assert.Single(result);

        Assert.Equal(
            "employee-001",
            record.EmployeeId);

        Assert.Equal(
            new DateOnly(
                2026,
                8,
                20),
            record.AttendanceDate);

        Assert.Contains(
            "EmployeeId eq 'employee-001'",
            graphClient.PagePaths[0]);
    }

    [Fact]
    public async Task FollowsContinuationPagesAndSortsDescending()
    {
        var graphClient =
            new FakeGraphClient(
                new AttendanceSiteLookup
                {
                    Id = "site-id"
                },
                [
                    new GraphPage<
                        SharePointListItem>(
                        [
                            CreateItem(
                                "employee-001",
                                "2026-08-10",
                                "Present")
                        ],
                        "https://graph.microsoft.com/v1.0/sites/site-id/lists/list-id/items?$skiptoken=next"),
                    new GraphPage<
                        SharePointListItem>(
                        [
                            CreateItem(
                                "employee-001",
                                "2026-08-20",
                                "Remote")
                        ],
                        null)
                ]);

        var repository =
            CreateRepository(
                graphClient);

        var result =
            await repository
                .GetForEmployeeAsync(
                    "employee-001",
                    new DateOnly(
                        2026,
                        8,
                        1),
                    new DateOnly(
                        2026,
                        8,
                        31),
                    CreateContext());

        Assert.Equal(
            2,
            result.Count);

        Assert.Equal(
            new DateOnly(
                2026,
                8,
                20),
            result[0].AttendanceDate);

        Assert.Equal(
            2,
            graphClient.PagePaths.Count);
    }

    [Fact]
    public async Task RejectsInvalidDateRange()
    {
        var repository =
            CreateRepository(
                new FakeGraphClient(
                    null,
                    []));

        await Assert.ThrowsAsync<
            ArgumentException>(
                () =>
                    repository
                        .GetForEmployeeAsync(
                            "employee-001",
                            new DateOnly(
                                2026,
                                9,
                                1),
                            new DateOnly(
                                2026,
                                8,
                                1),
                            CreateContext()));
    }

    [Fact]
    public async Task ThrowsWhenAttendanceListIsMissing()
    {
        var repository =
            new AttendanceRepository(
                new FakeGraphClient(
                    null,
                    []),
                Options.Create(
                    new SharePointOptions
                    {
                        Hostname =
                            "example.sharepoint.com",
                        SitePath =
                            "/sites/EmployeePortal",
                        AttendanceListId =
                            string.Empty
                    }),
                new AttendanceMapper());

        await Assert.ThrowsAsync<
            InvalidOperationException>(
                () =>
                    repository
                        .GetForEmployeeAsync(
                            "employee-001",
                            new DateOnly(
                                2026,
                                8,
                                1),
                            new DateOnly(
                                2026,
                                8,
                                31),
                            CreateContext()));
    }

    private static AttendanceRepository
        CreateRepository(
            FakeGraphClient graphClient)
    {
        return new AttendanceRepository(
            graphClient,
            Options.Create(
                new SharePointOptions
                {
                    Hostname =
                        "example.sharepoint.com",
                    SitePath =
                        "/sites/EmployeePortal",
                    AttendanceListId =
                        "attendance-list-id"
                }),
            new AttendanceMapper());
    }

    private static GraphRequestContext
        CreateContext()
    {
        return new GraphRequestContext(
            "correlation-001",
            "object-001",
            CancellationToken.None);
    }

    private static SharePointListItem
        CreateItem(
            string employeeId,
            string attendanceDate,
            string status)
    {
        var json =
            $$"""
            {
              "EmployeeId": "{{employeeId}}",
              "AttendanceDate": "{{attendanceDate}}",
              "CheckIn": "{{attendanceDate}}T08:00:00Z",
              "CheckOut": "{{attendanceDate}}T16:00:00Z",
              "Status": "{{status}}",
              "WorkedMinutes": 480
            }
            """;

        var fields =
            JsonSerializer.Deserialize<
                Dictionary<
                    string,
                    JsonElement>>(json)!;

        return new SharePointListItem
        {
            Id =
                Guid.NewGuid().ToString(),
            Fields =
                new Dictionary<
                    string,
                    JsonElement>(
                    fields,
                    StringComparer.OrdinalIgnoreCase)
        };
    }

    private sealed class FakeGraphClient
        : IPortalGraphClient
    {
        private readonly AttendanceSiteLookup?
            _site;

        private readonly IReadOnlyList<
            GraphPage<SharePointListItem>>
            _pages;

        private int _pageIndex;

        public FakeGraphClient(
            AttendanceSiteLookup? site,
            IReadOnlyList<
                GraphPage<SharePointListItem>>
                pages)
        {
            _site = site;
            _pages = pages;
        }

        public List<string> PagePaths
        {
            get;
        } = [];

        public Task<T?> GetAsync<T>(
            string relativePath,
            GraphRequestContext context)
        {
            return Task.FromResult(
                (T?)(object?)_site);
        }

        public Task<GraphPage<T>>
            GetPageAsync<T>(
                string relativePath,
                GraphRequestContext context)
        {
            PagePaths.Add(
                relativePath);

            var page =
                _pages[_pageIndex++];

            return Task.FromResult(
                (GraphPage<T>)(object)page);
        }

        public Task<GraphFileContent> DownloadAsync(
            string relativePath,
            GraphRequestContext context)
        {
            throw new NotSupportedException(
                "File download is not used by attendance repository tests.");
        }}
}