using System.Text.Json;
using PortalApp.Infrastructure.SharePoint.Mapping;
using Xunit;

namespace PortalApp.UnitTests.SharePoint;

public sealed class SharePointFieldReaderTests
{
    [Fact]
    public void ReadsRequiredString()
    {
        var item = CreateItem(
            """
            {
              "Title": "Annual Leave"
            }
            """);

        var reader =
            new SharePointFieldReader(item);

        Assert.Equal(
            "Annual Leave",
            reader.GetRequiredString("Title"));
    }

    [Fact]
    public void ReadsIntegerFromNumber()
    {
        var item = CreateItem(
            """
            {
              "Days": 12
            }
            """);

        var reader =
            new SharePointFieldReader(item);

        Assert.Equal(
            12,
            reader.GetOptionalInt32("Days"));
    }

    [Fact]
    public void ReadsIntegerFromString()
    {
        var item = CreateItem(
            """
            {
              "Days": "9"
            }
            """);

        var reader =
            new SharePointFieldReader(item);

        Assert.Equal(
            9,
            reader.GetOptionalInt32("Days"));
    }

    [Fact]
    public void ReadsDecimalUsingInvariantFormat()
    {
        var item = CreateItem(
            """
            {
              "Balance": "18.5"
            }
            """);

        var reader =
            new SharePointFieldReader(item);

        Assert.Equal(
            18.5m,
            reader.GetOptionalDecimal("Balance"));
    }

    [Fact]
    public void ReadsUtcDate()
    {
        var item = CreateItem(
            """
            {
              "StartDate": "2026-08-27T06:00:00Z"
            }
            """);

        var reader =
            new SharePointFieldReader(item);

        var result =
            reader.GetOptionalDateTimeOffset(
                "StartDate");

        Assert.NotNull(result);
        Assert.Equal(
            TimeSpan.Zero,
            result.Value.Offset);
    }

    [Fact]
    public void ReturnsNullForMissingOptionalField()
    {
        var item = CreateItem("{}");

        var reader =
            new SharePointFieldReader(item);

        Assert.Null(
            reader.GetOptionalString("Title"));
    }

    [Fact]
    public void ThrowsForMissingRequiredField()
    {
        var item = CreateItem("{}");

        var reader =
            new SharePointFieldReader(item);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () =>
                    reader.GetRequiredString(
                        "Title"));

        Assert.Equal(
            "item-001",
            exception.ItemId);

        Assert.Equal(
            "Title",
            exception.FieldName);
    }

    [Fact]
    public void FieldLookupIsCaseInsensitive()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492"
            }
            """);

        var reader =
            new SharePointFieldReader(item);

        Assert.Equal(
            "23101492",
            reader.GetRequiredString(
                "employeeid"));
    }

    private static SharePointListItem CreateItem(
        string fieldsJson)
    {
        var fields =
            JsonSerializer.Deserialize<
                Dictionary<string, JsonElement>>(
                fieldsJson);

        return new SharePointListItem
        {
            Id = "item-001",
            Fields = new Dictionary<
                string,
                JsonElement>(
                fields ??
                new Dictionary<
                    string,
                    JsonElement>(),
                StringComparer.OrdinalIgnoreCase)
        };
    }
}