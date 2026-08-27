namespace PortalApp.Infrastructure.SharePoint.Payroll;

public static class PayrollDrivePaths
{
    public static string Children(
        string driveId,
        string folderItemId)
    {
        ValidateIdentifier(
            driveId,
            nameof(driveId));

        ValidateIdentifier(
            folderItemId,
            nameof(folderItemId));

        return
            $"/drives/{Uri.EscapeDataString(driveId)}" +
            $"/items/{Uri.EscapeDataString(folderItemId)}" +
            "/children" +
            "?$select=id,name,eTag,size,createdDateTime,lastModifiedDateTime,file,folder";
    }

    public static string Content(
        string driveId,
        string itemId)
    {
        ValidateIdentifier(
            driveId,
            nameof(driveId));

        ValidateIdentifier(
            itemId,
            nameof(itemId));

        return
            $"/drives/{Uri.EscapeDataString(driveId)}" +
            $"/items/{Uri.EscapeDataString(itemId)}" +
            "/content";
    }

    private static void ValidateIdentifier(
        string value,
        string parameterName)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException(
                "A drive identifier is required.",
                parameterName);
        }

        if (value.Contains(
                '/',
                StringComparison.Ordinal) ||
            value.Contains(
                '\\',
                StringComparison.Ordinal) ||
            value.Contains(
                "..",
                StringComparison.Ordinal))
        {
            throw new ArgumentException(
                "The drive identifier contains unsupported path characters.",
                parameterName);
        }
    }
}