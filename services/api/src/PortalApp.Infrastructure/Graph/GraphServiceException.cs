namespace PortalApp.Infrastructure.Graph;

public sealed class GraphServiceException : Exception
{
    public GraphServiceException(
        string message,
        int? statusCode = null,
        string? errorCode = null,
        TimeSpan? retryAfter = null,
        Exception? innerException = null)
        : base(message, innerException)
    {
        StatusCode = statusCode;
        ErrorCode = errorCode;
        RetryAfter = retryAfter;
    }

    public int? StatusCode { get; }

    public string? ErrorCode { get; }

    public TimeSpan? RetryAfter { get; }

    public bool IsThrottled =>
        StatusCode == 429;

    public bool IsTransient =>
        IsThrottled ||
        StatusCode is 408 or 500 or 502 or 503 or 504;
}