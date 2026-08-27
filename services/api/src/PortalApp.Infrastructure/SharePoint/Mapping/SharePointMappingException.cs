namespace PortalApp.Infrastructure.SharePoint.Mapping;

public sealed class SharePointMappingException : Exception
{
    public SharePointMappingException(
        string itemId,
        string fieldName,
        string message,
        Exception? innerException = null)
        : base(message, innerException)
    {
        ItemId = itemId;
        FieldName = fieldName;
    }

    public string ItemId { get; }

    public string FieldName { get; }
}