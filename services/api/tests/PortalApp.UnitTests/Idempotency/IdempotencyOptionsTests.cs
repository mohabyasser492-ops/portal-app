using PortalApp.Api.Idempotency;
using Xunit;

namespace PortalApp.UnitTests.Idempotency;

public sealed class IdempotencyOptionsTests
{
    [Fact]
    public void DefaultsAreValid() => Assert.True(new IdempotencyOptions().IsValid);

    [Theory]
    [InlineData(0, 128, 1048576)]
    [InlineData(1441, 128, 1048576)]
    [InlineData(60, 15, 1048576)]
    [InlineData(60, 257, 1048576)]
    [InlineData(60, 128, 100)]
    public void RejectsInvalidLimits(int retention, int keyLength, int bodyBytes)
    {
        Assert.False(new IdempotencyOptions
        {
            RetentionMinutes = retention,
            MaximumKeyLength = keyLength,
            MaximumBodyBytes = bodyBytes
        }.IsValid);
    }
}