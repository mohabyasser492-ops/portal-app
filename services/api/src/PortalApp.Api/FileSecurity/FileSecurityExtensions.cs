namespace PortalApp.Api.FileSecurity;

public static class FileSecurityExtensions
{
    public static IServiceCollection AddPortalFileSecurity(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services
            .AddOptions<FileSecurityOptions>()
            .Bind(configuration.GetSection(FileSecurityOptions.SectionName))
            .Validate(options => options.IsValid, "The file-security configuration is invalid.")
            .ValidateOnStart();

        services.AddSingleton<IFileSecurityValidator, FileSecurityValidator>();
        return services;
    }
}