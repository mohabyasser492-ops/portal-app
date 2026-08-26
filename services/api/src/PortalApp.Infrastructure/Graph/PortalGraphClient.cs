using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace PortalApp.Infrastructure.Graph;

public sealed class PortalGraphClient : IPortalGraphClient
{
    public const string ClientName = "PortalGraph";

    private static readonly JsonSerializerOptions JsonOptions =
        new(JsonSerializerDefaults.Web);

    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IGraphAccessTokenProvider _tokenProvider;
    private readonly GraphOptions _options;
    private readonly ILogger<PortalGraphClient> _logger;
    private readonly Uri _baseUri;

    public PortalGraphClient(
        IHttpClientFactory httpClientFactory,
        IGraphAccessTokenProvider tokenProvider,
        IOptions<GraphOptions> options,
        ILogger<PortalGraphClient> logger)
    {
        _httpClientFactory = httpClientFactory;
        _tokenProvider = tokenProvider;
        _options = options.Value;
        _logger = logger;

        _baseUri = new Uri(
            EnsureTrailingSlash(_options.BaseUrl),
            UriKind.Absolute);
    }

    public async Task<GraphPage<T>> GetPageAsync<T>(
        string relativePath,
        GraphRequestContext context)
    {
        ArgumentNullException.ThrowIfNull(context);

        var requestUri = CreateRequestUri(relativePath);

        using var response = await SendGetAsync(
            requestUri,
            context);

        await EnsureSuccessAsync(
            response,
            context.CancellationToken);

        await using var stream =
            await response.Content.ReadAsStreamAsync(
                context.CancellationToken);

        var graphResponse =
            await JsonSerializer.DeserializeAsync<
                GraphCollectionResponse<T>>(
                stream,
                JsonOptions,
                context.CancellationToken);

        if (graphResponse is null)
        {
            throw new GraphServiceException(
                "Microsoft Graph returned an empty collection response.",
                statusCode: (int)response.StatusCode);
        }

        return new GraphPage<T>(
            graphResponse.Value,
            graphResponse.NextLink);
    }

    public async Task<T?> GetAsync<T>(
        string relativePath,
        GraphRequestContext context)
    {
        ArgumentNullException.ThrowIfNull(context);

        var requestUri = CreateRequestUri(relativePath);

        using var response = await SendGetAsync(
            requestUri,
            context);

        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return default;
        }

        await EnsureSuccessAsync(
            response,
            context.CancellationToken);

        await using var stream =
            await response.Content.ReadAsStreamAsync(
                context.CancellationToken);

