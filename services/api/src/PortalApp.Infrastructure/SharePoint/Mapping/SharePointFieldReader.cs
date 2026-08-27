using System.Globalization;
using System.Text.Json;

namespace PortalApp.Infrastructure.SharePoint.Mapping;

public sealed class SharePointFieldReader
{
    private readonly SharePointListItem _item;

    public SharePointFieldReader(
        SharePointListItem item)
    {
        ArgumentNullException.ThrowIfNull(item);
        _item = item;
    }

    public string? GetOptionalString(
        string fieldName)
    {
        if (!TryGetField(
                fieldName,
                out var value) ||
            value.ValueKind is
                JsonValueKind.Null or
                JsonValueKind.Undefined)
        {
            return null;
        }

        if (value.ValueKind != JsonValueKind.String)
        {
            throw CreateException(
                fieldName,
                "The SharePoint field must contain a string.");
        }

        var text = value.GetString()?.Trim();

        return string.IsNullOrWhiteSpace(text)
            ? null
            : text;
    }

    public string GetRequiredString(
        string fieldName)
    {
        return GetOptionalString(fieldName) ??
               throw CreateException(
                   fieldName,
                   "The required SharePoint field is missing or blank.");
    }

    public int? GetOptionalInt32(
        string fieldName)
    {
        if (!TryGetField(
                fieldName,
                out var value) ||
            value.ValueKind is
                JsonValueKind.Null or
                JsonValueKind.Undefined)
        {
            return null;
        }

        if (value.ValueKind == JsonValueKind.Number &&
            value.TryGetInt32(out var number))
        {
            return number;
        }

        if (value.ValueKind == JsonValueKind.String &&
            int.TryParse(
                value.GetString(),
                NumberStyles.Integer,
                CultureInfo.InvariantCulture,
                out number))
        {
            return number;
        }

        throw CreateException(
            fieldName,
            "The SharePoint field must contain a valid integer.");
    }

    public decimal? GetOptionalDecimal(
        string fieldName)
    {
        if (!TryGetField(
                fieldName,
                out var value) ||
            value.ValueKind is
                JsonValueKind.Null or
                JsonValueKind.Undefined)
        {
            return null;
        }

        if (value.ValueKind == JsonValueKind.Number &&
            value.TryGetDecimal(out var number))
        {
            return number;
        }

        if (value.ValueKind == JsonValueKind.String &&
            decimal.TryParse(
                value.GetString(),
                NumberStyles.Number,
                CultureInfo.InvariantCulture,
                out number))
        {
            return number;
        }

        throw CreateException(
            fieldName,
            "The SharePoint field must contain a valid decimal value.");
    }

    public bool? GetOptionalBoolean(
        string fieldName)
    {
        if (!TryGetField(
                fieldName,
                out var value) ||
            value.ValueKind is
                JsonValueKind.Null or
                JsonValueKind.Undefined)
        {
            return null;
        }

        if (value.ValueKind is
            JsonValueKind.True or
            JsonValueKind.False)
        {
            return value.GetBoolean();
        }

        if (value.ValueKind == JsonValueKind.String &&
            bool.TryParse(
                value.GetString(),
                out var result))
        {
            return result;
        }

        throw CreateException(
            fieldName,
            "The SharePoint field must contain a valid Boolean value.");
    }

    public DateTimeOffset? GetOptionalDateTimeOffset(
        string fieldName)
    {
        var value = GetOptionalString(fieldName);

        if (value is null)
        {
            return null;
        }

        if (DateTimeOffset.TryParse(
                value,
                CultureInfo.InvariantCulture,
                DateTimeStyles.AssumeUniversal |
                DateTimeStyles.AdjustToUniversal,
                out var dateTime))
        {
            return dateTime;
        }

        throw CreateException(
            fieldName,
            "The SharePoint field must contain a valid date and time.");
    }

    private bool TryGetField(
        string fieldName,
        out JsonElement value)
    {
        if (string.IsNullOrWhiteSpace(fieldName))
        {
            throw new ArgumentException(
                "A SharePoint field name is required.",
                nameof(fieldName));
        }

        return _item.Fields.TryGetValue(
            fieldName,
            out value);
    }

    private SharePointMappingException CreateException(
        string fieldName,
        string message)
    {
        return new SharePointMappingException(
            _item.Id,
            fieldName,
            message);
    }
}