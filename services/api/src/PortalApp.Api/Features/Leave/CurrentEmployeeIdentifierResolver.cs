using PortalApp.Api.Authorization;

namespace PortalApp.Api.Features.Leave;

public sealed class CurrentEmployeeIdentifierResolver
{
    private static readonly string[] ClaimTypes =
    [
        "employee_id",
        "employeeid",
        "extension_EmployeeId"
    ];

    public string Resolve(
        ICurrentUser currentUser)
    {
        ArgumentNullException.ThrowIfNull(
            currentUser);

        if (!currentUser.IsAuthenticated)
        {
            throw new UnauthorizedAccessException(
                "An authenticated employee is required.");
        }

        foreach (var claimType in ClaimTypes)
        {
            var value =
                currentUser.Principal
                    .FindFirst(claimType)
                    ?.Value
                    ?.Trim();

            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }
        }

        var objectId =
            currentUser.ObjectId?.Trim();

        if (!string.IsNullOrWhiteSpace(
                objectId))
        {
            return objectId;
        }

        throw new UnauthorizedAccessException(
            "The authenticated identity does not contain an employee identifier.");
    }
}