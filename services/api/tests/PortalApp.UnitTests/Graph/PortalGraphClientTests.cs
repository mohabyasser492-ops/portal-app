using System.Net;
using System.Text;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using PortalApp.Infrastructure.Graph;
using Xunit;

namespace PortalApp.UnitTests.Graph;

public sealed class PortalGraphClientTests
{
    [Fact]
    public async Task GetAsyncReturnsDeserializedObject()
    {
        var handler = new RecordingHttpMessageHandler(
            _ => JsonResponse(
                HttpStatusCode.OK,
                """
                {
                  "id": "employee-001",
                  "displayName": "Test Employee"
                }
                """));

        var client = CreateClient(handler);

        var result = await client.GetAsync<TestGraphItem>(
            "users/employee-001",
            CreateContext());

        Assert.NotNull(result);
        Assert.Equal("employee-001", result.Id);
        Assert.Equal("Test Employee", result.DisplayName);
    }

    [Fact]
    public async Task GetAsyncReturnsNullForNotFound()
    {
        var handler = new RecordingHttpMessageHandler(
            _ => new HttpResponseMessage(
                HttpStatusCode.NotFound));

        var client = CreateClient(handler);

        var result = await client.GetAsync<TestGraphItem>(
            "users/missing",
            CreateContext());

        Assert.Null(result);
    }

    [Fact]
    public async Task GetPageAsyncMapsItemsAndContinuationLink()
    {
        var handler = new RecordingHttpMessageHandler(
            _ => JsonResponse(
                HttpStatusCode.OK,
                """
                {
                  "value": [
                    {
                      "id": "employee-001",
                      "displayName": "Test Employee"
                    },
                    {
                      "id": "employee-002",
                      "displayName": "Second Employee"
                    }
                  ],
                  "@odata.nextLink": "https://graph.microsoft.com/v1.0/users?$skiptoken=synthetic"
                }
                """));

        var client = CreateClient(handler);

        var page = await client.GetPageAsync<TestGraphItem>(
            "users",
            CreateContext());

        Assert.Equal(2, page.Items.Count);
        Assert.True(page.HasNextPage);
        Assert.Contains(
            "skiptoken=synthetic",
            page.NextLink);
    }

    [Fact]
    public async Task RequestContainsBearerTokenAndCorrelationId()
    {
        var handler = new RecordingHttpMessageHandler(
            _ => JsonResponse(
                HttpStatusCode.OK,
                """
                {
                  "id": "employee-001",
                  "displayName": "Test Employee"
                }
                """));

        var client = CreateClient(handler);

        await client.GetAsync<TestGraphItem>(
            "users/employee-001",
            CreateContext("portal-test-001"));

        var request = Assert.Single(handler.Requests);

        Assert.Equal(
            "Bearer",
            request.AuthorizationScheme);

        Assert.Equal(
            "synthetic-access-token",
            request.AuthorizationParameter);

        Assert.Equal(
            "portal-test-001",
            request.correlationId);

        Assert.Equal(
            "true",
            request.ReturnCorrelationId);
    }

    [Fact]
    public async Task GraphErrorIsNormalized()
    {
        var handler = new RecordingHttpMessageHandler(
            _ => JsonResponse(
                HttpStatusCode.Forbidden,
                """
                {
                  "error": {
                    "code": "accessDenied",
                    "message": "Synthetic access denial."
                  }
                }
                """));

        var client = CreateClient(handler);

        var exception =
            await Assert.ThrowsAsync<GraphServiceException>(
                () => client.GetAsync<TestGraphItem>(
                    "users/employee-001",
                    CreateContext()));

        Assert.Equal(403, exception.StatusCode);
        Assert.Equal(
            "accessDenied",
            exception.ErrorCode);
        Assert.False(exception.IsTransient);
    }

    [Fact]
    public async Task ForeignContinuationUrlIsRejected()
    {
        var handler = new RecordingHttpMessageHandler(
            _ => throw new InvalidOperationException(
                "HTTP should not be called."));

        var client = CreateClient(handler);

        await Assert.ThrowsAsync<ArgumentException>(
            () => client.GetPageAsync<TestGraphItem>(
                "https://example.test/v1.0/users",
                CreateContext()));

        Assert.Empty(handler.Requests);
    }

    [Fact]
    public async Task TransientResponseIsRetried()
    {
        var responses = new Queue<HttpResponseMessage>();

        responses.Enqueue(
            new HttpResponseMessage(
                HttpStatusCode.ServiceUnavailable));

        responses.Enqueue(
            JsonResponse(
                HttpStatusCode.OK,
                """
                {
                  "id": "employee-001",
                  "displayName": "Test Employee"
                }
                """));

        var handler = new RecordingHttpMessageHandler(
            _ => responses.Dequeue());

        var client = CreateClient(
            handler,
            maximumRetryAttempts: 1);

        var result = await client.GetAsync<TestGraphItem>(
            "users/employee-001",
            CreateContext());

        Assert.NotNull(result);
        Assert.Equal(2, handler.Requests.Count);
    }

