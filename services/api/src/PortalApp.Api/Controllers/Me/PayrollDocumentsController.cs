using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Authorization.Policies;
using PortalApp.Api.Features.Payroll;

namespace PortalApp.Api.Controllers.Me;

[ApiController]
[Route("api/v1/me/payroll-documents")]
public sealed class PayrollDocumentsController : ControllerBase
{
    private readonly IPayrollDocumentService _service;

    public PayrollDocumentsController(IPayrollDocumentService service)
    {
        _service = service;
    }

    [HttpGet]
    [Authorize(Policy = PortalPolicies.EmployeeAccess)]
    [ProducesResponseType<PayrollDocumentsResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<PayrollDocumentsResponse>> Get(
        [FromQuery] int? year,
        [FromQuery] int? month,
        CancellationToken cancellationToken)
    {
        return Ok(await _service.GetCurrentAsync(
            year,
            month,
            HttpContext.TraceIdentifier,
            cancellationToken));
    }

    [HttpGet("{documentId}/content")]
    [Authorize(Policy = PortalPolicies.EmployeeAccess)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Download(
        string documentId,
        CancellationToken cancellationToken)
    {
        var download = await _service.DownloadCurrentAsync(
            documentId,
            HttpContext.TraceIdentifier,
            cancellationToken);

        if (download is null)
        {
            return NotFound();
        }

        Response.RegisterForDisposeAsync(download);
        Response.Headers.CacheControl = "no-store, private";
        Response.Headers.Pragma = "no-cache";
        Response.Headers["X-Content-Type-Options"] = "nosniff";
        Response.Headers["Content-Security-Policy"] = "sandbox; default-src 'none'";
        Response.Headers["Cross-Origin-Resource-Policy"] = "same-origin";
        Response.Headers["X-Download-Options"] = "noopen";
        if (download.ContentLength.HasValue)
        {
            Response.ContentLength = download.ContentLength.Value;
        }
        if (!string.IsNullOrWhiteSpace(download.ETag))
        {
            Response.Headers.ETag = download.ETag;
        }

        return File(download.Content, download.ContentType, download.FileName, enableRangeProcessing: false);
    }
}