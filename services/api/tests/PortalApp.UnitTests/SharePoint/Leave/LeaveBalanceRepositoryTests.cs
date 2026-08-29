using System.Text.Json;
using Microsoft.Extensions.Options;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint;
using PortalApp.Infrastructure.SharePoint.Leave;
using PortalApp.Infrastructure.SharePoint.Mapping;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Leave;

public sealed class LeaveBalanceRepositoryTests
{
    [Fact]
    public async Task MapsOnlyRequestedEmployee()
    {
        var graphClient =
            new FakeGraphClient(
                new SharePointSiteLookup
                {
                    Id = "site-id"
                },
                [
                    new GraphPage<
                        SharePointListItem>(
                        [
                            CreateItem(
                                "employee-001",
                                20m),
                            CreateItem(
                                "employee-002",
                                10m)
                        ],
                        null)
                ]);

        var repository =
            CreateRepository(graphClient);

        var result =
            await repository.GetForEmployeeAsync(
                "employee-001",
                CreateContext());

        var record =
            Assert.Single(result);

        Assert.Equal(
            "employee-001",
            record.EmployeeId);

        Assert.Equal(
            20m,
            record.RemainingDays);

        Assert.Contains(
            "EmployeeId eq 'employee-001'",
            graphClient.PagePaths[0]);
    }

    [Fact]
    public async Task FollowsContinuationPage()
    {
        var graphClient =
            new FakeGraphClient(
                new SharePointSiteLookup
                {
                    Id = "site-id"
                },
                [
                    new GraphPage<
                        SharePointListItem>(
                        [
                            CreateItem(
                                "employee-001",
                                20m,
                                2025)
                        ],
                        "https://graph.microsoft.com/v1.0/sites/site-id/lists/list-id/items?$skiptoken=next"),
                    new GraphPage<
                        SharePointListItem>(
                        [
                            CreateItem(
                                "employee-001",
                                25m,
                                2026)
                        ],
                        null)
                ]);

        var repository =
            CreateRepository(graphClient);

        var result =
            await repository.GetForEmployeeAsync(
                "employee-001",
                CreateContext());

        Assert.Equal(
            2,
            result.Count);

        Assert.Equal(
            2026,
            result[0].BalanceYear);

        Assert.Equal(
            2,
            graphClient.PagePaths.Count);
    }

    [Fact]
    public async Task ThrowsWhenLeaveListIsMissing()
    {
        var graphClient =
            new FakeGraphClient(
                null,
                []);

        var repository =
            new LeaveBalanceRepository(
                graphClient,
                Options.Create(
                    new SharePointOptions
                    {
                        Hostname =
                            "example.sharepoint.com",
                        SitePath =
                            "/sites/EmployeePortal",
                        LeaveListId =
                            string.Empty
                    }),
                new LeaveBalanceMapper());

        await Assert.ThrowsAsync<
            InvalidOperationException>(
                () =>
                    repository.GetForEmployeeAsync(
                        "employee-001",
                        CreateContext()));
    }

    private static LeaveBalanceRepository
        CreateRepository(
            FakeGraphClient graphClient)
    {
        return new LeaveBalanceRepository(
            graphClient,
            Options.Create(
                new SharePointOptions
                {
                    Hostname =
                        "example.sharepoint.com",
                    SitePath =
                        "/sites/EmployeePortal",
                    LeaveListId =
                        "leave-list-id"
                }),
            new LeaveBalanceMapper());
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
            decimal remainingDays,
            int year = 2026)
    {
        var json =
            $$"""
            {
              "EmployeeId": "{{employeeId}}",
              "LeaveType": "Annual",
              "EntitledDays": 30,
              "UsedDays": 8,
              "PendingDays": 2,
              "RemainingDays": {{remainingDays}},
              "BalanceYear": {{year}}
            }
            """;

        var fields =
            JsonSerializer.Deserialize<
                Dictionary<
                    string,
                    JsonElement>>(json)!;

        return new SharePointListItem
        {
            Id = Guid.NewGuid().ToString(),
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
        private readonly SharePointSiteLookup?
            _site;

        private readonly IReadOnlyList<
            GraphPage<SharePointListItem>>
            _pages;

        private int _index;

        public FakeGraphClient(
            SharePointSiteLookup? site,
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
            PagePaths.Add(relativePath);

            var page =
                _pages[_index++];

            return Task.FromResult(
                (GraphPage<T>)(object)page);
        }

        public Task<GraphFileContent> DownloadAsync(
            string relativePath,
            GraphRequestContext context)
        {
            throw new NotSupportedException(
                "File download is not used by leave balance repository tests.");
        }}
}