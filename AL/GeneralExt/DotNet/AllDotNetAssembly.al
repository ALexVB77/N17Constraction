dotnet
{
    assembly(zxing)
    {
        type(ZXing.Common.EncodingOptions; ZXingCommonEncodingOptions) { }
        type(ZXing.Common.BitMatrix; ZXingCommonBitMatrix) { }
        type(ZXing.BarcodeFormat; ZXingBarcodeFormat) { }
        type(ZXing.BarcodeWriter; ZXingBarcodeWriter) { }
    }
    assembly(System.Drawing)
    {
        type(System.Drawing.Bitmap; BitmapExt) { }
        type(System.Drawing.Imaging.ImageFormat; ImageFormatExt) { }
    }
}