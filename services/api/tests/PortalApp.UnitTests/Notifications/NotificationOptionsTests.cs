using PortalApp.Api.Notifications;
using Xunit;

namespace PortalApp.UnitTests.Notifications;

public sealed class NotificationOptionsTests
{
    [Fact]
    public void AcceptsSecureDefaults() => Assert.True(new NotificationOptions().IsValid);

    [Theory]
    [InlineData(0, 4096)]
    [InlineData(26, 4096)]
    [InlineData(10, 31)]
    [InlineData(10, 8193)]
    public void RejectsUnsafeLimits(int devices, int tokenLength)
    {
        Assert.False(new NotificationOptions
        {
            MaximumDevicesPerUser = devices,
            MaximumTokenLength = tokenLength
        }.IsValid);
    }
}