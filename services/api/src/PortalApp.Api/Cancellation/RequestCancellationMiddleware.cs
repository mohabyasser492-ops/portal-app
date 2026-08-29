using System.Text.Json;
using Microsoft.Extensions.Options;

namespace PortalApp.Api.Cancellation;

public sealed class RequestCancellationMiddleware
{
    public const string TimeoutFeatureKey =
        "PortalApp.RequestTimedOut";

    private static readonly JsonSerializerOptions JsonOptions =
        new(JsonSerializerDefaults.Web);

    private readonly RequestDelegate _next;
    private readonly RequestCancellationOptions _options;
    private readonly ILogger<RequestCancellationMiddleware> _logger;

    public RequestCancellationMiddleware(
        RequestDelegate next,
        IOptions<RequestCancellationOptions> options,
        ILogger<RequestCancellationMiddleware> logger)
    {
        ArgumentNullException.ThrowIfNull(next);
        ArgumentNullException.ThrowIfNull(options);
        ArgumentNullException.ThrowIfNull(logger);

        _next = next;
        _options = options.Value;
        _logger = logger;
    }

    public async Task InvokeAsync(
        HttpContext context)
    {
        ArgumentNullException.ThrowIfNull(context);

        var originalToken =
            context.RequestAborted;

        using var timeoutSource =
            new CancellationTokenSource(
                TimeSpan.FromSeconds(
                    _options.TimeoutSeconds));

        using var linkedSource =
            CancellationTokenSource
                .CreateLinkedTokenSource(
                    originalToken,
                    timeoutSource.Token);

        context.RequestAborted =
            linkedSource.Token;

        try
        {
            await _next(context);
        }
        catch (OperationCanceledException)
            when (
                timeoutSource.IsCancellationRequested &&
                !originalToken.IsCancellationRequested)
        {
            context.Items[TimeoutFeatureKey] =
                true;

            _logger.LogWarning(
                "Request {TraceIdentifier} exceeded the configured timeout of {TimeoutSeconds} seconds.",
                context.TraceIdentifier,
                _options.TimeoutSeconds);

            if (context.Response.HasStarted)
            {
                throw;
            }

            await WriteTimeoutResponseAsync(
                context);
        }
        catch (OperationCanceledException)
            when (originalToken.IsCancellationRequested)
        {
            _logger.LogInformation(
                "Request {TraceIdentifier} was cancelled by the client.",
                context.TraceIdentifier);

            throw;
        }
        finally
        {
            context.RequestAborted =
                originalToken;
        }
    }

    private static async Task WriteTimeoutResponseAsync(
        HttpContext context)
    {
        context.Response.Clear();

        context.Response.StatusCode =
            StatusCodes.Status408RequestTimeout;

        context.Response.ContentType =
            "application/problem+json";

        var problemDetails =
            new
            {
                type =
                    "https://portal-app.example/errors/request-timeout",
                title =
                    "Request timeout",
                status =
                    StatusCodes.Status408RequestTimeout,
                detail =
                    "The request exceeded the permitted processing time.",
                instance =
                    context.Request.Path.Value,
                traceId =
                    context.TraceIdentifier
            };

        await JsonSerializer.SerializeAsync(
            context.Response.Body,
            problemDetails,
            JsonOptions,
            CancellationToken.None);
    }
}