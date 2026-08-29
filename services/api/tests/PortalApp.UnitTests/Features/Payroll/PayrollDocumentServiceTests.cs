using System.Security.Claims;
using PortalApp.Api.Authorization;
using PortalApp.Api.Features.Leave;
using PortalApp.Api.Features.Payroll;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Payroll;
using Xunit;

namespace PortalApp.UnitTests.Features.Payroll;

public sealed class PayrollDocumentServiceTests
{
    [Fact]
    public async Task ResolvesEmployeeAndMapsDocuments()
    {
        var user = new TestUser("employee-001", "object-001");
        var repository = new FakeRepository();
        var service = new PayrollDocumentService(user, new CurrentEmployeeIdentifierResolver(), repository);

        var result = await service.GetCurrentAsync(2026, 8, "correlation-001", CancellationToken.None);

        Assert.Equal("employee-001", result.EmployeeId);
        Assert.Single(result.Documents);
        Assert.Equal("2026-08", result.Documents[0].Period);
        Assert.Equal("employee-001", repository.EmployeeId);
    }

    [Fact]
    public async Task RejectsPartialPeriod()
    {
        var service = new PayrollDocumentService(new TestUser("employee-001", "object-001"), new CurrentEmployeeIdentifierResolver(), new FakeRepository());
        await Assert.ThrowsAsync<ArgumentException>(() => service.GetCurrentAsync(2026, null, "correlation-001", CancellationToken.None));
    }

    private sealed class FakeRepository : IPayrollDocumentRepository
    {
        public string? EmployeeId { get; private set; }
        public Task<IReadOnlyList<PayrollDocumentRecord>> GetForEmployeeAsync(string employeeId, PayrollPeriod? period, GraphRequestContext context)
        {
            EmployeeId = employeeId;
            IReadOnlyList<PayrollDocumentRecord> records = [new("doc-1", null, "Payslip_2026-08.pdf", "application/pdf", 4, new PayrollPeriod(2026, 8), null, null, null)];
            return Task.FromResult(records);
        }
        public Task<GraphFileContent?> DownloadForEmployeeAsync(string employeeId, string documentId, GraphRequestContext context) => Task.FromResult<GraphFileContent?>(null);
    }

    private sealed class TestUser : ICurrentUser
    {
        public TestUser(string employeeId, string objectId)
        {
            ObjectId = objectId;
            Principal = new ClaimsPrincipal(new ClaimsIdentity([new Claim("employee_id", employeeId), new Claim("oid", objectId)], "Test"));
        }
        public bool IsAuthenticated => true;
        public string? ObjectId { get; }
        public string? TenantId => null;
        public string? DisplayName => null;
        public string? Username => null;
        public IReadOnlyCollection<string> Roles => [];
        public ClaimsPrincipal Principal { get; }
    }
}