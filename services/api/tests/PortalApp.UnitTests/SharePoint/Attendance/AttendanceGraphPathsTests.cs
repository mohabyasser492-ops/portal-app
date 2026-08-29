using PortalApp.Infrastructure.SharePoint.Attendance;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Attendance;

public sealed class AttendanceGraphPathsTests
{
    [Fact]
    public void BuildsSitePath()
    {
        var result =
            AttendanceGraphPaths.SiteByPath(
                "example.sharepoint.com",
                "/sites/EmployeePortal");

        Assert.Equal(
            "/sites/example.sharepoint.com:/sites/EmployeePortal",
            result);
    }

    [Fact]
    public void BuildsEmployeeFilter()
    {
        var result =
            AttendanceGraphPaths.ItemsForEmployee(
                "site-id",
                "list-id",
                "employee-001");

        Assert.Contains(
            "/sites/site-id/lists/list-id/items",
            result);

        Assert.Contains(
            "$expand=fields",
            result);

        Assert.Contains(
            "EmployeeId eq 'employee-001'",
            result);
    }

    [Fact]
    public void EscapesEmployeeApostrophe()
    {
        var result =
            AttendanceGraphPaths.ItemsForEmployee(
                "site-id",
                "list-id",
                "employee'001");

        Assert.Contains(
            "employee''001",
            result);
    }

    [Theory]
    [InlineData("")]
    [InlineData("../site")]
    [InlineData("folder/site")]
    [InlineData("folder\\site")]
    public void RejectsUnsafeSiteIdentifier(
        string siteId)
    {
        Assert.Throws<ArgumentException>(
            () =>
                AttendanceGraphPaths
                    .ItemsForEmployee(
                        siteId,
                        "list-id",
                        "employee-001"));
    }

    [Fact]
    public void RejectsBlankEmployeeIdentifier()
    {
        Assert.Throws<ArgumentException>(
            () =>
                AttendanceGraphPaths
                    .ItemsForEmployee(
                        "site-id",
                        "list-id",
                        string.Empty));
    }
}