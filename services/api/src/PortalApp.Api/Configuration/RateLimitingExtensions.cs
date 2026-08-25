using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;

namespace PortalApp.Api.Configuration;

public static class RateLimitingExtensions
{
    public const string AuthenticatedPolicy =
        "authenticated-api";

    public static IServiceCollection AddPortalRateLimiting(
        this IServiceCollection services)
    {
        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode =
                StatusCodes.Status429TooManyRequests;

            options.OnRejected = async (
                context,
                cancellationToken) =>
            {
                var response = context.HttpContext.Response;

                response.ContentType =
                    "application/problem+json";

                await response.WriteAsJsonAsync(
                    new
                    {
                        type =
                            "https://portal-app.example/errors/rate-limit",
                        title = "Too many requests",
                        status =
                            StatusCodes.Status429TooManyRequests,
                        detail =
                            "Too many requests were received. Try again later.",
                        instance =
                            context.HttpContext.Request.Path.Value,
                        traceId =
                            context.HttpContext.TraceIdentifier
                    },
                    cancellationToken:
                        cancellationToken);
            };

            options.AddPolicy(
                AuthenticatedPolicy,
                httpContext =>
                {
                    var partitionKey =
                        httpContext.User.FindFirst("oid")?.Value ??
                        httpContext.Connection.RemoteIpAddress?
                            .ToString() ??
                        "anonymous";

                    return RateLimitPartition.GetFixedWindowLimiter(
                        partitionKey,
                        _ => new FixedWindowRateLimiterOptions
                        {
                            PermitLimit = 100,
                            Window = TimeSpan.FromMinutes(1),
                            QueueLimit = 0,
                            QueueProcessingOrder =
                                QueueProcessingOrder.OldestFirst,
                            AutoReplenishment = true
                        });
                });
        });

        return services;
    }
}
