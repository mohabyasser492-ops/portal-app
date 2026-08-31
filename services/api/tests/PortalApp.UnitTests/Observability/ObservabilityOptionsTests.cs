using PortalApp.Api.Observability;
using Xunit;

namespace PortalApp.UnitTests.Observability;

public sealed class ObservabilityOptionsTests
{
    [Theory]
    [InlineData(100)]
    [InlineData(1000)]
    [InlineData(60000)]
    public void AcceptsSupportedThresholds(int threshold)
    {
        Assert.True(new ObservabilityOptions
        {
            SlowRequestThresholdMilliseconds = threshold
        }.IsValid);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(99)]
    [InlineData(60001)]
    public void RejectsUnsupportedThresholds(int threshold)
    {
        Assert.False(new ObservabilityOptions
        {
            SlowRequestThresholdMilliseconds = threshold
        }.IsValid);
    }
}