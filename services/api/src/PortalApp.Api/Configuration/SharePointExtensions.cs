using PortalApp.Api.Features.Attendance;
using PortalApp.Api.Features.Leave;
using PortalApp.Api.Features.Payroll;
using PortalApp.Infrastructure.SharePoint;
using PortalApp.Infrastructure.SharePoint.Attendance;
using PortalApp.Infrastructure.SharePoint.Leave;
using PortalApp.Infrastructure.SharePoint.Payroll;

namespace PortalApp.Api.Configuration;

public static class SharePointExtensions
{
    public static IServiceCollection
        AddPortalSharePoint(
            this IServiceCollection services,
            IConfiguration configuration)
    {
        services
            .AddOptions<SharePointOptions>()
            .Bind(
                configuration.GetSection(
                    SharePointOptions.SectionName))
            .Validate(
                options =>
                    options.IsConfigured,
                "The SharePoint configuration is incomplete.")
            .ValidateOnStart();

        services.AddSingleton<
            LeaveBalanceMapper>();

        services.AddScoped<
            ILeaveBalanceRepository,
            LeaveBalanceRepository>();

        services.AddScoped<
            CurrentEmployeeIdentifierResolver>();

        services.AddScoped<
            ILeaveBalanceService,
            LeaveBalanceService>();

        services.AddSingleton<
            AttendanceMapper>();

        services.AddScoped<
            IAttendanceRepository,
            AttendanceRepository>();

        services.AddScoped<
            IAttendanceService,
            AttendanceService>();


        services.AddSingleton<PayrollDocumentMapper>();

        services.AddScoped<
            IPayrollDocumentRepository,
            PayrollDocumentRepository>();

        services.AddScoped<
            IPayrollDocumentService,
            PayrollDocumentService>();
        return services;
    }
}