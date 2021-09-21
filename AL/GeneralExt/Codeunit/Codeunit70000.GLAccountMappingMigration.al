codeunit 70000 "G/L Account Mapping Migration"
{
    trigger OnRun()
    var
        ServerFileName: Text;
        FileManagement: Codeunit "File Management";
        SheetName: Text;
        Text001: Label 'Import G/L Account Mapping';
        ExcelExt: Label '*.xlsx';
        RowNo: Integer;
        GLAccountMapping: Record "G/L Account Mapping";
    begin
        ServerFileName := FileManagement.UploadFile(Text001, ExcelExt);
        if ServerFileName = '' then
            exit;
        SheetName := ExcelBuffer.SelectSheetsName(ServerFileName);
        if SheetName = '' then
            exit;
        ExcelBuffer.LockTable();
        ExcelBuffer.OpenBook(ServerFileName, SheetName);
        ExcelBuffer.ReadSheet();

        GLAccountMapping.FindSet();
        GLAccountMapping.DeleteAll();

        for RowNo := 3 to GetLastRow do begin
            GLAccountMapping.Init();
            GLAccountMapping."New No." := GetValueAtCall(RowNo, 1);
            GLAccountMapping."Old No." := GetValueAtCall(RowNo, 2);
            GLAccountMapping.Insert(true);
        end;
    end;

    var
        ExcelBuffer: Record "Excel Buffer Mod";

    local procedure GetLastRow(): Integer

    begin
        if ExcelBuffer.FindLast() then
            exit(ExcelBuffer."Row No.");
    end;

    local procedure GetValueAtCall(RowNo: Integer; ColNo: Integer): Text

    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            exit(ExcelBuffer."Cell Value as Text");
    end;
}