using PortalApp.Infrastructure.SharePoint;
using Xunit;

namespace PortalApp.UnitTests.SharePoint;

public sealed class SharePointGraphPathsTests
{
    [Fact]
    public void BuildsListItemsPathWithSelectedFields()
    {
        var path = SharePointGraphPaths.ListItems(
            "site-id",
            "list-id",
            [
                "LeaveType",
                "EmployeeId"
            ]);

        Assert.Equal(
            "/sites/site-id/lists/list-id/items" +
            "?$expand=fields($select=EmployeeId,LeaveType)" +
            "&$select=id,eTag,createdDateTime,lastModifiedDateTime",
            path);
    }

    [Fact]
    public void RemovesDuplicateFields()
    {
        var path = SharePointGraphPaths.ListItems(
            "site-id",
            "list-id",
            [
                "EmployeeId",
                "EmployeeId"
            ]);

        Assert.Contains(
            "$select=EmployeeId)",
            path);
    }

    [Fact]
    public void RejectsBlankSiteIdentifier()
    {
        Assert.Throws<ArgumentException>(
            () => SharePointGraphPaths.ListItems(
                string.Empty,
                "list-id",
                ["EmployeeId"]));
    }

    [Fact]
    public void RejectsUnsupportedFieldCharacters()
    {
        Assert.Throws<ArgumentException>(
            () => SharePointGraphPaths.ListItems(
                "site-id",
                "list-id",
                ["Employee Id"]));
    }

    [Fact]
    public void AcceptsMicrosoftGraphContinuationLink()
    {
        const string nextLink =
            "https://graph.microsoft.com/v1.0/sites/site-id/lists/list-id/items?$skiptoken=value";

        Assert.Equal(
            nextLink,
            SharePointGraphPaths.NextPage(
                nextLink));
    }

    [Fact]
    public void RejectsExternalContinuationHost()
    {
        Assert.Throws<ArgumentException>(
            () => SharePointGraphPaths.NextPage(
                "https://example.test/items?page=2"));
    }
}