        return await JsonSerializer.DeserializeAsync<T>(
            stream,
            JsonOptions,
            context.CancellationToken);
    }

    private async Task<HttpResponseMessage> SendGetAsync(
        Uri requestUri,
        GraphRequestContext context)
    {
        var accessToken =
            await _tokenProvider.GetAccessTokenAsync(
                _options.Scopes,
                context.CancellationToken);

        var attempts = 0;

        while (true)
        {
            attempts++;

            using var request =
                new HttpRequestMessage(
                    HttpMethod.Get,
                    requestUri);

            request.Headers.Authorization =
                new AuthenticationHeaderValue(
                    "Bearer",
                    accessToken);

            request.Headers.Accept.Add(
                new MediaTypeWithQualityHeaderValue(
                    "application/json"));

            request.Headers.TryAddWithoutValidation(
                "client-request-id",
                context.CorrelationId);

            request.Headers.TryAddWithoutValidation(
                "return-client-request-id",
                "true");

            var client =
                _httpClientFactory.CreateClient(
                    ClientName);

            var response = await client.SendAsync(
                request,
                HttpCompletionOption.ResponseHeadersRead,
                context.CancellationToken);

            if (!IsTransient(response.StatusCode) ||
                attempts > _options.MaximumRetryAttempts)
            {
                return response;
            }

            var delay = GetRetryDelay(
                response,
                attempts);

            _logger.LogWarning(
                "Microsoft Graph request returned status {StatusCode}. Retrying after {DelayMilliseconds} milliseconds. Attempt {Attempt}.",
                (int)response.StatusCode,
                delay.TotalMilliseconds,
                attempts);

            response.Dispose();

            await Task.Delay(
                delay,
                context.CancellationToken);
        }
    }

    private Uri CreateRequestUri(string relativePath)
    {
        if (string.IsNullOrWhiteSpace(relativePath))
        {
            throw new ArgumentException(
                "A Microsoft Graph request path is required.",
                nameof(relativePath));
        }

        if (Uri.TryCreate(
                relativePath,
                UriKind.Absolute,
                out var absoluteUri))
        {
            if (!string.Equals(
                    absoluteUri.Scheme,
                    _baseUri.Scheme,
                    StringComparison.OrdinalIgnoreCase) ||
                !string.Equals(
                    absoluteUri.Host,
                    _baseUri.Host,
                    StringComparison.OrdinalIgnoreCase) ||
                absoluteUri.Port != _baseUri.Port)
            {
                throw new ArgumentException(
                    "The Microsoft Graph continuation URL has an unexpected origin.",
                    nameof(relativePath));
            }

            return absoluteUri;
        }

        var normalizedPath =
            relativePath.TrimStart('/');

        return new Uri(
            _baseUri,
            normalizedPath);
    }

    private static bool IsTransient(
        HttpStatusCode statusCode)
    {
        return statusCode is
            HttpStatusCode.RequestTimeout or
            HttpStatusCode.TooManyRequests or
            HttpStatusCode.InternalServerError or
            HttpStatusCode.BadGateway or
            HttpStatusCode.ServiceUnavailable or
            HttpStatusCode.GatewayTimeout;
    }

    private static TimeSpan GetRetryDelay(
        HttpResponseMessage response,
        int attempt)
    {
        var retryAfter =
            response.Headers.RetryAfter;

        if (retryAfter?.Delta is TimeSpan delta &&
            delta > TimeSpan.Zero)
        {
            return delta;
        }

        if (retryAfter?.Date is DateTimeOffset date)
        {
            var calculatedDelay =
                date - DateTimeOffset.UtcNow;

            if (calculatedDelay > TimeSpan.Zero)
            {
                return calculatedDelay;
            }
        }

        var seconds =
            Math.Min(
                Math.Pow(2, attempt - 1),
                8);

        return TimeSpan.FromSeconds(seconds);
    }

    private static async Task EnsureSuccessAsync(
        HttpResponseMessage response,
        CancellationToken cancellationToken)
    {
        if (response.IsSuccessStatusCode)
        {
            return;
        }

        GraphErrorEnvelope? envelope = null;

        try
        {
            await using var stream =
                await response.Content.ReadAsStreamAsync(
                    cancellationToken);

            envelope =
                await JsonSerializer.DeserializeAsync<
                    GraphErrorEnvelope>(
                    stream,
                    JsonOptions,
                    cancellationToken);
        }
        catch (JsonException)
        {
            // The response did not contain a Graph error envelope.
        }

        var retryAfter =
            GetResponseRetryAfter(response);

        throw new GraphServiceException(
            envelope?.Error?.Message ??
            "Microsoft Graph request failed.",
            statusCode: (int)response.StatusCode,
            errorCode: envelope?.Error?.Code,
            retryAfter: retryAfter);
    }

    private static TimeSpan? GetResponseRetryAfter(
        HttpResponseMessage response)
    {
        var retryAfter =
            response.Headers.RetryAfter;

        if (retryAfter?.Delta is TimeSpan delta &&
            delta > TimeSpan.Zero)
        {
            return delta;
        }

        if (retryAfter?.Date is not DateTimeOffset date)
        {
            return null;
        }

        var calculatedDelay =
            date - DateTimeOffset.UtcNow;

        return calculatedDelay > TimeSpan.Zero
            ? calculatedDelay
            : null;
    }

    private static string EnsureTrailingSlash(
        string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException(
                "The Microsoft Graph base URL is required.",
                nameof(value));
        }

        return value.EndsWith(
            "/",
            StringComparison.Ordinal)
            ? value
            : $"{value}/";
    }
}