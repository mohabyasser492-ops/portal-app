namespace PortalApp.Api.Cancellation;

public static class RequestCancellationExtensions
{
    public static IServiceCollection AddPortalRequestCancellation(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        services
            .AddOptions<RequestCancellationOptions>()
            .Bind(configuration.GetSection(RequestCancellationOptions.SectionName))
            .Validate(
                options => options.IsValid,
                $"Request cancellation timeout must be between 1 and {RequestCancellationOptions.MaximumTimeoutSeconds} seconds.")
            .ValidateOnStart();

        return services;
    }

    public static IApplicationBuilder UsePortalRequestCancellation(
        this IApplicationBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);
        return app.UseMiddleware<RequestCancellationMiddleware>();
    }
}