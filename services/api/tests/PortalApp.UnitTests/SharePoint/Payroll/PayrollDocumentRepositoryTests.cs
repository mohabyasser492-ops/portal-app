using Microsoft.Extensions.Options;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint;
using PortalApp.Infrastructure.SharePoint.Payroll;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Payroll;

public sealed class PayrollDocumentRepositoryTests
{
    [Fact]
    public async Task ListsAndFiltersEmployeeDocuments()
    {
        var graph = new FakeGraphClient([
            CreateItem("doc-1", "Payslip_2026-08.pdf"),
            CreateItem("doc-2", "Payslip_2026-07.pdf")
        ]);
        var repository = CreateRepository(graph);

        var result = await repository.GetForEmployeeAsync(
            "employee-001",
            new PayrollPeriod(2026, 8),
            Context());

        var document = Assert.Single(result);
        Assert.Equal("doc-1", document.DriveItemId);
        Assert.Contains("employee-001", graph.PagePath);
    }

    [Fact]
    public async Task DownloadRequiresDocumentToBelongToEmployeeFolder()
    {
        var graph = new FakeGraphClient([CreateItem("doc-1", "Payslip_2026-08.pdf")]);
        var repository = CreateRepository(graph);

        var missing = await repository.DownloadForEmployeeAsync(
            "employee-001",
            "doc-2",
            Context());

        Assert.Null(missing);
        Assert.Null(graph.DownloadPath);
    }

    [Fact]
    public async Task DownloadsVerifiedPdf()
    {
        var graph = new FakeGraphClient([CreateItem("doc-1", "Payslip_2026-08.pdf")]);
        var repository = CreateRepository(graph);

        await using var file = await repository.DownloadForEmployeeAsync(
            "employee-001",
            "doc-1",
            Context());

        Assert.NotNull(file);
        Assert.True(file.IsPdf);
        Assert.Equal("/drives/drive-id/items/doc-1/content", graph.DownloadPath);
    }

    private static PayrollDocumentRepository CreateRepository(FakeGraphClient graph) =>
        new(graph, Options.Create(new SharePointOptions { Hostname = "example.sharepoint.com", SitePath = "/sites/Portal", PayrollDriveId = "drive-id" }), new PayrollDocumentMapper());

    private static GraphRequestContext Context() =>
        new("correlation-001", "object-001", CancellationToken.None);

    private static SharePointDriveItem CreateItem(string id, string name) =>
        new()
        {
            Id = id,
            Name = name,
            Size = 4,
            File = new SharePointFileFacet { MimeType = "application/pdf" }
        };

    private sealed class FakeGraphClient : IPortalGraphClient
    {
        private readonly IReadOnlyList<SharePointDriveItem> _items;
        public FakeGraphClient(IReadOnlyList<SharePointDriveItem> items) => _items = items;
        public string? PagePath { get; private set; }
        public string? DownloadPath { get; private set; }

        public Task<T?> GetAsync<T>(string relativePath, GraphRequestContext context) =>
            Task.FromResult(default(T));

        public Task<GraphPage<T>> GetPageAsync<T>(string relativePath, GraphRequestContext context)
        {
            PagePath = relativePath;
            return Task.FromResult(new GraphPage<T>(_items.Cast<T>().ToArray(), null));
        }

        public Task<GraphFileContent> DownloadAsync(string relativePath, GraphRequestContext context)
        {
            DownloadPath = relativePath;
            GraphFileContent file = new(new MemoryStream([0x25, 0x50, 0x44, 0x46]), "application/pdf", 4, "etag", "Payslip_2026-08.pdf");
            return Task.FromResult(file);
        }
    }
}