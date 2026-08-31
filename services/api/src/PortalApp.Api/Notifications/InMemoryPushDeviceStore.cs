using System.Collections.Concurrent;

namespace PortalApp.Api.Notifications;

public sealed class InMemoryPushDeviceStore : IPushDeviceStore
{
    private readonly ConcurrentDictionary<string, PushDeviceRegistration> _registrations = new(StringComparer.Ordinal);

    public Task<IReadOnlyList<PushDeviceRegistration>> GetForUserAsync(
        string userObjectId,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        IReadOnlyList<PushDeviceRegistration> result = _registrations.Values
            .Where(item => string.Equals(item.UserObjectId, userObjectId, StringComparison.Ordinal))
            .OrderByDescending(item => item.LastSeenAt)
            .ToArray();
        return Task.FromResult(result);
    }

    public Task<PushDeviceRegistration> UpsertAsync(
        PushDeviceRegistration registration,
        int maximumDevicesPerUser,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var existing = _registrations.Values.SingleOrDefault(item =>
            string.Equals(item.UserObjectId, registration.UserObjectId, StringComparison.Ordinal) &&
            string.Equals(item.Token, registration.Token, StringComparison.Ordinal));

        var saved = existing is null
            ? registration
            : registration with { Id = existing.Id, RegisteredAt = existing.RegisteredAt };
        _registrations[saved.Id] = saved;

        var excess = _registrations.Values
            .Where(item => string.Equals(item.UserObjectId, registration.UserObjectId, StringComparison.Ordinal))
            .OrderByDescending(item => item.LastSeenAt)
            .Skip(maximumDevicesPerUser)
            .ToArray();
        foreach (var item in excess) { _registrations.TryRemove(item.Id, out _); }

        return Task.FromResult(saved);
    }

    public Task<bool> RemoveAsync(
        string userObjectId,
        string registrationId,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        if (!_registrations.TryGetValue(registrationId, out var value) ||
            !string.Equals(value.UserObjectId, userObjectId, StringComparison.Ordinal))
        {
            return Task.FromResult(false);
        }
        return Task.FromResult(_registrations.TryRemove(registrationId, out _));
    }
}