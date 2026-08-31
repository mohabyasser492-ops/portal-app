using PortalApp.Api.Cancellation;
using PortalApp.Api.Configuration;
using PortalApp.Api.Errors;
using PortalApp.Api.FileSecurity;
using PortalApp.Api.Idempotency;
using PortalApp.Api.Middleware;
using PortalApp.Api.Notifications;
using PortalApp.Api.Observability;
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddPortalApiSecurity(
    builder.Configuration);

builder.Services.AddPortalGraph(
    builder.Configuration);

builder.Services.AddPortalSharePoint(
    builder.Configuration);


builder.Services.AddPortalRateLimiting();
builder.Services.AddPortalRequestCancellation(
    builder.Configuration);
builder.Services.AddPortalFileSecurity(
    builder.Configuration);
builder.Services.AddPortalPushNotifications(
    builder.Configuration);
builder.Services.AddPortalIdempotency(
    builder.Configuration);
builder.Services.AddPortalObservability(
    builder.Configuration);

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
app.UsePortalObservability();
app.UsePortalRequestCancellation();
app.UseExceptionHandler();
app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();
app.UsePortalIdempotency();

app.UseRateLimiter();

app.MapControllers()
    .RequireRateLimiting(
        RateLimitingExtensions.AuthenticatedPolicy);

app.MapHealthChecks("/health")
    .AllowAnonymous();
app.MapPortalHealthChecks();

app.Run();

public partial class Program;