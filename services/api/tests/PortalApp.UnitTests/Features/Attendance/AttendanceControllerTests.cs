using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Controllers.Me;
using PortalApp.Api.Features.Attendance;
using PortalApp.Infrastructure.SharePoint.Attendance;
using Xunit;

namespace PortalApp.UnitTests.Features.Attendance;

public sealed class AttendanceControllerTests
{
    [Fact]
    public async Task ReturnsAttendanceResponse()
    {
        var expected =
            new AttendanceResponse(
                EmployeeId:
                    "employee-001",
                FromDate:
                    new DateOnly(
                        2026,
                        8,
                        1),
                ToDate:
                    new DateOnly(
                        2026,
                        8,
                        31),
                Summary:
                    new AttendanceSummaryResponse(
                        TotalRecords:
                            1,
                        PresentDays:
                            1,
                        AbsentDays:
                            0,
                        LateDays:
                            0,
                        RemoteDays:
                            0,
                        LeaveDays:
                            0,
                        HolidayDays:
                            0,
                        TotalWorkedMinutes:
                            480),
                Records:
                [
                    new AttendanceItemResponse(
                        AttendanceDate:
                            new DateOnly(
                                2026,
                                8,
                                20),
                        CheckIn:
                            null,
                        CheckOut:
                            null,
                        Status:
                            AttendanceStatus.Present,
                        WorkedMinutes:
                            480,
                        Notes:
                            null,
                        LastUpdated:
                            null)
                ]);

        var service =
            new FakeAttendanceService(
                expected);

        var controller =
            new AttendanceController(
                service)
            {
                ControllerContext =
                    new ControllerContext
                    {
                        HttpContext =
                            new DefaultHttpContext
                            {
                                TraceIdentifier =
                                    "correlation-001"
                            }
                    }
            };

        var fromDate =
            new DateOnly(
                2026,
                8,
                1);

        var toDate =
            new DateOnly(
                2026,
                8,
                31);

        var result =
            await controller.Get(
                fromDate,
                toDate,
                CancellationToken.None);

        var okResult =
            Assert.IsType<
                OkObjectResult>(
                result.Result);

        Assert.Same(
            expected,
            okResult.Value);

        Assert.Equal(
            fromDate,
            service.FromDate);

        Assert.Equal(
            toDate,
            service.ToDate);

        Assert.Equal(
            "correlation-001",
            service.CorrelationId);
    }

    private sealed class FakeAttendanceService
        : IAttendanceService
    {
        private readonly AttendanceResponse
            _response;

        public FakeAttendanceService(
            AttendanceResponse response)
        {
            _response = response;
        }

        public DateOnly? FromDate
        {
            get;
            private set;
        }

        public DateOnly? ToDate
        {
            get;
            private set;
        }

        public string? CorrelationId
        {
            get;
            private set;
        }

        public Task<AttendanceResponse>
            GetCurrentAsync(
                DateOnly? fromDate,
                DateOnly? toDate,
                string correlationId,
                CancellationToken cancellationToken)
        {
            FromDate = fromDate;
            ToDate = toDate;
            CorrelationId = correlationId;

            return Task.FromResult(
                _response);
        }
    }
}