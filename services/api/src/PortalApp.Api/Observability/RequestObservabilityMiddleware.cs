using System.Diagnostics;
using System.Globalization;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Options;
using PortalApp.Api.Cancellation;

namespace PortalApp.Api.Observability;

public sealed class RequestObservabilityMiddleware
{
    public const string RequestDurationHeader =
        "X-Request-Duration-Ms";

    public const string TraceIdHeader =
        "X-Trace-ID";

    private readonly RequestDelegate _next;
    private readonly ILogger<RequestObservabilityMiddleware> _logger;
    private readonly ObservabilityOptions _options;

    public RequestObservabilityMiddleware(
        RequestDelegate next,
        ILogger<RequestObservabilityMiddleware> logger,
        IOptions<ObservabilityOptions> options)
    {
        ArgumentNullException.ThrowIfNull(next);
        ArgumentNullException.ThrowIfNull(logger);
        ArgumentNullException.ThrowIfNull(options);

        _next = next;
        _logger = logger;
        _options = options.Value;
    }

    public async Task InvokeAsync(
        HttpContext context)
    {
        ArgumentNullException.ThrowIfNull(context);

        var stopwatch =
            Stopwatch.StartNew();

        var traceId =
            Activity.Current?.TraceId.ToString();

        if (string.IsNullOrWhiteSpace(traceId))
        {
            traceId =
                context.TraceIdentifier;
        }

        var cancelled =
            false;

        if (_options.IncludeResponseHeaders)
        {
            context.Response.Headers[TraceIdHeader] =
                traceId;

            context.Response.OnStarting(
                static state =>
                {
                    var responseState =
                        (ResponseHeaderState)state;

                    SetDurationHeader(
                        responseState.Context,
                        responseState.Stopwatch);

                    return Task.CompletedTask;
                },
                new ResponseHeaderState(
                    context,
                    stopwatch));
        }

        try
        {
            await _next(context);
        }
        catch (OperationCanceledException)
        {
            cancelled = true;

            throw;
        }
        finally
        {
            stopwatch.Stop();

            if (_options.IncludeResponseHeaders &&
                !context.Response.HasStarted)
            {
                SetDurationHeader(
                    context,
                    stopwatch);
            }

            LogCompletion(
                context,
                stopwatch.ElapsedMilliseconds,
                traceId,
                cancelled);
        }
    }

    private void LogCompletion(
        HttpContext context,
        long durationMilliseconds,
        string traceId,
        bool cancelled)
    {
        var endpoint =
            context.GetEndpoint();

        var route =
            endpoint?.Metadata
                .GetMetadata<RouteNameMetadata>()
                ?.RouteName ??
            endpoint?.DisplayName ??
            context.Request.Path.Value ??
            "unknown";

        var timedOut =
            context.Items.ContainsKey(
                RequestCancellationMiddleware
                    .TimeoutFeatureKey);

        var idempotencyReplayed =
            string.Equals(
                context.Response.Headers[
                    "Idempotency-Replayed"]
                    .FirstOrDefault(),
                "true",
                StringComparison.OrdinalIgnoreCase);

        using var scope =
            _logger.BeginScope(
                new Dictionary<string, object?>
                {
                    ["TraceId"] =
                        traceId,

                    ["CorrelationId"] =
                        context.TraceIdentifier,

                    ["HttpMethod"] =
                        context.Request.Method,

                    ["Route"] =
                        route
                });

        if (durationMilliseconds >=
            _options
                .SlowRequestThresholdMilliseconds)
        {
            _logger.LogWarning(
                "Slow HTTP request completed. Method {Method}, route {Route}, status {StatusCode}, duration {DurationMilliseconds} ms, cancelled {Cancelled}, timed out {TimedOut}, idempotency replayed {IdempotencyReplayed}.",
                context.Request.Method,
                route,
                context.Response.StatusCode,
                durationMilliseconds,
                cancelled,
                timedOut,
                idempotencyReplayed);

            return;
        }

        _logger.LogInformation(
            "HTTP request completed. Method {Method}, route {Route}, status {StatusCode}, duration {DurationMilliseconds} ms, cancelled {Cancelled}, timed out {TimedOut}, idempotency replayed {IdempotencyReplayed}.",
            context.Request.Method,
            route,
            context.Response.StatusCode,
            durationMilliseconds,
            cancelled,
            timedOut,
            idempotencyReplayed);
    }

    private static void SetDurationHeader(
        HttpContext context,
        Stopwatch stopwatch)
    {
        context.Response.Headers[
            RequestDurationHeader] =
            stopwatch.ElapsedMilliseconds.ToString(
                CultureInfo.InvariantCulture);
    }

    private sealed record ResponseHeaderState(
        HttpContext Context,
        Stopwatch Stopwatch);
}