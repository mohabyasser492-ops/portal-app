using PortalApp.Api.Authorization;
using PortalApp.Api.Features.Leave;
using PortalApp.Infrastructure.Graph;
using PortalApp.Infrastructure.SharePoint.Attendance;

namespace PortalApp.Api.Features.Attendance;

public sealed class AttendanceService
    : IAttendanceService
{
    private const int DefaultRangeDays = 30;
    private const int MaximumRangeDays = 366;

    private readonly ICurrentUser _currentUser;
    private readonly CurrentEmployeeIdentifierResolver
        _employeeIdentifierResolver;
    private readonly IAttendanceRepository
        _repository;

    public AttendanceService(
        ICurrentUser currentUser,
        CurrentEmployeeIdentifierResolver
            employeeIdentifierResolver,
        IAttendanceRepository repository)
    {
        _currentUser = currentUser;
        _employeeIdentifierResolver =
            employeeIdentifierResolver;
        _repository = repository;
    }

    public async Task<AttendanceResponse>
        GetCurrentAsync(
            DateOnly? fromDate,
            DateOnly? toDate,
            string correlationId,
            CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(
                correlationId))
        {
            throw new ArgumentException(
                "A correlation identifier is required.",
                nameof(correlationId));
        }

        var resolvedToDate =
            toDate ??
            DateOnly.FromDateTime(
                DateTime.UtcNow);

        var resolvedFromDate =
            fromDate ??
            resolvedToDate.AddDays(
                -(DefaultRangeDays - 1));

        if (resolvedFromDate > resolvedToDate)
        {
            throw new ArgumentException(
                "The attendance start date cannot be later than the end date.",
                nameof(fromDate));
        }

        var inclusiveRangeDays =
            resolvedToDate.DayNumber -
            resolvedFromDate.DayNumber +
            1;

        if (inclusiveRangeDays > MaximumRangeDays)
        {
            throw new ArgumentOutOfRangeException(
                nameof(fromDate),
                $"The attendance date range cannot exceed {MaximumRangeDays} days.");
        }

        var employeeId =
            _employeeIdentifierResolver.Resolve(
                _currentUser);

        var context =
            new GraphRequestContext(
                correlationId,
                _currentUser.ObjectId,
                cancellationToken);

        var records =
            await _repository.GetForEmployeeAsync(
                employeeId,
                resolvedFromDate,
                resolvedToDate,
                context);

        var items =
            records
                .Select(
                    record =>
                        new AttendanceItemResponse(
                            AttendanceDate:
                                record.AttendanceDate,
                            CheckIn:
                                record.CheckIn,
                            CheckOut:
                                record.CheckOut,
                            Status:
                                record.Status,
                            WorkedMinutes:
                                record.WorkedMinutes,
                            Notes:
                                record.Notes,
                            LastUpdated:
                                record.LastUpdated))
                .ToArray();

        var summary =
            new AttendanceSummaryResponse(
                TotalRecords:
                    items.Length,
                PresentDays:
                    CountStatus(
                        items,
                        AttendanceStatus.Present),
                AbsentDays:
                    CountStatus(
                        items,
                        AttendanceStatus.Absent),
                LateDays:
                    CountStatus(
                        items,
                        AttendanceStatus.Late),
                RemoteDays:
                    CountStatus(
                        items,
                        AttendanceStatus.Remote),
                LeaveDays:
                    CountStatus(
                        items,
                        AttendanceStatus.Leave),
                HolidayDays:
                    CountStatus(
                        items,
                        AttendanceStatus.Holiday),
                TotalWorkedMinutes:
                    items.Sum(
                        item =>
                            item.WorkedMinutes ??
                            0));

        return new AttendanceResponse(
            EmployeeId:
                employeeId,
            FromDate:
                resolvedFromDate,
            ToDate:
                resolvedToDate,
            Summary:
                summary,
            Records:
                items);
    }

    private static int CountStatus(
        IEnumerable<AttendanceItemResponse> items,
        AttendanceStatus status)
    {
        return items.Count(
            item =>
                item.Status == status);
    }
}