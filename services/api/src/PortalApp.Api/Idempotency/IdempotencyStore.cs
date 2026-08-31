using System.Collections.Concurrent;

namespace PortalApp.Api.Idempotency;

public interface IIdempotencyStore
{
    IdempotencyAcquireResult Acquire(string scope, string fingerprint, DateTimeOffset now);
    void Complete(string scope, IdempotencyRecord record);
    void Abandon(string scope);
}

public sealed class InMemoryIdempotencyStore : IIdempotencyStore
{
    private sealed class Entry
    {
        public Entry(string fingerprint)
        {
            Fingerprint = fingerprint;
            Completion = new TaskCompletionSource<IdempotencyRecord?>(TaskCreationOptions.RunContinuationsAsynchronously);
        }
        public string Fingerprint { get; }
        public IdempotencyRecord? Record { get; set; }
        public TaskCompletionSource<IdempotencyRecord?> Completion { get; }
    }

    private readonly ConcurrentDictionary<string, Entry> _entries = new(StringComparer.Ordinal);

    public IdempotencyAcquireResult Acquire(string scope, string fingerprint, DateTimeOffset now)
    {
        while (true)
        {
            if (_entries.TryGetValue(scope, out var existing))
            {
                if (existing.Record is { } record && record.ExpiresAt <= now)
                {
                    _entries.TryRemove(new KeyValuePair<string, Entry>(scope, existing));
                    continue;
                }
                if (!string.Equals(existing.Fingerprint, fingerprint, StringComparison.Ordinal))
                {
                    return new(IdempotencyAcquireStatus.Conflict, null, null);
                }
                return existing.Record is { } replay
                    ? new(IdempotencyAcquireStatus.Replay, replay, null)
                    : new(IdempotencyAcquireStatus.Replay, null, existing.Completion.Task);
            }

            var created = new Entry(fingerprint);
            if (_entries.TryAdd(scope, created))
            {
                return new(IdempotencyAcquireStatus.Acquired, null, null);
            }
        }
    }

    public void Complete(string scope, IdempotencyRecord record)
    {
        if (_entries.TryGetValue(scope, out var entry))
        {
            entry.Record = record;
            entry.Completion.TrySetResult(record);
        }
    }

    public void Abandon(string scope)
    {
        if (_entries.TryRemove(scope, out var entry))
        {
            entry.Completion.TrySetResult(null);
        }
    }
}