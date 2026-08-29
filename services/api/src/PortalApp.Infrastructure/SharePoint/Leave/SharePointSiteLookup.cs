using System.Text.Json.Serialization;

namespace PortalApp.Infrastructure.SharePoint.Leave;

public sealed class SharePointSiteLookup
{
    [JsonPropertyName("id")]
    public string Id { get; init; } =
        string.Empty;

    [JsonPropertyName("displayName")]
    public string? DisplayName { get; init; }

    [JsonPropertyName("webUrl")]
    public string? WebUrl { get; init; }
}