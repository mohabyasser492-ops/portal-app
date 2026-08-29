using PortalApp.Api.Cancellation;
using Xunit;

namespace PortalApp.UnitTests.Cancellation;

public sealed class RequestCancellationOptionsTests
{
    [Theory]
    [InlineData(1)]
    [InlineData(30)]
    [InlineData(300)]
    public void AcceptsSupportedTimeout(int timeoutSeconds)
    {
        var options = new RequestCancellationOptions
        {
            TimeoutSeconds = timeoutSeconds
        };

        Assert.True(options.IsValid);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    [InlineData(301)]
    public void RejectsUnsupportedTimeout(int timeoutSeconds)
    {
        var options = new RequestCancellationOptions
        {
            TimeoutSeconds = timeoutSeconds
        };

        Assert.False(options.IsValid);
    }
}