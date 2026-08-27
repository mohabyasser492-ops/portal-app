using System.Globalization;
using PortalApp.Infrastructure.SharePoint.Mapping;

namespace PortalApp.Infrastructure.SharePoint.Attendance;

public sealed class AttendanceMapper
{
    public AttendanceRecord Map(
        SharePointListItem item)
    {
        ArgumentNullException.ThrowIfNull(item);

        if (string.IsNullOrWhiteSpace(item.Id))
        {
            throw new SharePointMappingException(
                string.Empty,
                "id",
                "The SharePoint list item identifier is missing.");
        }

        var fields =
            new SharePointFieldReader(item);

        var attendanceDate =
            ParseAttendanceDate(
                item.Id,
                fields.GetRequiredString(
                    AttendanceFields.AttendanceDate));

        var checkIn =
            fields.GetOptionalDateTimeOffset(
                AttendanceFields.CheckIn);

        var checkOut =
            fields.GetOptionalDateTimeOffset(
                AttendanceFields.CheckOut);

        if (checkIn is not null &&
            checkOut is not null &&
            checkOut < checkIn)
        {
            throw new SharePointMappingException(
                item.Id,
                AttendanceFields.CheckOut,
                "The attendance check-out time cannot be earlier than check-in.");
        }

        var explicitWorkedMinutes =
            fields.GetOptionalInt32(
                AttendanceFields.WorkedMinutes);

        if (explicitWorkedMinutes is < 0)
        {
            throw new SharePointMappingException(
                item.Id,
                AttendanceFields.WorkedMinutes,
                "Worked minutes cannot be negative.");
        }

        var calculatedWorkedMinutes =
            CalculateWorkedMinutes(
                checkIn,
                checkOut);

        var workedMinutes =
            explicitWorkedMinutes ??
            calculatedWorkedMinutes;

        return new AttendanceRecord(
            SharePointItemId: item.Id,
            ETag: item.ETag,
            EmployeeId:
                fields.GetRequiredString(
                    AttendanceFields.EmployeeId),
            AttendanceDate:
                attendanceDate,
            CheckIn:
                checkIn,
            CheckOut:
                checkOut,
            Status:
                AttendanceStatusNormalizer.Normalize(
                    fields.GetOptionalString(
                        AttendanceFields.Status)),
            WorkedMinutes:
                workedMinutes,
            Notes:
                fields.GetOptionalString(
                    AttendanceFields.Notes),
            LastUpdated:
                fields.GetOptionalDateTimeOffset(
                    AttendanceFields.LastUpdated) ??
                item.LastModifiedDateTime);
    }

    private static DateOnly ParseAttendanceDate(
        string itemId,
        string value)
    {
        if (DateOnly.TryParse(
                value,
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out var date))
        {
            return date;
        }

        if (DateTimeOffset.TryParse(
                value,
                CultureInfo.InvariantCulture,
                DateTimeStyles.AssumeUniversal,
                out var dateTime))
        {
            return DateOnly.FromDateTime(
                dateTime.UtcDateTime);
        }

        throw new SharePointMappingException(
            itemId,
            AttendanceFields.AttendanceDate,
            "The attendance date is invalid.");
    }

    private static int? CalculateWorkedMinutes(
        DateTimeOffset? checkIn,
        DateTimeOffset? checkOut)
    {
        if (checkIn is null ||
            checkOut is null)
        {
            return null;
        }

        var minutes =
            Convert.ToInt32(
                Math.Floor(
                    (checkOut.Value -
                     checkIn.Value)
                    .TotalMinutes));

        return minutes;
    }
}