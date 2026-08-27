using PortalApp.Infrastructure.SharePoint.Mapping;

namespace PortalApp.Infrastructure.SharePoint.Leave;

public sealed class LeaveBalanceMapper
{
    public LeaveBalanceRecord Map(
        SharePointListItem item)
    {
        ArgumentNullException.ThrowIfNull(item);

        if (string.IsNullOrWhiteSpace(item.Id))
        {
            throw new SharePointMappingException(
                string.Empty,
                "id",
                "The SharePoint list item identifier is missing.");
        }

        var fields =
            new SharePointFieldReader(item);

        var entitledDays =
            fields.GetOptionalDecimal(
                LeaveBalanceFields.EntitledDays) ??
            0m;

        var usedDays =
            fields.GetOptionalDecimal(
                LeaveBalanceFields.UsedDays) ??
            0m;

        var pendingDays =
            fields.GetOptionalDecimal(
                LeaveBalanceFields.PendingDays) ??
            0m;

        var explicitRemainingDays =
            fields.GetOptionalDecimal(
                LeaveBalanceFields.RemainingDays);

        ValidateNonNegative(
            item.Id,
            LeaveBalanceFields.EntitledDays,
            entitledDays);

        ValidateNonNegative(
            item.Id,
            LeaveBalanceFields.UsedDays,
            usedDays);

        ValidateNonNegative(
            item.Id,
            LeaveBalanceFields.PendingDays,
            pendingDays);

        if (explicitRemainingDays is not null)
        {
            ValidateNonNegative(
                item.Id,
                LeaveBalanceFields.RemainingDays,
                explicitRemainingDays.Value);
        }

        var remainingDays =
            explicitRemainingDays ??
            Math.Max(
                entitledDays -
                usedDays -
                pendingDays,
                0m);

        var balanceYear =
            fields.GetOptionalInt32(
                LeaveBalanceFields.BalanceYear) ??
            DateTimeOffset.UtcNow.Year;

        if (balanceYear is < 2000 or > 2200)
        {
            throw new SharePointMappingException(
                item.Id,
                LeaveBalanceFields.BalanceYear,
                "The leave balance year is outside the supported range.");
        }

        return new LeaveBalanceRecord(
            SharePointItemId: item.Id,
            ETag: item.ETag,
            EmployeeId:
                fields.GetRequiredString(
                    LeaveBalanceFields.EmployeeId),
            LeaveType:
                fields.GetRequiredString(
                    LeaveBalanceFields.LeaveType),
            EntitledDays: entitledDays,
            UsedDays: usedDays,
            PendingDays: pendingDays,
            RemainingDays: remainingDays,
            BalanceYear: balanceYear,
            LastUpdated:
                fields.GetOptionalDateTimeOffset(
                    LeaveBalanceFields.LastUpdated) ??
                item.LastModifiedDateTime);
    }

    private static void ValidateNonNegative(
        string itemId,
        string fieldName,
        decimal value)
    {
        if (value < 0)
        {
            throw new SharePointMappingException(
                itemId,
                fieldName,
                "Leave balance values cannot be negative.");
        }
    }
}