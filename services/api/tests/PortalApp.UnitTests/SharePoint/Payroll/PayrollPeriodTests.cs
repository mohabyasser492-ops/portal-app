using PortalApp.Infrastructure.SharePoint.Payroll;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Payroll;

public sealed class PayrollPeriodTests
{
    [Theory]
    [InlineData("2026-08", 2026, 8)]
    [InlineData("2026_08", 2026, 8)]
    [InlineData("2026 08", 2026, 8)]
    [InlineData("1970-08", 1970, 8)]
    [InlineData("1965-12", 1965, 12)]
    [InlineData("2300-01", 2300, 1)]
    public void ParsesSupportedPeriods(
        string source,
        int expectedYear,
        int expectedMonth)
    {
        var result =
            PayrollPeriod.Parse(source);

        Assert.Equal(
            expectedYear,
            result.Year);

        Assert.Equal(
            expectedMonth,
            result.Month);
    }

    [Theory]
    [InlineData("")]
    [InlineData("202608")]
    [InlineData("2026-00")]
    [InlineData("2026-13")]
    [InlineData("August 2026")]
    public void RejectsInvalidPeriods(
        string source)
    {
        Assert.False(
            PayrollPeriod.TryParse(
                source,
                out _));
    }

    [Fact]
    public void ReturnsNormalizedValue()
    {
        var period =
            new PayrollPeriod(
                2026,
                8);

        Assert.Equal(
            "2026-08",
            period.Value);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public void ConstructorRejectsNonPositiveYear(
        int year)
    {
        Assert.Throws<ArgumentOutOfRangeException>(
            () => new PayrollPeriod(
                year,
                8));
    }

    [Theory]
    [InlineData(0)]
    [InlineData(13)]
    [InlineData(-1)]
    public void ConstructorRejectsInvalidMonth(
        int month)
    {
        Assert.Throws<ArgumentOutOfRangeException>(
            () => new PayrollPeriod(
                2026,
                month));
    }
}