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
        var response =
            new PayrollDocumentsResponse(
                "employee-001",
                []);

        var service =
            new FakeService(response);

        var controller =
            CreateController(
                service,
                "correlation-001");

        var result =
            await controller.Get(
                year: null,
                month: null,
                CancellationToken.None);

        var okResult =
            Assert.IsType<OkObjectResult>(
                result.Result);

        Assert.Same(
            response,
            okResult.Value);

        Assert.Null(
            service.RequestedYear);

        Assert.Null(
            service.RequestedMonth);

        Assert.Equal(
            "correlation-001",
            service.CorrelationId);
    }

    [Fact]
    public async Task PassesPayrollPeriodToService()
    {
        var response =
            new PayrollDocumentsResponse(
                "employee-001",
                []);

        var service =
            new FakeService(response);

        var controller =
            CreateController(
                service,
                "correlation-002");

        var result =
            await controller.Get(
                year: 2026,
                month: 8,
                CancellationToken.None);

        Assert.IsType<OkObjectResult>(
            result.Result);

        Assert.Equal(
            2026,
            service.RequestedYear);

        Assert.Equal(
            8,
            service.RequestedMonth);

        Assert.Equal(
            "correlation-002",
            service.CorrelationId);
    }

    [Fact]
    public async Task ReturnsNotFoundForUnknownDocument()
    {
        var service =
            new FakeService(
                new PayrollDocumentsResponse(
                    "employee-001",
                    []));

        var controller =
            CreateController(
                service,
                "correlation-003");

        var result =
            await controller.Download(
                "missing",
                CancellationToken.None);

        Assert.IsType<NotFoundResult>(
            result);

        Assert.Equal(
            "missing",
            service.RequestedDocumentId);

        Assert.Equal(
            "correlation-003",
            service.CorrelationId);
    }

    [Fact]
    public async Task AddsSecureDownloadHeaders()
    {
        var owner =
            new TestOwner();

        var content =
            new MemoryStream(
            [
                0x25,
                0x50,
                0x44,
                0x46,
                0x2D
            ]);

        var download =
            new PayrollDownload(
                content,
                "application/pdf",
                "payslip.pdf",
                5,
                "etag-001",
                owner);

        var service =
            new FakeService(
                new PayrollDocumentsResponse(
                    "employee-001",
                    []),
                download);

        var controller =
            CreateController(
                service,
                "correlation-004");

        var result =
            await controller.Download(
                "doc-1",
                CancellationToken.None);

        var fileResult =
            Assert.IsType<FileStreamResult>(
                result);

        Assert.Same(
            download.Content,
            fileResult.FileStream);

        Assert.Equal(
            "application/pdf",
            fileResult.ContentType);

        Assert.Equal(
            "payslip.pdf",
            fileResult.FileDownloadName);

        Assert.Equal(
            "nosniff",
            controller.Response.Headers[
                "X-Content-Type-Options"]);

        Assert.Equal(
            "no-store, private",
            controller.Response.Headers.CacheControl);

        Assert.Equal(
            "no-cache",
            controller.Response.Headers.Pragma);

        Assert.Equal(
            "same-origin",
            controller.Response.Headers[
                "Cross-Origin-Resource-Policy"]);

        Assert.Equal(
            "noopen",
            controller.Response.Headers[
                "X-Download-Options"]);

        Assert.Equal(
            "sandbox; default-src 'none'",
            controller.Response.Headers[
                "Content-Security-Policy"]);

        Assert.Equal(
            "doc-1",
            service.RequestedDocumentId);

        Assert.Equal(
            "correlation-004",
            service.CorrelationId);

        Assert.False(
            owner.IsDisposed);

        await download.DisposeAsync();

        Assert.True(
            owner.IsDisposed);

        content.Dispose();
    }

    private static PayrollDocumentsController
        CreateController(
            IPayrollDocumentService service,
            string correlationId)
    {
        return new PayrollDocumentsController(
            service)
        {
            ControllerContext =
                new ControllerContext
                {
                    HttpContext =
                        new DefaultHttpContext
                        {
                            TraceIdentifier =
                                correlationId
                        }
                }
        };
    }

    private sealed class FakeService
        : IPayrollDocumentService
    {
        private readonly PayrollDocumentsResponse
            _response;

        private readonly PayrollDownload?
            _download;

        public FakeService(
            PayrollDocumentsResponse response,
            PayrollDownload? download = null)
        {
            _response = response;
            _download = download;
        }

        public int? RequestedYear
        {
            get;
            private set;
        }

        public int? RequestedMonth
        {
            get;
            private set;
        }

        public string? RequestedDocumentId
        {
            get;
            private set;
        }

        public string? CorrelationId
        {
            get;
            private set;
        }

        public Task<PayrollDocumentsResponse>
            GetCurrentAsync(
                int? year,
                int? month,
                string correlationId,
                CancellationToken cancellationToken)
        {
            cancellationToken
                .ThrowIfCancellationRequested();

            RequestedYear = year;
            RequestedMonth = month;
            CorrelationId = correlationId;

            return Task.FromResult(
                _response);
        }

        public Task<PayrollDownload?>
            DownloadCurrentAsync(
                string documentId,
                string correlationId,
                CancellationToken cancellationToken)
        {
            cancellationToken
                .ThrowIfCancellationRequested();

            RequestedDocumentId =
                documentId;

            CorrelationId =
                correlationId;

            return Task.FromResult(
                _download);
        }
    }

    private sealed class TestOwner
        : IAsyncDisposable
    {
        public bool IsDisposed
        {
            get;
            private set;
        }

        public ValueTask DisposeAsync()
        {
            IsDisposed = true;

            return ValueTask.CompletedTask;
        }
    }
}