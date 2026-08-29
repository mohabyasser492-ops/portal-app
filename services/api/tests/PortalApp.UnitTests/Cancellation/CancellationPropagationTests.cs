using System.Security.Claims;
using PortalApp.Api.Authorization;
using PortalApp.Api.Features.Attendance;
using PortalApp.Api.Features.Leave;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Attendance;
using Xunit;

namespace PortalApp.UnitTests.Cancellation;

public sealed class CancellationPropagationTests
{
    [Fact]
    public async Task AttendanceServicePropagatesCancellationToken()
    {
        using var source = new CancellationTokenSource();
        var repository = new CapturingAttendanceRepository();
        var service = new AttendanceService(
            new TestCurrentUser(),
            new CurrentEmployeeIdentifierResolver(),
            repository);

        await service.GetCurrentAsync(
            new DateOnly(2026, 8, 1),
            new DateOnly(2026, 8, 2),
            "correlation-001",
            source.Token);

        Assert.Equal(source.Token, repository.Context?.CancellationToken);
    }

    private sealed class CapturingAttendanceRepository : IAttendanceRepository
    {
        public GraphRequestContext? Context { get; private set; }

        public Task<IReadOnlyList<AttendanceRecord>> GetForEmployeeAsync(
            string employeeId,
            DateOnly fromDate,
            DateOnly toDate,
            GraphRequestContext context)
        {
            Context = context;
            return Task.FromResult<IReadOnlyList<AttendanceRecord>>([]);
        }
    }

    private sealed class TestCurrentUser : ICurrentUser
    {
        public TestCurrentUser()
        {
            Principal = new ClaimsPrincipal(
                new ClaimsIdentity(
                    [
                        new Claim("employee_id", "employee-001"),
                        new Claim("oid", "object-001")
                    ],
                    "Test"));
        }

        public bool IsAuthenticated => true;
        public string? ObjectId => "object-001";
        public string? TenantId => null;
        public string? DisplayName => null;
        public string? Username => null;
        public IReadOnlyCollection<string> Roles => [];
        public ClaimsPrincipal Principal { get; }
    }
}