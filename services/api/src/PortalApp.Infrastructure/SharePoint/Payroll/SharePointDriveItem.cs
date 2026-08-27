using System.Text.Json.Serialization;

namespace PortalApp.Infrastructure.SharePoint.Payroll;

public sealed class SharePointDriveItem
{
    [JsonPropertyName("id")]
    public string Id { get; init; } = string.Empty;

    [JsonPropertyName("name")]
    public string Name { get; init; } = string.Empty;

    [JsonPropertyName("eTag")]
    public string? ETag { get; init; }

    [JsonPropertyName("size")]
    public long? Size { get; init; }

    [JsonPropertyName("createdDateTime")]
    public DateTimeOffset? CreatedDateTime { get; init; }

    [JsonPropertyName("lastModifiedDateTime")]
    public DateTimeOffset? LastModifiedDateTime { get; init; }

    [JsonPropertyName("webUrl")]
    public string? WebUrl { get; init; }

    [JsonPropertyName("file")]
    public SharePointFileFacet? File { get; init; }

    [JsonPropertyName("folder")]
    public SharePointFolderFacet? Folder { get; init; }
}

public sealed class SharePointFileFacet
{
    [JsonPropertyName("mimeType")]
    public string? MimeType { get; init; }

    [JsonPropertyName("hashes")]
    public SharePointFileHashes? Hashes { get; init; }
}

public sealed class SharePointFileHashes
{
    [JsonPropertyName("sha1Hash")]
    public string? Sha1Hash { get; init; }

    [JsonPropertyName("quickXorHash")]
    public string? QuickXorHash { get; init; }
}

public sealed class SharePointFolderFacet
{
    [JsonPropertyName("childCount")]
    public int? ChildCount { get; init; }
}