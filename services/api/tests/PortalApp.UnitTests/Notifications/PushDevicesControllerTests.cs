using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PortalApp.Api.Controllers.Me;
using PortalApp.Api.Notifications;
using Xunit;

namespace PortalApp.UnitTests.Notifications;

public sealed class PushDevicesControllerTests
{
    [Fact]
    public async Task ReturnsRegisteredDevices()
    {
        var response = new PushDevicesResponse([]);
        var controller = new PushDevicesController(new FakeService(response));
        var result = await controller.Get(CancellationToken.None);
        var ok = Assert.IsType<OkObjectResult>(result.Result);
        Assert.Same(response, ok.Value);
    }

    [Fact]
    public async Task ReturnsNotFoundWhenRegistrationIsNotOwned()
    {
        var controller = new PushDevicesController(new FakeService(new PushDevicesResponse([])));
        var result = await controller.Remove("missing", CancellationToken.None);
        Assert.IsType<NotFoundResult>(result);
    }

    private sealed class FakeService : IPushDeviceService
    {
        private readonly PushDevicesResponse _response;
        public FakeService(PushDevicesResponse response) => _response = response;
        public Task<PushDevicesResponse> GetCurrentAsync(CancellationToken cancellationToken) => Task.FromResult(_response);
        public Task<PushDeviceResponse> RegisterCurrentAsync(RegisterPushDeviceRequest request, CancellationToken cancellationToken) =>
            Task.FromResult(new PushDeviceResponse("id", request.Platform, request.DeviceId, DateTimeOffset.UtcNow, DateTimeOffset.UtcNow));
        public Task<bool> RemoveCurrentAsync(string registrationId, CancellationToken cancellationToken) => Task.FromResult(false);
    }
}