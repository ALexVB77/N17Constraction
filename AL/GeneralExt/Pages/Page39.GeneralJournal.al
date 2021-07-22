pageextension 80039 "General Journal (Ext)" extends "General Journal"
{
    actions
    {
        addlast("F&unctions")
        {
            action("Import from Excel")
            {
                Caption = 'Import from Excel';
                Image = Excel;

                trigger OnAction()
                begin
                    ServerFileName := FileManagement.UploadFile(FileNameText, ExcelExtText);
                    if ServerFileName = '' then
                        exit;
                    SheetName := ExcelBuffer.SelectSheetsName(ServerFileName);
                    if SheetName = '' then
                        exit;

                    ExcelBuffer.LockTable();
                    ExcelBuffer.OpenBook(ServerFileName, SheetName);
                    ExcelBuffer.ReadSheet();
                    GetLastRowAndColumn();
                end;
            }
        }
    }
    var
        ServerFileName: Text;
        FileManagement: Codeunit "File Management";
        FileNameText: Label 'Import General Journal Line';
        ExcelExtText: Label '*.xlsx';
        SheetName: Text;
        ExcelBuffer: Record "Excel Buffer Mod" temporary;
        TotalColumns: Integer;
        TotalRows: Integer;

    local procedure GetLastRowAndColumn()
    begin
        ExcelBuffer.SetRange("Row No.", 1);
        TotalColumns := ExcelBuffer.Count;

        ExcelBuffer.Reset();
        if ExcelBuffer.FindLast() then
            TotalRows := ExcelBuffer."Row No.";
    end;
}