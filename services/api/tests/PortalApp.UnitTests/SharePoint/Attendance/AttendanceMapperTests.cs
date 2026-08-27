using System.Text.Json;
using PortalApp.Infrastructure.SharePoint.Attendance;
using PortalApp.Infrastructure.SharePoint.Mapping;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Attendance;

public sealed class AttendanceMapperTests
{
    private readonly AttendanceMapper _mapper = new();

    [Fact]
    public void MapsCompleteAttendanceRecord()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "AttendanceDate": "2026-08-27",
              "CheckIn": "2026-08-27T06:00:00Z",
              "CheckOut": "2026-08-27T14:30:00Z",
              "Status": "Present",
              "WorkedMinutes": 510,
              "Notes": "Synthetic attendance record",
              "LastUpdated": "2026-08-27T14:45:00Z"
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
            new DateOnly(
                2026,
                8,
                27),
            result.AttendanceDate);

        Assert.Equal(
            AttendanceStatus.Present,
            result.Status);

        Assert.Equal(
            510,
            result.WorkedMinutes);

        Assert.Equal(
            TimeSpan.FromMinutes(510),
            result.WorkedDuration);
    }

    [Fact]
    public void CalculatesWorkedMinutesWhenMissing()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "AttendanceDate": "2026-08-27",
              "CheckIn": "2026-08-27T06:15:00Z",
              "CheckOut": "2026-08-27T14:45:00Z",
              "Status": "Present"
            }
            """);

        var result = _mapper.Map(item);

        Assert.Equal(
            510,
            result.WorkedMinutes);
    }

    [Fact]
    public void ReturnsNullDurationWhenCheckOutIsMissing()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "AttendanceDate": "2026-08-27",
              "CheckIn": "2026-08-27T06:15:00Z",
              "Status": "Present"
            }
            """);

        var result = _mapper.Map(item);

        Assert.Null(
            result.WorkedMinutes);

        Assert.Null(
            result.WorkedDuration);
    }

    [Fact]
    public void RejectsCheckOutBeforeCheckIn()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "AttendanceDate": "2026-08-27",
              "CheckIn": "2026-08-27T14:00:00Z",
              "CheckOut": "2026-08-27T06:00:00Z"
            }
            """);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            AttendanceFields.CheckOut,
            exception.FieldName);
    }

    [Fact]
    public void RejectsNegativeWorkedMinutes()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "AttendanceDate": "2026-08-27",
              "WorkedMinutes": -1
            }
            """);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            AttendanceFields.WorkedMinutes,
            exception.FieldName);
    }

    [Fact]
    public void RejectsMissingEmployeeIdentifier()
    {
        var item = CreateItem(
            """
            {
              "AttendanceDate": "2026-08-27",
              "Status": "Present"
            }
            """);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            AttendanceFields.EmployeeId,
            exception.FieldName);
    }

    [Fact]
    public void RejectsInvalidAttendanceDate()
    {
        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "AttendanceDate": "not-a-date",
              "Status": "Present"
            }
            """);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            AttendanceFields.AttendanceDate,
            exception.FieldName);
    }

    [Fact]
    public void UsesModificationDateAsFallback()
    {
        var modified =
            new DateTimeOffset(
                2026,
                8,
                27,
                15,
                0,
                0,
                TimeSpan.Zero);

        var item = CreateItem(
            """
            {
              "EmployeeId": "23101492",
              "AttendanceDate": "2026-08-27",
              "Status": "Present"
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