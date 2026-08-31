using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using PortalApp.Api.Idempotency;
using Xunit;

namespace PortalApp.UnitTests.Idempotency;

public sealed class IdempotencyMiddlewareTests
{
    [Fact]
    public async Task ReplaysSuccessfulMutation()
    {
        var calls = 0;
        RequestDelegate next = async context =>
        {
            calls++;
            context.Response.StatusCode = 200;
            context.Response.ContentType = "application/json";
            await context.Response.WriteAsync("{\"ok\":true}");
        };
        var store = new InMemoryIdempotencyStore();
        var middleware = Create(next, store);

        var first = Context("abcdefghijklmnop");
        await middleware.InvokeAsync(first);
        var second = Context("abcdefghijklmnop");
        await middleware.InvokeAsync(second);

        Assert.Equal(1, calls);
        Assert.Equal("true", second.Response.Headers["Idempotency-Replayed"]);
    }

    [Fact]
    public async Task RejectsDifferentRequestForSameKey()
    {
        RequestDelegate next = context => { context.Response.StatusCode = 204; return Task.CompletedTask; };
        var store = new InMemoryIdempotencyStore();
        var middleware = Create(next, store);
        var first = Context("abcdefghijklmnop", "/one");
        await middleware.InvokeAsync(first);
        var second = Context("abcdefghijklmnop", "/one", "?value=2");
        await middleware.InvokeAsync(second);
        Assert.Equal(409, second.Response.StatusCode);
    }

    [Fact]
    public async Task RequiresKeyForMutation()
    {
        var middleware = Create(_ => Task.CompletedTask, new InMemoryIdempotencyStore());
        var context = Context(null);
        await middleware.InvokeAsync(context);
        Assert.Equal(400, context.Response.StatusCode);
    }

    private static IdempotencyMiddleware Create(RequestDelegate next, IIdempotencyStore store) =>
        new(next, store, Options.Create(new IdempotencyOptions()), TimeProvider.System);

    private static DefaultHttpContext Context(string? key, string path = "/api/test", string query = "")
    {
        var context = new DefaultHttpContext();
        context.Request.Method = HttpMethods.Post;
        context.Request.Path = path;
        context.Request.QueryString = new QueryString(query);
        context.Request.Body = new MemoryStream();
        context.Response.Body = new MemoryStream();
        if (key is not null) { context.Request.Headers[IdempotencyMiddleware.HeaderName] = key; }
        return context;
    }
}