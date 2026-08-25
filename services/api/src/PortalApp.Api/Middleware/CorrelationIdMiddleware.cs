using Microsoft.Extensions.Primitives;

namespace PortalApp.Api.Middleware;

public sealed class CorrelationIdMiddleware
{
    public const string HeaderName = "X-Correlation-ID";

    private const int MaximumLength = 128;

    private readonly RequestDelegate _next;
    private readonly ILogger<CorrelationIdMiddleware> _logger;

    public CorrelationIdMiddleware(
        RequestDelegate next,
        ILogger<CorrelationIdMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId =
            GetOrCreateCorrelationId(context);

        context.TraceIdentifier = correlationId;
        context.Response.Headers[HeaderName] =
            correlationId;

        using (_logger.BeginScope(
                   new Dictionary<string, object>
                   {
                       ["CorrelationId"] = correlationId
                   }))
        {
            await _next(context);
        }
    }

    private static string GetOrCreateCorrelationId(
        HttpContext context)
    {
        if (context.Request.Headers.TryGetValue(
                HeaderName,
                out StringValues values))
        {
            var suppliedValue = values.FirstOrDefault();

            if (IsValid(suppliedValue))
            {
                return suppliedValue!;
            }
        }

        return Guid.NewGuid().ToString("N");
    }

    private static bool IsValid(string? value)
    {
        return !string.IsNullOrWhiteSpace(value) &&
               value.Length <= MaximumLength &&
               value.All(character =>
                   char.IsLetterOrDigit(character) ||
                   character is '-' or '_');
    }
}