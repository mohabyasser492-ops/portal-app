using Microsoft.AspNetCore.Http;

namespace PortalApp.Api.Errors;

public sealed class PortalProblemDetailsCustomizer
{
    private readonly IHostEnvironment _environment;

    public PortalProblemDetailsCustomizer(
        IHostEnvironment environment)
    {
        _environment = environment;
    }

    public void Customize(
        ProblemDetailsContext context)
    {
        var problemDetails = context.ProblemDetails;

        problemDetails.Instance =
            context.HttpContext.Request.Path;

        problemDetails.Extensions["traceId"] =
            context.HttpContext.TraceIdentifier;

        problemDetails.Extensions["timestamp"] =
            DateTimeOffset.UtcNow;

        if (!_environment.IsDevelopment())
        {
            problemDetails.Extensions.Remove("exception");
        }
    }
}
