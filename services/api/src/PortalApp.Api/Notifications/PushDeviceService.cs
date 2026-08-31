using Microsoft.Extensions.Options;
using PortalApp.Api.Authorization;

namespace PortalApp.Api.Notifications;

public sealed class PushDeviceService : IPushDeviceService
{
    private readonly ICurrentUser _currentUser;
    private readonly IPushDeviceStore _store;
    private readonly NotificationOptions _options;
    private readonly TimeProvider _timeProvider;

    public PushDeviceService(
        ICurrentUser currentUser,
        IPushDeviceStore store,
        IOptions<NotificationOptions> options,
        TimeProvider timeProvider)
    {
        _currentUser = currentUser;
        _store = store;
        _options = options.Value;
        _timeProvider = timeProvider;
    }

    public async Task<PushDevicesResponse> GetCurrentAsync(CancellationToken cancellationToken)
    {
        var userId = ResolveUserId();
        var devices = await _store.GetForUserAsync(userId, cancellationToken);
        return new PushDevicesResponse(devices.Select(Map).ToArray());
    }

    public async Task<PushDeviceResponse> RegisterCurrentAsync(
        RegisterPushDeviceRequest request,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var userId = ResolveUserId();
        var token = NormalizeToken(request.Token);
        var deviceId = NormalizeDeviceId(request.DeviceId);
        if (!Enum.IsDefined(request.Platform))
        {
            throw new ArgumentOutOfRangeException(nameof(request.Platform), "The push platform is unsupported.");
        }

        var now = _timeProvider.GetUtcNow();
        var registration = new PushDeviceRegistration(
            Guid.NewGuid().ToString("N"),
            userId,
            token,
            request.Platform,
            deviceId,
            now,
            now);
        return Map(await _store.UpsertAsync(
            registration,
            _options.MaximumDevicesPerUser,
            cancellationToken));
    }

    public Task<bool> RemoveCurrentAsync(
        string registrationId,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(registrationId) || registrationId.Length > 64 ||
            registrationId.Any(character => !char.IsLetterOrDigit(character) && character != '-'))
        {
            throw new ArgumentException("A valid push registration identifier is required.", nameof(registrationId));
        }
        return _store.RemoveAsync(ResolveUserId(), registrationId, cancellationToken);
    }

    private string ResolveUserId()
    {
        if (!_currentUser.IsAuthenticated || string.IsNullOrWhiteSpace(_currentUser.ObjectId))
        {
            throw new UnauthorizedAccessException("An authenticated user object identifier is required.");
        }
        return _currentUser.ObjectId.Trim();
    }

    private string NormalizeToken(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException("A push token is required.", nameof(value));
        }
        var token = value.Trim();
        if (token.Length < 32 || token.Length > _options.MaximumTokenLength || token.Any(char.IsWhiteSpace) || token.Any(char.IsControl))
        {
            throw new ArgumentException("The push token format is invalid.", nameof(value));
        }
        return token;
    }

    private static string? NormalizeDeviceId(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) { return null; }
        var deviceId = value.Trim();
        if (deviceId.Length > 128 || deviceId.Any(char.IsControl))
        {
            throw new ArgumentException("The device identifier is invalid.", nameof(value));
        }
        return deviceId;
    }

    private static PushDeviceResponse Map(PushDeviceRegistration value) =>
        new(value.Id, value.Platform, value.DeviceId, value.RegisteredAt, value.LastSeenAt);
}