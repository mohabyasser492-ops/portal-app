using PortalApp.Api.Configuration;
using PortalApp.Api.Errors;
using PortalApp.Api.Middleware;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHealthChecks();

builder.Services.AddPortalApiSecurity(
    builder.Configuration);

builder.Services.AddPortalGraph(
    builder.Configuration);


builder.Services.AddPortalRateLimiting();

builder.Services.AddSingleton<PortalProblemDetailsCustomizer>();

builder.Services.AddProblemDetails(options =>
{
    options.CustomizeProblemDetails = context =>
    {
        var customizer = context.HttpContext
            .RequestServices
            .GetRequiredService<PortalProblemDetailsCustomizer>();

        customizer.Customize(context);
    };
});

var app = builder.Build();

app.UseCorrelationId();
app.UseExceptionHandler();
app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.UseRateLimiter();

app.MapControllers()
    .RequireRateLimiting(
        RateLimitingExtensions.AuthenticatedPolicy);

app.MapHealthChecks("/health")
    .AllowAnonymous();

app.Run();

public partial class Program;