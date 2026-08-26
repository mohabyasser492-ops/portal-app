using System.Text.Json.Serialization;

namespace PortalApp.Infrastructure.Graph;

internal sealed class GraphCollectionResponse<T>
{
    [JsonPropertyName("value")]
    public List<T> Value { get; init; } = [];

    [JsonPropertyName("@odata.nextLink")]
    public string? NextLink { get; init; }
}