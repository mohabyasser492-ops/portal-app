using System.Text.Json;
using PortalApp.Infrastructure.SharePoint.Leave;
using PortalApp.Infrastructure.SharePoint.Mapping;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Leave;

public sealed class LeaveBalanceMapperTests
{
    private readonly LeaveBalanceMapper _mapper = new();

    [Fact]
    public void MapsCompleteLeaveBalance()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "LeaveType": "Annual",
              "EntitledDays": 30,
              "UsedDays": 8,
              "PendingDays": 2,
              "RemainingDays": 20,
              "BalanceYear": 2026,
              "LastUpdated": "2026-08-27T06:00:00Z"
            }
            """);

        var result = _mapper.Map(item);

        Assert.Equal(
            "item-001",
            result.SharePointItemId);

        Assert.Equal(
            "23101492",
            result.EmployeeId);

        Assert.Equal(
            "Annual",
            result.LeaveType);

        Assert.Equal(
            30m,
            result.EntitledDays);

        Assert.Equal(
            8m,
            result.UsedDays);

        Assert.Equal(
            2m,
            result.PendingDays);

        Assert.Equal(
            20m,
            result.RemainingDays);

        Assert.Equal(
            2026,
            result.BalanceYear);
    }

    [Fact]
    public void CalculatesRemainingDaysWhenMissing()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "LeaveType": "Annual",
              "EntitledDays": 30,
              "UsedDays": 8,
              "PendingDays": 2,
              "BalanceYear": 2026
            }
            """);

        var result = _mapper.Map(item);

        Assert.Equal(
            20m,
            result.RemainingDays);
    }

    [Fact]
    public void RemainingDaysCannotBecomeNegative()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "LeaveType": "Annual",
              "EntitledDays": 5,
              "UsedDays": 8,
              "PendingDays": 2,
              "BalanceYear": 2026
            }
            """);

        var result = _mapper.Map(item);

        Assert.Equal(
            0m,
            result.RemainingDays);
    }

    [Fact]
    public void RejectsNegativeValues()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "LeaveType": "Annual",
              "EntitledDays": -1,
              "BalanceYear": 2026
            }
            """);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            LeaveBalanceFields.EntitledDays,
            exception.FieldName);
    }

    [Fact]
    public void RejectsMissingEmployeeIdentifier()
    {
        var item = CreateItem(
            """
            {
              "LeaveType": "Annual",
              "EntitledDays": 30,
              "BalanceYear": 2026
            }
            """);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            LeaveBalanceFields.EmployeeId,
            exception.FieldName);
    }

    [Fact]
    public void UsesItemModificationDateAsFallback()
    {
        var modified =
            new DateTimeOffset(
                2026,
                8,
                27,
                7,
                0,
                0,
                TimeSpan.Zero);

        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "LeaveType": "Annual",
              "BalanceYear": 2026
            }
            """,
            modified);

        var result = _mapper.Map(item);

        Assert.Equal(
            modified,
            result.LastUpdated);
    }

    private static SharePointListItem CreateItem(
        string fieldsJson,
        DateTimeOffset? lastModified = null)
    {
        var fields =
            JsonSerializer.Deserialize<
                Dictionary<string, JsonElement>>(
                fieldsJson);

        return new SharePointListItem
        {
            Id = "item-001",
            ETag = "etag-001",
            LastModifiedDateTime =
                lastModified,
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