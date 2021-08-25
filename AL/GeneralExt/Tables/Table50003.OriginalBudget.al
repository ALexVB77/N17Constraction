table 50003 "Original Budget"
{

    fields
    {
        field(1; "Cost Place"; Code[20])
        {
            Caption = 'Cost Place';

        }
        field(2; "Cost Code"; Code[20])
        {
            Caption = 'Cost Code';
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
        }
    }

    keys
    {
        key(Key1; "Cost Place", "Cost Code")
        {
            Clustered = true;
        }
    }

    procedure ImportExcel()
    var
        OrBudget: Record "Original Budget";
        ExcelBuf: Record "Excel Buffer" temporary;
        UploadResult: Boolean;
        NVInStream: InStream;
        Name: Text;
        SheetName: Text;
        Rno: Integer;
        MaxRow: Integer;
        DialogCaption: Label 'Select File';
        Excel2007FileType: Label 'Excel Files (*.xlsx;*.xls)|*.xlsx;*.xls', Comment = '{Split=r''\|''}{Locked=s''1''}';
        ImpErr: Label 'Nothing to import!';
        lText001: Label 'Uploaded!';
    begin
        UploadResult := UploadIntoStream(DialogCaption, '', Excel2007FileType, Name, NVInStream);
        if UploadResult then begin
            ExcelBuf.Reset();
            SheetName := ExcelBuf.SelectSheetsNameStream(NVInStream);
            ExcelBuf.OpenBookStream(NVInStream, SheetName);
            ExcelBuf.ReadSheet();
            if ExcelBuf.FindLast() then
                MaxRow := ExcelBuf."Row No.";
            if MaxRow < 2 then
                Error(ImpErr);
            for Rno := 2 to MaxRow do begin
                OrBudget.Init;
                if ExcelBuf.get(Rno, 2) then
                    OrBudget."Cost Place" := ExcelBuf."Cell Value as Text";
                if ExcelBuf.get(Rno, 1) then
                    OrBudget."Cost Code" := ExcelBuf."Cell Value as Text";
                if ExcelBuf.get(Rno, 3) then
                    if Evaluate(OrBudget.Amount, ExcelBuf."Cell Value as Text") then;
                if not OrBudget.Insert(false) then
                    OrBudget.Modify(false);
            end;
            Message(lText001);
        end;

    end;


}