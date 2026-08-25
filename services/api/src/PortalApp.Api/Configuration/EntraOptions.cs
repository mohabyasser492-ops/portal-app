namespace PortalApp.Api.Configuration;

public sealed class EntraOptions
{
    public const string SectionName = "Entra";

    public string Instance { get; init; } =
        "https://login.microsoftonline.com/";

    public string TenantId { get; init; } = string.Empty;

    public string ClientId { get; init; } = string.Empty;

    public string Audience { get; init; } = string.Empty;

    public string RequiredScope { get; init; } =
        "access_as_user";

    public bool IsConfigured =>
        Uri.TryCreate(Instance, UriKind.Absolute, out _) &&
        !string.IsNullOrWhiteSpace(TenantId) &&
        !string.IsNullOrWhiteSpace(ClientId) &&
        !string.IsNullOrWhiteSpace(Audience) &&
        !string.IsNullOrWhiteSpace(RequiredScope);
}