namespace PortalApp.Api.Idempotency;

public static class IdempotencyExtensions
{
    public static IServiceCollection AddPortalIdempotency(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOptions<IdempotencyOptions>()
            .Bind(configuration.GetSection(IdempotencyOptions.SectionName))
            .Validate(options => options.IsValid, "The idempotency configuration is invalid.")
            .ValidateOnStart();
        services.AddSingleton<IIdempotencyStore, InMemoryIdempotencyStore>();
        return services;
    }

    public static IApplicationBuilder UsePortalIdempotency(this IApplicationBuilder app) =>
        app.UseMiddleware<IdempotencyMiddleware>();
}