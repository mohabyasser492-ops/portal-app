using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using PortalApp.Api.Cancellation;
using Xunit;

namespace PortalApp.UnitTests.Cancellation;

public sealed class RequestCancellationMiddlewareTests
{
    [Fact]
    public async Task PassesLinkedCancellationTokenToNextMiddleware()
    {
        CancellationToken observedToken = default;
        RequestDelegate next = context =>
        {
            observedToken = context.RequestAborted;
            return Task.CompletedTask;
        };

        var middleware = CreateMiddleware(next, 30);
        var context = CreateContext();
        var originalToken = context.RequestAborted;

        await middleware.InvokeAsync(context);

        Assert.NotEqual(originalToken, observedToken);
        Assert.Equal(originalToken, context.RequestAborted);
        Assert.Equal(StatusCodes.Status200OK, context.Response.StatusCode);
    }

    [Fact]
    public async Task ReturnsProblemDetailsWhenTimeoutExpires()
    {
        RequestDelegate next = async context =>
        {
            await Task.Delay(TimeSpan.FromSeconds(10), context.RequestAborted);
        };

        var middleware = CreateMiddleware(next, 1);
        var context = CreateContext();
        context.Request.Path = "/api/v1/me/attendance";
        context.TraceIdentifier = "trace-001";

        await middleware.InvokeAsync(context);

        Assert.Equal(StatusCodes.Status408RequestTimeout, context.Response.StatusCode);
        Assert.Equal("application/problem+json", context.Response.ContentType);
        Assert.True(context.Items.ContainsKey(RequestCancellationMiddleware.TimeoutFeatureKey));

        context.Response.Body.Position = 0;
        using var document = await JsonDocument.ParseAsync(context.Response.Body);
        Assert.Equal(408, document.RootElement.GetProperty("status").GetInt32());
        Assert.Equal("trace-001", document.RootElement.GetProperty("traceId").GetString());
    }

    [Fact]
    public async Task RethrowsClientCancellation()
    {
        using var clientCancellation = new CancellationTokenSource();
        clientCancellation.Cancel();

        RequestDelegate next = context =>
            Task.FromCanceled(context.RequestAborted);

        var middleware = CreateMiddleware(next, 30);
        var context = CreateContext();
        context.RequestAborted = clientCancellation.Token;

        await Assert.ThrowsAnyAsync<OperationCanceledException>(
            () => middleware.InvokeAsync(context));
    }

    [Fact]
    public async Task RestoresOriginalRequestTokenAfterFailure()
    {
        using var originalSource = new CancellationTokenSource();
        RequestDelegate next = _ =>
            throw new InvalidOperationException("Synthetic failure.");

        var middleware = CreateMiddleware(next, 30);
        var context = CreateContext();
        context.RequestAborted = originalSource.Token;

        await Assert.ThrowsAsync<InvalidOperationException>(
            () => middleware.InvokeAsync(context));

        Assert.Equal(originalSource.Token, context.RequestAborted);
    }

    private static RequestCancellationMiddleware CreateMiddleware(
        RequestDelegate next,
        int timeoutSeconds)
    {
        return new RequestCancellationMiddleware(
            next,
            Options.Create(new RequestCancellationOptions
            {
                TimeoutSeconds = timeoutSeconds
            }),
            NullLogger<RequestCancellationMiddleware>.Instance);
    }

    private static DefaultHttpContext CreateContext()
    {
        return new DefaultHttpContext
        {
            Response =
            {
                Body = new MemoryStream()
            }
        };
    }
}