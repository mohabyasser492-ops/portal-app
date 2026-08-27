using System.Text.Json;
using System.Text.Json.Serialization;

namespace PortalApp.Infrastructure.SharePoint.Mapping;

public sealed class SharePointListItem
{
    [JsonPropertyName("id")]
    public string Id { get; init; } = string.Empty;

    [JsonPropertyName("eTag")]
    public string? ETag { get; init; }

    [JsonPropertyName("createdDateTime")]
    public DateTimeOffset? CreatedDateTime { get; init; }

    [JsonPropertyName("lastModifiedDateTime")]
    public DateTimeOffset? LastModifiedDateTime { get; init; }

    [JsonPropertyName("fields")]
    public Dictionary<string, JsonElement> Fields { get; init; } =
        new(StringComparer.OrdinalIgnoreCase);
}