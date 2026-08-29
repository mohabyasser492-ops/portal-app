using System.Security.Claims;
using PortalApp.Api.Authorization;
using PortalApp.Api.Features.Attendance;
using PortalApp.Api.Features.Leave;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Attendance;
using Xunit;

namespace PortalApp.UnitTests.Features.Attendance;

public sealed class AttendanceServiceTests
{
    [Fact]
    public async Task CalculatesAttendanceSummary()
    {
        var currentUser =
            CreateCurrentUser();

        var repository =
            new FakeAttendanceRepository(
                [
                    CreateRecord(
                        new DateOnly(
                            2026,
                            8,
                            20),
                        AttendanceStatus.Present,
                        480),
                    CreateRecord(
                        new DateOnly(
                            2026,
                            8,
                            19),
                        AttendanceStatus.Late,
                        450),
                    CreateRecord(
                        new DateOnly(
                            2026,
                            8,
                            18),
                        AttendanceStatus.Remote,
                        480),
                    CreateRecord(
                        new DateOnly(
                            2026,
                            8,
                            17),
                        AttendanceStatus.Absent,
                        null)
                ]);

        var service =
            new AttendanceService(
                currentUser,
                new CurrentEmployeeIdentifierResolver(),
                repository);

        var result =
            await service.GetCurrentAsync(
                new DateOnly(
                    2026,
                    8,
                    1),
                new DateOnly(
                    2026,
                    8,
                    31),
                "correlation-001",
                CancellationToken.None);

        Assert.Equal(
            "employee-001",
            result.EmployeeId);

        Assert.Equal(
            4,
            result.Summary.TotalRecords);

        Assert.Equal(
            1,
            result.Summary.PresentDays);

        Assert.Equal(
            1,
            result.Summary.LateDays);

        Assert.Equal(
            1,
            result.Summary.RemoteDays);

        Assert.Equal(
            1,
            result.Summary.AbsentDays);

        Assert.Equal(
            1410,
            result.Summary.TotalWorkedMinutes);

        Assert.Equal(
            "object-001",
            repository.Context?.UserObjectId);
    }

    [Fact]
    public async Task RejectsReversedDateRange()
    {
        var service =
            new AttendanceService(
                CreateCurrentUser(),
                new CurrentEmployeeIdentifierResolver(),
                new FakeAttendanceRepository(
                    []));

        await Assert.ThrowsAsync<
            ArgumentException>(
                () =>
                    service.GetCurrentAsync(
                        new DateOnly(
                            2026,
                            9,
                            1),
                        new DateOnly(
                            2026,
                            8,
                            1),
                        "correlation-001",
                        CancellationToken.None));
    }

    [Fact]
    public async Task RejectsExcessiveDateRange()
    {
        var service =
            new AttendanceService(
                CreateCurrentUser(),
                new CurrentEmployeeIdentifierResolver(),
                new FakeAttendanceRepository(
                    []));

        await Assert.ThrowsAsync<
            ArgumentOutOfRangeException>(
                () =>
                    service.GetCurrentAsync(
                        new DateOnly(
                            2025,
                            1,
                            1),
                        new DateOnly(
                            2026,
                            8,
                            1),
                        "correlation-001",
                        CancellationToken.None));
    }

    [Fact]
    public async Task RejectsAnonymousUser()
    {
        var currentUser =
            new FakeCurrentUser(
                new ClaimsPrincipal(
                    new ClaimsIdentity()));

        var service =
            new AttendanceService(
                currentUser,
                new CurrentEmployeeIdentifierResolver(),
                new FakeAttendanceRepository(
                    []));

        await Assert.ThrowsAsync<
            UnauthorizedAccessException>(
                () =>
                    service.GetCurrentAsync(
                        new DateOnly(
                            2026,
                            8,
                            1),
                        new DateOnly(
                            2026,
                            8,
                            31),
                        "correlation-001",
                        CancellationToken.None));
    }

    private static FakeCurrentUser
        CreateCurrentUser()
    {
        var principal =
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
                    "Test"));

        return new FakeCurrentUser(
            principal);
    }

    private static AttendanceRecord
        CreateRecord(
            DateOnly date,
            AttendanceStatus status,
            int? workedMinutes)
    {
        return new AttendanceRecord(
            SharePointItemId:
                Guid.NewGuid().ToString(),
            ETag:
                null,
            EmployeeId:
                "employee-001",
            AttendanceDate:
                date,
            CheckIn:
                null,
            CheckOut:
                null,
            Status:
                status,
            WorkedMinutes:
                workedMinutes,
            Notes:
                null,
            LastUpdated:
                null);
    }

    private sealed class FakeAttendanceRepository
        : IAttendanceRepository
    {
        private readonly IReadOnlyList<
            AttendanceRecord> _records;

        public FakeAttendanceRepository(
            IReadOnlyList<
                AttendanceRecord> records)
        {
            _records = records;
        }

        public GraphRequestContext? Context
        {
            get;
            private set;
        }

        public Task<IReadOnlyList<
            AttendanceRecord>>
            GetForEmployeeAsync(
                string employeeId,
                DateOnly fromDate,
                DateOnly toDate,
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
            Principal.Identity
                ?.IsAuthenticated == true;

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