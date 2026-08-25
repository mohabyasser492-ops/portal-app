namespace PortalApp.Api.Authorization.Policies;

public static class PortalPolicies
{
    public const string EmployeeAccess = "EmployeeAccess";

    public const string ManagerAccess = "ManagerAccess";

    public const string AdministratorAccess =
        "AdministratorAccess";

    public const string SecurityOperatorAccess =
        "SecurityOperatorAccess";
}