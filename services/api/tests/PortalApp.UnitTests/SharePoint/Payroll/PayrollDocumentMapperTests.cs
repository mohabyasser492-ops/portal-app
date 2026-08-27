using PortalApp.Infrastructure.SharePoint.Mapping;
using PortalApp.Infrastructure.SharePoint.Payroll;
using Xunit;

namespace PortalApp.UnitTests.SharePoint.Payroll;

public sealed class PayrollDocumentMapperTests
{
    private readonly PayrollDocumentMapper _mapper =
        new();

    [Fact]
    public void MapsValidPdfDocument()
    {
        const string fileName =
            "Payslip_2026-08.pdf";

        var item = CreateItem(
            name: fileName,
            mimeType: "application/pdf",
            size: 2048);

        var result =
            _mapper.Map(item);

        Assert.Equal(
            "drive-item-001",
            result.DriveItemId);

        Assert.Equal(
            fileName,
            result.FileName);

        Assert.Equal(
            "application/pdf",
            result.MimeType);

        Assert.Equal(
            2026,
            result.Period.Year);

        Assert.Equal(
            8,
            result.Period.Month);

        Assert.True(result.IsPdf);
    }

    [Fact]
    public void NormalizesMimeTypeAndHash()
    {
        var item = CreateItem(
            name: "Payslip_2026_08.PDF",
            mimeType: " APPLICATION/PDF ",
            size: 2048,
            sha1Hash: " abcdef ");

        var result =
            _mapper.Map(item);

        Assert.Equal(
            "application/pdf",
            result.MimeType);

        Assert.Equal(
            "ABCDEF",
            result.Sha1Hash);

        Assert.Equal(
            2026,
            result.Period.Year);

        Assert.Equal(
            8,
            result.Period.Month);
    }

    [Fact]
    public void MapsPeriodSeparatedBySpace()
    {
        var item = CreateItem(
            name: "Payslip 2026 08.pdf",
            mimeType: "application/pdf",
            size: 2048);

        var result =
            _mapper.Map(item);

        Assert.Equal(
            2026,
            result.Period.Year);

        Assert.Equal(
            8,
            result.Period.Month);
    }

    [Fact]
    public void RejectsFolder()
    {
        var item = new SharePointDriveItem
        {
            Id = "folder-001",
            Name = "Payroll",
            Folder = new SharePointFolderFacet
            {
                ChildCount = 2
            }
        };

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "folder",
            exception.FieldName);
    }

    [Fact]
    public void RejectsNonPdfMimeType()
    {
        var item = CreateItem(
            name: "Payslip_2026-08.txt",
            mimeType: "text/plain",
            size: 1024);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "mimeType",
            exception.FieldName);
    }

    [Fact]
    public void RejectsUnsafeFileName()
    {
        var item = CreateItem(
            name: "../Payslip_2026-08.pdf",
            mimeType: "application/pdf",
            size: 1024);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "name",
            exception.FieldName);
    }

    [Theory]
    [InlineData("folder/Payslip_2026-08.pdf")]
    [InlineData("folder\\Payslip_2026-08.pdf")]
    [InlineData("..Payslip_2026-08.pdf")]
    public void RejectsUnsafeFileNames(
        string fileName)
    {
        var item = CreateItem(
            name: fileName,
            mimeType: "application/pdf",
            size: 1024);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "name",
            exception.FieldName);
    }

    [Fact]
    public void RejectsFileWithoutPayrollPeriod()
    {
        var item = CreateItem(
            name: "Payslip.pdf",
            mimeType: "application/pdf",
            size: 1024);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "name",
            exception.FieldName);
    }

    [Theory]
    [InlineData("Payslip_2026-00.pdf")]
    [InlineData("Payslip_2026-13.pdf")]
    [InlineData("Payslip_1999-08.pdf")]
    [InlineData("Payslip_202608.pdf")]
    public void RejectsInvalidPayrollPeriods(
        string fileName)
    {
        var item = CreateItem(
            name: fileName,
            mimeType: "application/pdf",
            size: 1024);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "name",
            exception.FieldName);
    }

    [Fact]
    public void RejectsEmptyFile()
    {
        var item = CreateItem(
            name: "Payslip_2026-08.pdf",
            mimeType: "application/pdf",
            size: 0);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "size",
            exception.FieldName);
    }

    [Fact]
    public void RejectsOversizedFile()
    {
        var item = CreateItem(
            name: "Payslip_2026-08.pdf",
            mimeType: "application/pdf",
            size: 26L * 1024L * 1024L);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "size",
            exception.FieldName);
    }

    [Fact]
    public void RejectsMissingFileFacet()
    {
        var item = new SharePointDriveItem
        {
            Id = "drive-item-001",
            Name = "Payslip_2026-08.pdf",
            Size = 2048
        };

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "file",
            exception.FieldName);
    }

    [Fact]
    public void RejectsMissingItemIdentifier()
    {
        var item = CreateItem(
            name: "Payslip_2026-08.pdf",
            mimeType: "application/pdf",
            size: 2048,
            id: string.Empty);

        var exception =
            Assert.Throws<SharePointMappingException>(
                () => _mapper.Map(item));

        Assert.Equal(
            "id",
            exception.FieldName);
    }

    private static SharePointDriveItem CreateItem(
        string name,
        string mimeType,
        long size,
        string? sha1Hash = null,
        string id = "drive-item-001")
    {
        return new SharePointDriveItem
        {
            Id = id,
            Name = name,
            ETag = "etag-001",
            Size = size,
            CreatedDateTime =
                new DateTimeOffset(
                    2026,
                    8,
                    1,
                    8,
                    0,
                    0,
                    TimeSpan.Zero),
            LastModifiedDateTime =
                new DateTimeOffset(
                    2026,
                    8,
                    25,
                    9,
                    0,
                    0,
                    TimeSpan.Zero),
            File = new SharePointFileFacet
            {
                MimeType = mimeType,
                Hashes = new SharePointFileHashes
                {
                    Sha1Hash = sha1Hash
                }
            }
        };
    }
}