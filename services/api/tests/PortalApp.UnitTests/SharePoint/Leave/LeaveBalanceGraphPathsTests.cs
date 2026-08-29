using PortalApp.Infrastructure.SharePoint.Leave;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Leave;

public sealed class LeaveBalanceGraphPathsTests
{
    [Fact]
    public void BuildsSitePath()
    {
        var result =
            LeaveBalanceGraphPaths.SiteByPath(
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
            LeaveBalanceGraphPaths.ItemsForEmployee(
                "site-id",
                "list-id",
                "employee-001");

        Assert.Contains(
            "EmployeeId eq 'employee-001'",
            result);

        Assert.Contains(
            "$expand=fields",
            result);
    }

    [Fact]
    public void EscapesApostrophe()
    {
        var result =
            LeaveBalanceGraphPaths.ItemsForEmployee(
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
    public void RejectsUnsafeSiteId(
        string siteId)
    {
        Assert.Throws<ArgumentException>(
            () =>
                LeaveBalanceGraphPaths
                    .ItemsForEmployee(
                        siteId,
                        "list-id",
                        "employee-001"));
    }
}