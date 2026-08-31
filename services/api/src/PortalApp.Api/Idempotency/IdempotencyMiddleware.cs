using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;

namespace PortalApp.Api.Idempotency;

public sealed class IdempotencyMiddleware
{
    public const string HeaderName = "Idempotency-Key";
    private readonly RequestDelegate _next;
    private readonly IIdempotencyStore _store;
    private readonly IdempotencyOptions _options;
    private readonly TimeProvider _timeProvider;

    public IdempotencyMiddleware(
        RequestDelegate next,
        IIdempotencyStore store,
        IOptions<IdempotencyOptions> options,
        TimeProvider timeProvider)
    {
        _next = next;
        _store = store;
        _options = options.Value;
        _timeProvider = timeProvider;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (!RequiresIdempotency(context.Request.Method))
        {
            await _next(context);
            return;
        }

        var key = context.Request.Headers[HeaderName].FirstOrDefault()?.Trim();
        if (!IsValidKey(key))
        {
            await WriteProblemAsync(context, 400, "Invalid idempotency key", "A valid Idempotency-Key header is required.");
            return;
        }

        context.Request.EnableBuffering();
        if (context.Request.ContentLength is > 0 && context.Request.ContentLength > _options.MaximumBodyBytes)
        {
            await WriteProblemAsync(context, 413, "Request too large", "The request body exceeds the idempotency limit.");
            return;
        }

        var bodyHash = await HashBodyAsync(context.Request, context.RequestAborted);
        var userId = context.User.FindFirstValue("oid") ?? context.User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "anonymous";
        var scope = $"{userId}:{context.Request.Method}:{context.Request.Path}:{key}";
        var fingerprint = $"{context.Request.Method}|{context.Request.Path}|{context.Request.QueryString}|{bodyHash}";
        var acquired = _store.Acquire(scope, fingerprint, _timeProvider.GetUtcNow());

        if (acquired.Status == IdempotencyAcquireStatus.Conflict)
        {
            await WriteProblemAsync(context, 409, "Idempotency conflict", "The idempotency key was reused for a different request.");
            return;
        }

        if (acquired.Status == IdempotencyAcquireStatus.Replay)
        {
            var record = acquired.Record ?? (acquired.Pending is null ? null : await acquired.Pending.WaitAsync(context.RequestAborted));
            if (record is null)
            {
                await WriteProblemAsync(context, 409, "Idempotency retry required", "The original request did not complete successfully.");
                return;
            }
            await ReplayAsync(context, record);
            return;
        }

        var originalBody = context.Response.Body;
        await using var capture = new MemoryStream();
        context.Response.Body = capture;
        try
        {
            await _next(context);
            capture.Position = 0;
            if (context.Response.StatusCode is >= 200 and < 300)
            {
                var bytes = capture.ToArray();
                _store.Complete(scope, new IdempotencyRecord(
                    fingerprint,
                    context.Response.StatusCode,
                    context.Response.ContentType,
                    bytes,
                    _timeProvider.GetUtcNow().AddMinutes(_options.RetentionMinutes)));
            }
            else
            {
                _store.Abandon(scope);
            }
            await capture.CopyToAsync(originalBody, context.RequestAborted);
        }
        catch
        {
            _store.Abandon(scope);
            throw;
        }
        finally
        {
            context.Response.Body = originalBody;
        }
    }

    private bool IsValidKey(string? key) =>
        !string.IsNullOrWhiteSpace(key) &&
        key.Length is >= 16 && key.Length <= _options.MaximumKeyLength &&
        key.All(character => char.IsLetterOrDigit(character) || character is '-' or '_');

    private static bool RequiresIdempotency(string method) =>
        HttpMethods.IsPost(method) || HttpMethods.IsPut(method) || HttpMethods.IsPatch(method) || HttpMethods.IsDelete(method);

    private async Task<string> HashBodyAsync(HttpRequest request, CancellationToken cancellationToken)
    {
        using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        var buffer = new byte[8192];
        var total = 0;
        int read;
        while ((read = await request.Body.ReadAsync(buffer.AsMemory(), cancellationToken)) > 0)
        {
            total += read;
            if (total > _options.MaximumBodyBytes) { throw new InvalidOperationException("The request body exceeds the idempotency limit."); }
            hash.AppendData(buffer, 0, read);
        }
        request.Body.Position = 0;
        return Convert.ToHexString(hash.GetHashAndReset());
    }

    private static async Task ReplayAsync(HttpContext context, IdempotencyRecord record)
    {
        context.Response.StatusCode = record.StatusCode;
        context.Response.ContentType = record.ContentType;
        context.Response.Headers["Idempotency-Replayed"] = "true";
        await context.Response.Body.WriteAsync(record.Body, context.RequestAborted);
    }

    private static async Task WriteProblemAsync(HttpContext context, int status, string title, string detail)
    {
        context.Response.StatusCode = status;
        context.Response.ContentType = "application/problem+json";
        await JsonSerializer.SerializeAsync(context.Response.Body, new { title, status, detail, traceId = context.TraceIdentifier }, cancellationToken: CancellationToken.None);
    }
}