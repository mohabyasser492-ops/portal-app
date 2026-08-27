using System.Globalization;

namespace PortalApp.Infrastructure.SharePoint.Payroll;

public sealed record PayrollPeriod(
    int Year,
    int Month)
{
    public const int MinimumYear = 2000;

    public const int MaximumYear = 2200;

    public string Value =>
        string.Create(
            CultureInfo.InvariantCulture,
            $"{Year:D4}-{Month:D2}");

    public static PayrollPeriod Parse(
        string value)
    {
        if (!TryParse(value, out var period))
        {
            throw new FormatException(
                "The payroll period must contain a year between 2000 and 2200 and a valid month.");
        }

        return period;
    }

    public static bool TryParse(
        string? value,
        out PayrollPeriod period)
    {
        period = default!;

        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        var formats = new[]
        {
            "yyyy-MM",
            "yyyy_MM",
            "yyyy MM"
        };

        if (!DateTime.TryParseExact(
                value.Trim(),
                formats,
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out var date))
        {
            return false;
        }

        if (date.Year < MinimumYear ||
            date.Year > MaximumYear)
        {
            return false;
        }

        period = new PayrollPeriod(
            date.Year,
            date.Month);

        return true;
    }
}