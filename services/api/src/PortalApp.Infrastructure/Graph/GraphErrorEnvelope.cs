using System.Text.Json.Serialization;

namespace PortalApp.Infrastructure.Graph;

internal sealed class GraphErrorEnvelope
{
    [JsonPropertyName("error")]
    public GraphErrorBody? Error { get; init; }
}

internal sealed class GraphErrorBody
{
    [JsonPropertyName("code")]
    public string? Code { get; init; }

    [JsonPropertyName("message")]
    public string? Message { get; init; }
}