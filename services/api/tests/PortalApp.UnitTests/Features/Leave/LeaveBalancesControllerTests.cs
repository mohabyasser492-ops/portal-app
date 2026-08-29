using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Controllers.Me;
using PortalApp.Api.Features.Leave;
using Xunit;

namespace PortalApp.UnitTests.Features.Leave;

public sealed class LeaveBalancesControllerTests
{
    [Fact]
    public async Task ReturnsServiceResponse()
    {
        var expected =
            new LeaveBalanceResponse(
                "employee-001",
                30m,
                8m,
                2m,
                20m,
                []);

        var service =
            new FakeService(expected);

        var controller =
            new LeaveBalancesController(
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

        var result =
            await controller.Get(
                CancellationToken.None);

        var ok =
            Assert.IsType<
                OkObjectResult>(
                result.Result);

        Assert.Same(
            expected,
            ok.Value);

        Assert.Equal(
            "correlation-001",
            service.CorrelationId);
    }

    private sealed class FakeService
        : ILeaveBalanceService
    {
        private readonly LeaveBalanceResponse
            _response;

        public FakeService(
            LeaveBalanceResponse response)
        {
            _response = response;
        }

        public string? CorrelationId
        {
            get;
            private set;
        }

        public Task<LeaveBalanceResponse>
            GetCurrentAsync(
                string correlationId,
                CancellationToken cancellationToken)
        {
            CorrelationId = correlationId;

            return Task.FromResult(
                _response);
        }
    }
}