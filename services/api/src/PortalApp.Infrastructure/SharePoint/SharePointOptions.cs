namespace PortalApp.Infrastructure.SharePoint;

public sealed class SharePointOptions
{
    public const string SectionName = "SharePoint";

    public string Hostname { get; init; } = string.Empty;

    public string SitePath { get; init; } = string.Empty;

    public string LeaveListId { get; init; } = string.Empty;

    public string AttendanceListId { get; init; } = string.Empty;

    public string PayrollDriveId { get; init; } = string.Empty;

    public bool IsConfigured =>
        IsValidHostname(Hostname) &&
        IsValidSitePath(SitePath);

    public string SiteLookupPath =>
        $"/sites/{Hostname}:{NormalizeSitePath(SitePath)}";

    private static bool IsValidHostname(
        string hostname)
    {
        if (string.IsNullOrWhiteSpace(hostname))
        {
            return false;
        }

        return Uri.CheckHostName(hostname) ==
               UriHostNameType.Dns &&
               hostname.EndsWith(
                   ".sharepoint.com",
                   StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsValidSitePath(
        string sitePath)
    {
        return !string.IsNullOrWhiteSpace(sitePath) &&
               sitePath.StartsWith(
                   "/sites/",
                   StringComparison.OrdinalIgnoreCase) &&
               !sitePath.Contains(
                   "..",
                   StringComparison.Ordinal);
    }

    private static string NormalizeSitePath(
        string sitePath)
    {
        return sitePath.StartsWith(
            "/",
            StringComparison.Ordinal)
            ? sitePath
            : "/" + sitePath;
    }
}