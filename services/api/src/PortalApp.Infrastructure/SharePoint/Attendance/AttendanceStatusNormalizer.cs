namespace PortalApp.Infrastructure.SharePoint.Attendance;

public static class AttendanceStatusNormalizer
{
    public static AttendanceStatus Normalize(
        string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return AttendanceStatus.Unknown;
        }

        var normalized =
            value.Trim()
                .Replace(
                    "-",
                    string.Empty,
                    StringComparison.Ordinal)
                .Replace(
                    "_",
                    string.Empty,
                    StringComparison.Ordinal)
                .Replace(
                    " ",
                    string.Empty,
                    StringComparison.Ordinal)
                .ToUpperInvariant();

        return normalized switch
        {
            "PRESENT" =>
                AttendanceStatus.Present,

            "ABSENT" =>
                AttendanceStatus.Absent,

            "LATE" or "LATEARRIVAL" =>
                AttendanceStatus.Late,

            "REMOTE" or "WORKFROMHOME" or "WFH" =>
                AttendanceStatus.Remote,

            "LEAVE" or "ONLEAVE" =>
                AttendanceStatus.Leave,

            "HOLIDAY" or "PUBLICHOLIDAY" =>
                AttendanceStatus.Holiday,

            _ =>
                AttendanceStatus.Unknown
        };
    }
}