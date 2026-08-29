using Microsoft.Extensions.Options;
using PortalApp.Api.FileSecurity;
using PortalApp.Infrastructure.Graph;
using Xunit;

namespace PortalApp.UnitTests.FileSecurity;

public sealed class FileSecurityValidatorTests
{
    private readonly FileSecurityValidator _validator =
        new(
            Options.Create(
                new FileSecurityOptions
                {
                    MaximumSizeBytes = 1024,
                    AllowedExtensions =
                    [
                        ".pdf"
                    ],
                    AllowedContentTypes =
                    [
                        "application/pdf"
                    ]
                }));

    [Fact]
    public async Task AcceptsValidPdfAndRestoresStreamPosition()
    {
        await using var file =
            CreateFile(
            [
                0x25,
                0x50,
                0x44,
                0x46,
                0x2D,
                0x01
            ]);

        var result =
            await _validator.ValidateDownloadAsync(
                file,
                "fallback.pdf",
                CancellationToken.None);

        Assert.Equal(
            "payslip.pdf",
            result);

        Assert.Equal(
            0,
            file.Content.Position);
    }

    [Theory]
    [InlineData("../payslip.pdf")]
    [InlineData("folder/payslip.pdf")]
    [InlineData("folder\\payslip.pdf")]
    [InlineData("..payslip.pdf")]
    public async Task UsesSafeFallbackForSanitizedFileName(
        string unsafeFileName)
    {
        await using var file =
            CreateFile(
            [
                0x25,
                0x50,
                0x44,
                0x46,
                0x2D
            ],
            unsafeFileName);

        Assert.Null(
            file.FileName);

        var result =
            await _validator.ValidateDownloadAsync(
                file,
                "fallback.pdf",
                CancellationToken.None);

        Assert.Equal(
            "fallback.pdf",
            result);

        Assert.Equal(
            0,
            file.Content.Position);
    }

    [Theory]
    [InlineData("payslip.exe")]
    [InlineData("payslip.txt")]
    [InlineData("payslip.html")]
    public async Task RejectsDisallowedFileExtensions(
        string fileName)
    {
        await using var file =
            CreateFile(
            [
                0x25,
                0x50,
                0x44,
                0x46,
                0x2D
            ],
            fileName);

        await Assert.ThrowsAsync<
            FileSecurityValidationException>(
            () =>
                _validator.ValidateDownloadAsync(
                    file,
                    "fallback.pdf",
                    CancellationToken.None));
    }

    [Fact]
    public async Task RejectsSpoofedPdfContent()
    {
        await using var file =
            CreateFile(
            [
                0x4D,
                0x5A,
                0x90,
                0x00,
                0x00
            ]);

        await Assert.ThrowsAsync<
            FileSecurityValidationException>(
            () =>
                _validator.ValidateDownloadAsync(
                    file,
                    "fallback.pdf",
                    CancellationToken.None));

        Assert.Equal(
            0,
            file.Content.Position);
    }

    [Fact]
    public async Task RejectsDisallowedContentType()
    {
        await using var file =
            CreateFile(
            [
                0x25,
                0x50,
                0x44,
                0x46,
                0x2D
            ],
            contentType: "text/html");

        await Assert.ThrowsAsync<
            FileSecurityValidationException>(
            () =>
                _validator.ValidateDownloadAsync(
                    file,
                    "fallback.pdf",
                    CancellationToken.None));
    }

    [Fact]
    public async Task RejectsOversizedContent()
    {
        await using var file =
            new GraphFileContent(
                new MemoryStream(
                [
                    0x25,
                    0x50,
                    0x44,
                    0x46,
                    0x2D
                ]),
                "application/pdf",
                2048,
                null,
                "payslip.pdf");

        await Assert.ThrowsAsync<
            FileSecurityValidationException>(
            () =>
                _validator.ValidateDownloadAsync(
                    file,
                    "fallback.pdf",
                    CancellationToken.None));
    }

    [Fact]
    public async Task RejectsEmptyContent()
    {
        await using var file =
            new GraphFileContent(
                new MemoryStream(),
                "application/pdf",
                0,
                null,
                "payslip.pdf");

        await Assert.ThrowsAsync<
            FileSecurityValidationException>(
            () =>
                _validator.ValidateDownloadAsync(
                    file,
                    "fallback.pdf",
                    CancellationToken.None));
    }

    [Fact]
    public async Task RejectsUnsafeFallbackFileName()
    {
        await using var file =
            CreateFile(
            [
                0x25,
                0x50,
                0x44,
                0x46,
                0x2D
            ],
            "../untrusted.pdf");

        Assert.Null(
            file.FileName);

        await Assert.ThrowsAsync<
            FileSecurityValidationException>(
            () =>
                _validator.ValidateDownloadAsync(
                    file,
                    "../fallback.pdf",
                    CancellationToken.None));
    }

    [Fact]
    public async Task HonorsCancellationBeforeValidation()
    {
        await using var file =
            CreateFile(
            [
                0x25,
                0x50,
                0x44,
                0x46,
                0x2D
            ]);

        using var cancellationSource =
            new CancellationTokenSource();

        cancellationSource.Cancel();

        await Assert.ThrowsAnyAsync<
            OperationCanceledException>(
            () =>
                _validator.ValidateDownloadAsync(
                    file,
                    "fallback.pdf",
                    cancellationSource.Token));
    }

    private static GraphFileContent CreateFile(
        byte[] bytes,
        string fileName = "payslip.pdf",
        string contentType = "application/pdf")
    {
        return new GraphFileContent(
            new MemoryStream(bytes),
            contentType,
            bytes.Length,
            null,
            fileName);
    }
}