using System.Security.Claims;
using Microsoft.Extensions.Options;
using PortalApp.Api.Authorization;
using PortalApp.Api.Notifications;
using Xunit;

namespace PortalApp.UnitTests.Notifications;

public sealed class PushDeviceServiceTests
{
    [Fact]
    public async Task RegistersAndListsCurrentUsersDevice()
    {
        var store = new InMemoryPushDeviceStore();
        var service = CreateService("user-001", store);
        var token = new string('a', 64);

        var registered = await service.RegisterCurrentAsync(
            new RegisterPushDeviceRequest(token, PushPlatform.Android, "device-001"),
            CancellationToken.None);
        var result = await service.GetCurrentAsync(CancellationToken.None);

        Assert.Single(result.Devices);
        Assert.Equal(registered.Id, result.Devices[0].Id);
        Assert.Equal(PushPlatform.Android, result.Devices[0].Platform);
    }

    [Fact]
    public async Task RefreshingSameTokenKeepsRegistrationIdentifier()
    {
        var store = new InMemoryPushDeviceStore();
        var service = CreateService("user-001", store);
        var token = new string('b', 64);

        var first = await service.RegisterCurrentAsync(
            new RegisterPushDeviceRequest(token, PushPlatform.Android, null),
            CancellationToken.None);
        var second = await service.RegisterCurrentAsync(
            new RegisterPushDeviceRequest(token, PushPlatform.Ios, "device-002"),
            CancellationToken.None);

        Assert.Equal(first.Id, second.Id);
        Assert.Equal(PushPlatform.Ios, second.Platform);
    }

    [Fact]
    public async Task CannotRemoveAnotherUsersRegistration()
    {
        var store = new InMemoryPushDeviceStore();
        var owner = CreateService("user-001", store);
        var other = CreateService("user-002", store);
        var registration = await owner.RegisterCurrentAsync(
            new RegisterPushDeviceRequest(new string('c', 64), PushPlatform.Android, null),
            CancellationToken.None);

        Assert.False(await other.RemoveCurrentAsync(registration.Id, CancellationToken.None));
        Assert.Single((await owner.GetCurrentAsync(CancellationToken.None)).Devices);
    }

    [Theory]
    [InlineData("")]
    [InlineData("short")]
    [InlineData("contains whitespace token value")]
    public async Task RejectsInvalidToken(string token)
    {
        var service = CreateService("user-001", new InMemoryPushDeviceStore());
        await Assert.ThrowsAsync<ArgumentException>(() => service.RegisterCurrentAsync(
            new RegisterPushDeviceRequest(token, PushPlatform.Android, null),
            CancellationToken.None));
    }

    private static PushDeviceService CreateService(string objectId, IPushDeviceStore store) =>
        new(new TestUser(objectId), store, Options.Create(new NotificationOptions()), TimeProvider.System);

    private sealed class TestUser : ICurrentUser
    {
        public TestUser(string objectId)
        {
            ObjectId = objectId;
            Principal = new ClaimsPrincipal(new ClaimsIdentity([new Claim("oid", objectId)], "Test"));
        }
        public bool IsAuthenticated => true;
        public string? ObjectId { get; }
        public string? TenantId => null;
        public string? DisplayName => null;
        public string? Username => null;
        public IReadOnlyCollection<string> Roles => [];
        public ClaimsPrincipal Principal { get; }
    }
}