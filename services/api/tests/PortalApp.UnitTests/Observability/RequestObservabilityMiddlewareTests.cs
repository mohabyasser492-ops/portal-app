using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using PortalApp.Api.Observability;
using Xunit;

namespace PortalApp.UnitTests.Observability;

public sealed class RequestObservabilityMiddlewareTests
{
    [Fact]
    public async Task AddsDiagnosticHeadersAndLogsCompletion()
    {
        var logger = new CapturingLogger<RequestObservabilityMiddleware>();
        var middleware = Create(
            context =>
            {
                context.Response.StatusCode = StatusCodes.Status204NoContent;
                return Task.CompletedTask;
            },
            logger,
            1000);
        var context = new DefaultHttpContext
        {
            TraceIdentifier = "correlation-001"
        };

        await middleware.InvokeAsync(context);
        await context.Response.StartAsync();

        Assert.Equal("correlation-001", context.Response.Headers[RequestObservabilityMiddleware.TraceIdHeader]);
        Assert.True(context.Response.Headers.ContainsKey(RequestObservabilityMiddleware.RequestDurationHeader));
        Assert.Contains(logger.Entries, entry => entry.Level == LogLevel.Information);
    }

    [Fact]
    public async Task LogsSlowRequestAsWarning()
    {
        var logger = new CapturingLogger<RequestObservabilityMiddleware>();
        var middleware = Create(
            async _ => await Task.Delay(120),
            logger,
            100);
        var context = new DefaultHttpContext
        {
            TraceIdentifier = "correlation-002"
        };

        await middleware.InvokeAsync(context);

        Assert.Contains(logger.Entries, entry => entry.Level == LogLevel.Warning);
    }

    [Fact]
    public async Task RethrowsCancellationAndRecordsIt()
    {
        var logger = new CapturingLogger<RequestObservabilityMiddleware>();
        var middleware = Create(
            _ => Task.FromCanceled(new CancellationToken(true)),
            logger,
            1000);
        var context = new DefaultHttpContext();

        await Assert.ThrowsAnyAsync<OperationCanceledException>(() => middleware.InvokeAsync(context));
        Assert.Contains(logger.Entries, entry => entry.Message.Contains("cancelled True", StringComparison.Ordinal));
    }

    private static RequestObservabilityMiddleware Create(
        RequestDelegate next,
        ILogger<RequestObservabilityMiddleware> logger,
        int threshold) =>
        new(
            next,
            logger,
            Options.Create(new ObservabilityOptions
            {
                SlowRequestThresholdMilliseconds = threshold,
                IncludeResponseHeaders = true
            }));

    private sealed class CapturingLogger<T> : ILogger<T>
    {
        public List<(LogLevel Level, string Message)> Entries { get; } = [];
        public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;
        public bool IsEnabled(LogLevel logLevel) => true;
        public void Log<TState>(
            LogLevel logLevel,
            EventId eventId,
            TState state,
            Exception? exception,
            Func<TState, Exception?, string> formatter)
        {
            Entries.Add((logLevel, formatter(state, exception)));
        }
    }
}