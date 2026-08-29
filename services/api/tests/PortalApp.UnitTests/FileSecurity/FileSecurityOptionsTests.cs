using PortalApp.Api.FileSecurity;
using Xunit;

namespace PortalApp.UnitTests.FileSecurity;

public sealed class FileSecurityOptionsTests
{
    [Fact]
    public void AcceptsSecureDefaults()
    {
        Assert.True(new FileSecurityOptions().IsValid);
    }

    [Fact]
    public void RejectsZeroSizeLimit()
    {
        Assert.False(new FileSecurityOptions { MaximumSizeBytes = 0 }.IsValid);
    }

    [Fact]
    public void RejectsEmptyAllowlists()
    {
        Assert.False(new FileSecurityOptions { AllowedExtensions = [] }.IsValid);
        Assert.False(new FileSecurityOptions { AllowedContentTypes = [] }.IsValid);
    }
}