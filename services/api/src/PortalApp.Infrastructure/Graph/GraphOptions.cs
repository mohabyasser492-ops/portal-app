namespace PortalApp.Infrastructure.Graph;

public sealed class GraphOptions
{
    public const string SectionName = "MicrosoftGraph";

    public string BaseUrl { get; init; } =
        "https://graph.microsoft.com/v1.0";

    public string[] Scopes { get; init; } =
        Array.Empty<string>();

    public int MaximumRetryAttempts { get; init; } = 3;

    public int RequestTimeoutSeconds { get; init; } = 30;

    public bool IsConfigured =>
        Uri.TryCreate(
            BaseUrl,
            UriKind.Absolute,
            out var baseUri) &&
        baseUri.Scheme == Uri.UriSchemeHttps &&
        Scopes.Length > 0 &&
        Scopes.All(
            scope =>
                !string.IsNullOrWhiteSpace(scope)) &&
        MaximumRetryAttempts is >= 0 and <= 5 &&
        RequestTimeoutSeconds is >= 5 and <= 120;
}