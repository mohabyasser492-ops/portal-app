using System.Security.Claims;
using PortalApp.Api.Authorization;
using PortalApp.Api.Features.Leave;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Leave;
using Xunit;

namespace PortalApp.UnitTests.Features.Leave;

public sealed class LeaveBalanceServiceTests
{
    [Fact]
    public async Task ResolvesEmployeeAndCalculatesTotals()
    {
        var currentUser =
            new FakeCurrentUser(
                new ClaimsPrincipal(
                    new ClaimsIdentity(
                        [
                            new Claim(
                                "employee_id",
                                "employee-001"),
                            new Claim(
                                "oid",
                                "object-001")
                        ],
                        "Test")));

        var repository =
            new FakeRepository(
                [
                    new LeaveBalanceRecord(
                        "item-001",
                        null,
                        "employee-001",
                        "Annual",
                        30m,
                        8m,
                        2m,
                        20m,
                        2026,
                        null),
                    new LeaveBalanceRecord(
                        "item-002",
                        null,
                        "employee-001",
                        "Sick",
                        10m,
                        1m,
                        0m,
                        9m,
                        2026,
                        null)
                ]);

        var service =
            new LeaveBalanceService(
                currentUser,
                new CurrentEmployeeIdentifierResolver(),
                repository);

        var result =
            await service.GetCurrentAsync(
                "correlation-001",
                CancellationToken.None);

        Assert.Equal(
            "employee-001",
            result.EmployeeId);

        Assert.Equal(
            40m,
            result.TotalEntitledDays);

        Assert.Equal(
            29m,
            result.TotalRemainingDays);

        Assert.Equal(
            2,
            result.Balances.Count);

        Assert.Equal(
            "object-001",
            repository.Context?.UserObjectId);
    }

    [Fact]
    public async Task RejectsAnonymousUser()
    {
        var currentUser =
            new FakeCurrentUser(
                new ClaimsPrincipal(
                    new ClaimsIdentity()));

        var service =
            new LeaveBalanceService(
                currentUser,
                new CurrentEmployeeIdentifierResolver(),
                new FakeRepository([]));

        await Assert.ThrowsAsync<
            UnauthorizedAccessException>(
                () =>
                    service.GetCurrentAsync(
                        "correlation-001",
                        CancellationToken.None));
    }

    private sealed class FakeRepository
        : ILeaveBalanceRepository
    {
        private readonly IReadOnlyList<
            LeaveBalanceRecord> _records;

        public FakeRepository(
            IReadOnlyList<
                LeaveBalanceRecord> records)
        {
            _records = records;
        }

        public GraphRequestContext? Context
        {
            get;
            private set;
        }

        public Task<IReadOnlyList<
            LeaveBalanceRecord>>
            GetForEmployeeAsync(
                string employeeId,
                GraphRequestContext context)
        {
            Context = context;

            return Task.FromResult(
                _records);
        }
    }

    private sealed class FakeCurrentUser
        : ICurrentUser
    {
        public FakeCurrentUser(
            ClaimsPrincipal principal)
        {
            Principal = principal;
        }

        public bool IsAuthenticated =>
            Principal.Identity?.IsAuthenticated ==
            true;

        public string? ObjectId =>
            Principal.FindFirst("oid")?.Value;

        public string? TenantId =>
            Principal.FindFirst("tid")?.Value;

        public string? DisplayName =>
            Principal.FindFirst("name")?.Value;

        public string? Username =>
            Principal
                .FindFirst(
                    "preferred_username")
                ?.Value;

        public IReadOnlyCollection<string> Roles =>
            Principal
                .FindAll("roles")
                .Select(
                    claim => claim.Value)
                .ToArray();

        public ClaimsPrincipal Principal
        {
            get;
        }
    }
}