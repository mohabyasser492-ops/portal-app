using System.Globalization;

namespace PortalApp.Infrastructure.SharePoint.Payroll;

public sealed record PayrollPeriod
{
    public PayrollPeriod(
        int year,
        int month)
    {
        if (year < 1)
        {
            throw new ArgumentOutOfRangeException(
                nameof(year),
                "The payroll year must be positive.");
        }

        if (month is < 1 or > 12)
        {
            throw new ArgumentOutOfRangeException(
                nameof(month),
                "The payroll month must be between 1 and 12.");
        }

        Year = year;
        Month = month;
    }

    public int Year { get; }

    public int Month { get; }

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
                "The payroll period must use YYYY-MM, YYYY_MM, or YYYY MM and contain a valid calendar month.");
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

        period = new PayrollPeriod(
            date.Year,
            date.Month);

        return true;
    }
}