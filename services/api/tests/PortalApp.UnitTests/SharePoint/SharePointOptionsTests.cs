using PortalApp.Infrastructure.SharePoint;
using Xunit;

namespace PortalApp.UnitTests.SharePoint;

public sealed class SharePointOptionsTests
{
    [Fact]
    public void ValidConfigurationIsAccepted()
    {
        var options = new SharePointOptions
        {
            Hostname =
                "example.sharepoint.com",
            SitePath =
                "/sites/EmployeePortal"
        };

        Assert.True(options.IsConfigured);
    }

    [Fact]
    public void EmptyHostnameIsRejected()
    {
        var options = new SharePointOptions
        {
            Hostname = string.Empty,
            SitePath =
                "/sites/EmployeePortal"
        };

        Assert.False(options.IsConfigured);
    }

    [Fact]
    public void NonSharePointHostnameIsRejected()
    {
        var options = new SharePointOptions
        {
            Hostname = "example.test",
            SitePath =
                "/sites/EmployeePortal"
        };

        Assert.False(options.IsConfigured);
    }

    [Fact]
    public void InvalidSitePathIsRejected()
    {
        var options = new SharePointOptions
        {
            Hostname =
                "example.sharepoint.com",
            SitePath =
                "/teams/EmployeePortal"
        };

        Assert.False(options.IsConfigured);
    }

    [Fact]
    public void SiteLookupPathIsGenerated()
    {
        var options = new SharePointOptions
        {
            Hostname =
                "example.sharepoint.com",
            SitePath =
                "/sites/EmployeePortal"
        };

        Assert.Equal(
            "/sites/example.sharepoint.com:/sites/EmployeePortal",
            options.SiteLookupPath);
    }
}