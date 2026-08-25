using PortalApp.Infrastructure.Graph;
using Xunit;

namespace PortalApp.UnitTests;

public sealed class GraphOptionsTests
{
    [Fact]
    public void IsConfigured_ReturnsTrue_ForValidConfiguration()
    {
        var options = new GraphOptions
        {
            BaseUrl =
                "https://graph.microsoft.com/v1.0",
            Scopes =
            [
                "User.Read"
            ],
            MaximumRetryAttempts = 3,
            RequestTimeoutSeconds = 30
        };

        Assert.True(options.IsConfigured);
    }

    [Fact]
    public void IsConfigured_ReturnsFalse_ForHttpBaseUrl()
    {
        var options = new GraphOptions
        {
            BaseUrl =
                "http://graph.microsoft.com/v1.0",
            Scopes =
            [
                "User.Read"
            ]
        };

        Assert.False(options.IsConfigured);
    }

    [Fact]
    public void IsConfigured_ReturnsFalse_WhenScopesAreEmpty()
    {
        var options = new GraphOptions
        {
            BaseUrl =
                "https://graph.microsoft.com/v1.0",
            Scopes = Array.Empty<string>()
        };

        Assert.False(options.IsConfigured);
    }

    [Fact]
    public void IsConfigured_ReturnsFalse_ForExcessiveRetries()
    {
        var options = new GraphOptions
        {
            BaseUrl =
                "https://graph.microsoft.com/v1.0",
            Scopes =
            [
                "User.Read"
            ],
            MaximumRetryAttempts = 10
        };

        Assert.False(options.IsConfigured);
    }
}