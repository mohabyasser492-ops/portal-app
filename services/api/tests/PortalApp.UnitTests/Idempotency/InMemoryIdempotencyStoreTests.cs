using PortalApp.Api.Idempotency;
using Xunit;

namespace PortalApp.UnitTests.Idempotency;

public sealed class InMemoryIdempotencyStoreTests
{
    [Fact]
    public void ReplaysCompletedRequest()
    {
        var store = new InMemoryIdempotencyStore();
        var now = DateTimeOffset.UtcNow;
        Assert.Equal(IdempotencyAcquireStatus.Acquired, store.Acquire("scope", "fingerprint", now).Status);
        store.Complete("scope", new IdempotencyRecord("fingerprint", 200, "application/json", [1], now.AddMinutes(1)));
        var replay = store.Acquire("scope", "fingerprint", now);
        Assert.Equal(IdempotencyAcquireStatus.Replay, replay.Status);
        Assert.NotNull(replay.Record);
    }

    [Fact]
    public void RejectsKeyReuseWithDifferentFingerprint()
    {
        var store = new InMemoryIdempotencyStore();
        var now = DateTimeOffset.UtcNow;
        store.Acquire("scope", "first", now);
        Assert.Equal(IdempotencyAcquireStatus.Conflict, store.Acquire("scope", "second", now).Status);
    }
}