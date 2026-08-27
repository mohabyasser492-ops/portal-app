using PortalApp.Infrastructure.SharePoint.Attendance;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Attendance;

public sealed class AttendanceStatusNormalizerTests
{
    [Theory]
    [InlineData("Present", AttendanceStatus.Present)]
    [InlineData("ABSENT", AttendanceStatus.Absent)]
    [InlineData("late arrival", AttendanceStatus.Late)]
    [InlineData("Work From Home", AttendanceStatus.Remote)]
    [InlineData("WFH", AttendanceStatus.Remote)]
    [InlineData("on-leave", AttendanceStatus.Leave)]
    [InlineData("Public Holiday", AttendanceStatus.Holiday)]
    public void NormalizesKnownStatus(
        string source,
        AttendanceStatus expected)
    {
        var result =
            AttendanceStatusNormalizer.Normalize(
                source);

        Assert.Equal(
            expected,
            result);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("unsupported")]
    public void ReturnsUnknownForUnsupportedStatus(
        string? source)
    {
        var result =
            AttendanceStatusNormalizer.Normalize(
                source);

        Assert.Equal(
            AttendanceStatus.Unknown,
            result);
    }
}