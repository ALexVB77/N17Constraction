dotnet
{
    assembly(zxing)
    {
        type(ZXing.Common.EncodingOptions; ZXingCommonEncodingOptions) { }
        type(ZXing.Common.BitMatrix; ZXingCommonBitMatrix) { }
        type(ZXing.BarcodeFormat; ZXingBarcodeFormat) { }
        type("ZXing.BarcodeWriter`1"; ZXingBarcodeWriter) { }
    }
}