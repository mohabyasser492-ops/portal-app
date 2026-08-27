namespace PortalApp.Infrastructure.SharePoint;

public static class SharePointGraphPaths
{
    public static string ListItems(
        string siteId,
        string listId,
        IReadOnlyCollection<string> fields)
    {
        ValidateIdentifier(siteId, nameof(siteId));
        ValidateIdentifier(listId, nameof(listId));

        if (fields.Count == 0)
        {
            throw new ArgumentException(
                "At least one SharePoint field is required.",
                nameof(fields));
        }

        var selectedFields = fields
            .Select(ValidateFieldName)
            .Distinct(StringComparer.Ordinal)
            .OrderBy(
                field => field,
                StringComparer.Ordinal);

        var fieldSelection =
            string.Join(",", selectedFields);

        return
            $"/sites/{Uri.EscapeDataString(siteId)}" +
            $"/lists/{Uri.EscapeDataString(listId)}" +
            "/items" +
            $"?$expand=fields($select={fieldSelection})" +
            "&$select=id,eTag,createdDateTime,lastModifiedDateTime";
    }

    public static string NextPage(
        string nextLink)
    {
        if (!Uri.TryCreate(
                nextLink,
                UriKind.Absolute,
                out var uri))
        {
            throw new ArgumentException(
                "A valid absolute continuation URL is required.",
                nameof(nextLink));
        }

        if (!string.Equals(
                uri.Scheme,
                Uri.UriSchemeHttps,
                StringComparison.OrdinalIgnoreCase) ||
            !string.Equals(
                uri.Host,
                "graph.microsoft.com",
                StringComparison.OrdinalIgnoreCase))
        {
            throw new ArgumentException(
                "The continuation URL must target Microsoft Graph.",
                nameof(nextLink));
        }

        return nextLink;
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
                '/',
                StringComparison.Ordinal))
        {
            throw new ArgumentException(
                "The SharePoint identifier cannot contain path separators.",
                parameterName);
        }
    }

    private static string ValidateFieldName(
        string fieldName)
    {
        if (string.IsNullOrWhiteSpace(fieldName))
        {
            throw new ArgumentException(
                "SharePoint field names cannot be blank.",
                nameof(fieldName));
        }

        if (!fieldName.All(character =>
                char.IsLetterOrDigit(character) ||
                character == '_'))
        {
            throw new ArgumentException(
                "A SharePoint field name contains unsupported characters.",
                nameof(fieldName));
        }

        return fieldName;
    }
}