    [Fact]
    public async Task RetryLimitIsEnforced()
    {
        var handler = new RecordingHttpMessageHandler(
            _ => new HttpResponseMessage(
                HttpStatusCode.ServiceUnavailable));

        var client = CreateClient(
            handler,
            maximumRetryAttempts: 1);

        var exception =
            await Assert.ThrowsAsync<GraphServiceException>(
                () => client.GetAsync<TestGraphItem>(
                    "users/employee-001",
                    CreateContext()));

        Assert.Equal(503, exception.StatusCode);
        Assert.True(exception.IsTransient);
        Assert.Equal(2, handler.Requests.Count);
    }

    [Fact]
    public async Task BlankPathIsRejected()
    {
        var handler = new RecordingHttpMessageHandler(
            _ => throw new InvalidOperationException(
                "HTTP should not be called."));

        var client = CreateClient(handler);

        await Assert.ThrowsAsync<ArgumentException>(
            () => client.GetAsync<TestGraphItem>(
                " ",
                CreateContext()));

        Assert.Empty(handler.Requests);
    }

    private static PortalGraphClient CreateClient(
        RecordingHttpMessageHandler handler,
        int maximumRetryAttempts = 0)
    {
        var httpClient =
            new HttpClient(handler);

        var factory =
            new TestHttpClientFactory(httpClient);

        var tokenProvider =
            new TestGraphAccessTokenProvider();

        var options =
            Options.Create(
                new GraphOptions
                {
                    BaseUrl =
                        "https://graph.microsoft.com/v1.0",
                    Scopes =
                    [
                        "User.Read"
                    ],
                    MaximumRetryAttempts =
                        maximumRetryAttempts,
                    RequestTimeoutSeconds = 30
                });

        return new PortalGraphClient(
            factory,
            tokenProvider,
            options,
            NullLogger<PortalGraphClient>.Instance);
    }

    private static GraphRequestContext CreateContext(
        string correlationId = "portal-test-001")
    {
        return new GraphRequestContext(
            correlationId,
            "synthetic-user",
            CancellationToken.None);
    }

    private static HttpResponseMessage JsonResponse(
        HttpStatusCode statusCode,
        string json)
    {
        return new HttpResponseMessage(statusCode)
        {
            Content = new StringContent(
                json,
                Encoding.UTF8,
                "application/json")
        };
    }

    private sealed record TestGraphItem(
        string Id,
        string DisplayName);

    private sealed class TestGraphAccessTokenProvider
        : IGraphAccessTokenProvider
    {
        public Task<string> GetAccessTokenAsync(
            IReadOnlyCollection<string> scopes,
            CancellationToken cancellationToken)
        {
            cancellationToken.ThrowIfCancellationRequested();

            return Task.FromResult(
                "synthetic-access-token");
        }
    }

    private sealed class TestHttpClientFactory
        : IHttpClientFactory
    {
        private readonly HttpClient _client;

        public TestHttpClientFactory(
            HttpClient client)
        {
            _client = client;
        }

        public HttpClient CreateClient(string name)
        {
            return _client;
        }
    }

    private sealed class RecordingHttpMessageHandler
        : HttpMessageHandler
    {
        private readonly Func<
            HttpRequestMessage,
            HttpResponseMessage> _responseFactory;

        public RecordingHttpMessageHandler(
            Func<
                HttpRequestMessage,
                HttpResponseMessage> responseFactory)
        {
            _responseFactory = responseFactory;
        }

        public List<RecordedRequest> Requests { get; } =
            [];

        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            cancellationToken.ThrowIfCancellationRequested();

            Requests.Add(
                new RecordedRequest(
                    request.RequestUri?.ToString(),
                    request.Headers.Authorization?.Scheme,
                    request.Headers.Authorization?.Parameter,
                    GetHeader(
                        request,
                        "client-request-id"),
                    GetHeader(
                        request,
                        "return-client-request-id")));

            return Task.FromResult(
                _responseFactory(request));
        }

        private static string? GetHeader(
            HttpRequestMessage request,
            string name)
        {
            return request.Headers.TryGetValues(
                name,
                out var values)
                ? values.SingleOrDefault()
                : null;
        }
    }

    private sealed record RecordedRequest(
        string? Uri,
        string? AuthorizationScheme,
        string? AuthorizationParameter,
        string? correlationId,
        string? ReturnCorrelationId);
}