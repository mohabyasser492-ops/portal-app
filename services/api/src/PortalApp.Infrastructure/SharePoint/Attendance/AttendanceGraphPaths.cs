namespace PortalApp.Infrastructure.SharePoint.Attendance;

public static class AttendanceGraphPaths
{
    public static string SiteByPath(
        string hostname,
        string sitePath)
    {
        if (string.IsNullOrWhiteSpace(hostname))
        {
            throw new ArgumentException(
                "A SharePoint hostname is required.",
                nameof(hostname));
        }

        if (string.IsNullOrWhiteSpace(sitePath))
        {
            throw new ArgumentException(
                "A SharePoint site path is required.",
                nameof(sitePath));
        }

        var normalizedHostname =
            hostname.Trim();

        var normalizedSitePath =
            sitePath.Trim();

        if (!normalizedSitePath.StartsWith(
                "/",
                StringComparison.Ordinal))
        {
            normalizedSitePath =
                "/" + normalizedSitePath;
        }

        return
            $"/sites/{normalizedHostname}:{normalizedSitePath}";
    }

    public static string ItemsForEmployee(
        string siteId,
        string listId,
        string employeeId)
    {
        ValidateIdentifier(
            siteId,
            nameof(siteId));

        ValidateIdentifier(
            listId,
            nameof(listId));

        if (string.IsNullOrWhiteSpace(employeeId))
        {
            throw new ArgumentException(
                "An employee identifier is required.",
                nameof(employeeId));
        }

        var selectedFields =
            string.Join(
                ",",
                AttendanceFields.All
                    .Distinct(
                        StringComparer.Ordinal)
                    .OrderBy(
                        field => field,
                        StringComparer.Ordinal));

        var escapedEmployeeId =
            employeeId
                .Trim()
                .Replace(
                    "'",
                    "''",
                    StringComparison.Ordinal);

        return
            $"/sites/{Uri.EscapeDataString(siteId)}" +
            $"/lists/{Uri.EscapeDataString(listId)}" +
            "/items" +
            $"?$expand=fields($select={selectedFields})" +
            "&$select=id,eTag,createdDateTime,lastModifiedDateTime" +
            $"&$filter=fields/{AttendanceFields.EmployeeId} eq '{escapedEmployeeId}'";
    }

    private static void ValidateIdentifier(
        string value,
        string parameterName)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException(
                "A SharePoint identifier is required.",
                parameterName);
        }

        if (value.Contains(
                "/",
                StringComparison.Ordinal) ||
            value.Contains(
                "\\",
                StringComparison.Ordinal) ||
            value.Contains(
                "..",
                StringComparison.Ordinal))
        {
            throw new ArgumentException(
                "The SharePoint identifier contains unsupported path characters.",
                parameterName);
        }
    }
}