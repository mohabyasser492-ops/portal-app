using PortalApp.Infrastructure.SharePoint.Payroll;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Payroll;

public sealed class PayrollDrivePathsTests
{
    [Fact]
    public void BuildsChildrenPath()
    {
        var path =
            PayrollDrivePaths.Children(
                "drive-id",
                "folder-id");

        Assert.Equal(
            "/drives/drive-id/items/folder-id/children" +
            "?$select=id,name,eTag,size,createdDateTime,lastModifiedDateTime,file,folder",
            path);
    }

    [Fact]
    public void BuildsContentPath()
    {
        var path =
            PayrollDrivePaths.Content(
                "drive-id",
                "item-id");

        Assert.Equal(
            "/drives/drive-id/items/item-id/content",
            path);
    }

    [Theory]
    [InlineData("")]
    [InlineData("../item")]
    [InlineData("folder/item")]
    [InlineData("folder\\item")]
    public void RejectsUnsafeItemIdentifier(
        string itemId)
    {
        Assert.Throws<ArgumentException>(
            () =>
                PayrollDrivePaths.Content(
                    "drive-id",
                    itemId));
    }
}