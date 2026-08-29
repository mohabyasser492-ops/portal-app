using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Controllers.Me;
using PortalApp.Api.Features.Payroll;
using Xunit;

namespace PortalApp.UnitTests.Features.Payroll;

public sealed class PayrollDocumentsControllerTests
{
    [Fact]
    public async Task ReturnsPayrollDocuments()
    {
        var response = new PayrollDocumentsResponse("employee-001", []);
        var service = new FakeService(response);
        var controller = new PayrollDocumentsController(service)
        {
            ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext { TraceIdentifier = "correlation-001" }
            }
        };

        var result = await controller.Get(null, null, CancellationToken.None);
        var ok = Assert.IsType<OkObjectResult>(result.Result);
        Assert.Same(response, ok.Value);
    }

    [Fact]
    public async Task ReturnsNotFoundForUnknownDocument()
    {
        var service = new FakeService(new PayrollDocumentsResponse("employee-001", []));
        var controller = new PayrollDocumentsController(service)
        {
            ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() }
        };

        var result = await controller.Download("missing", CancellationToken.None);
        Assert.IsType<NotFoundResult>(result);
    }

    private sealed class FakeService : IPayrollDocumentService
    {
        private readonly PayrollDocumentsResponse _response;
        public FakeService(PayrollDocumentsResponse response) => _response = response;
        public Task<PayrollDocumentsResponse> GetCurrentAsync(int? year, int? month, string correlationId, CancellationToken cancellationToken) => Task.FromResult(_response);
        public Task<PayrollDownload?> DownloadCurrentAsync(string documentId, string correlationId, CancellationToken cancellationToken) => Task.FromResult<PayrollDownload?>(null);
    }
}