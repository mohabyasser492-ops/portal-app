using PortalApp.Infrastructure.Graph;
using Xunit;

namespace PortalApp.UnitTests.Graph;

public sealed class GraphFileContentTests
{
    [Fact]
    public async Task NormalizesMetadataAndDisposesOwnedResources()
    {
        var stream = new TrackingStream([1, 2, 3]);
        var owner = new TrackingOwner();
        var file = new GraphFileContent(
            stream,
            " APPLICATION/PDF; charset=binary ",
            3,
            " etag-001 ",
            " payslip.pdf ",
            null,
            owner);

        Assert.True(file.IsPdf);
        Assert.Equal("application/pdf", file.ContentType);
        Assert.Equal("payslip.pdf", file.FileName);
        Assert.False(file.IsDisposed);

        await file.DisposeAsync();

        Assert.True(file.IsDisposed);
        Assert.True(stream.WasDisposed);
        Assert.True(owner.WasDisposed);
        Assert.Throws<ObjectDisposedException>(() => _ = file.Content);
    }

    private sealed class TrackingOwner : IDisposable
    {
        public bool WasDisposed { get; private set; }
        public void Dispose() => WasDisposed = true;
    }

    private sealed class TrackingStream : MemoryStream
    {
        public TrackingStream(byte[] bytes) : base(bytes) { }
        public bool WasDisposed { get; private set; }
        protected override void Dispose(bool disposing)
        {
            WasDisposed = true;
            base.Dispose(disposing);
        }
    }
}