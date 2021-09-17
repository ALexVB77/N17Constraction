report 70009 "FA Turnover (Excel)"
{
    ApplicationArea = All;
    Caption = 'FA Turnover (Excel)';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("FA Depreciation Book"; "FA Depreciation Book")
        {
            trigger OnPreDataItem()
            begin
                if FANo <> '' then
                    "FA Depreciation Book".SetFilter("FA No.", FANo);
                if HideDisposal then
                    "FA Depreciation Book".SetFilter("Disposal Date", '%1|%2..', 0D, EndDate + 1);
                "FA Depreciation Book".SetRange("Depreciation Book Code", FADeprBookCode);

                FALedgEntry.Reset();
                FALedgEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "FA Posting Date");
                if GlobDim1Filter <> '' then
                    FALedgEntry.SetFilter("Global Dimension 1 Code", GlobDim1Filter);
                FillHeader();
            end;

            trigger OnAfterGetRecord()
            var
                FixedAsset: Record "Fixed Asset";
                DimValue: Record "Dimension Value";
                DeprGroup: Record "Depreciation Group";
                FASubclass: Record "FA Subclass";
                LineAmountsList: Dictionary of [Integer, Text];
            begin
                Clear(LineAmountsList);

                FALedgEntry.SetRange("FA No.", "FA Depreciation Book"."FA No.");
                FALedgEntry.SetRange("Depreciation Book Code", "FA Depreciation Book"."Depreciation Book Code");
                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");

                FALedgEntry.SetRange("FA Posting Category");
                FALedgEntry.SetRange(Reversed);

                FALedgEntry.SetFilter("FA Posting Date", '<%1', StartDate);
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 9, FALedgEntry.Amount);
                    SetListValue(TotalAmountsList, 9, FALedgEntry.Amount);
                end;

                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::Depreciation);
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 10, FALedgEntry.Amount * (-1));
                    SetListValue(TotalAmountsList, 10, FALedgEntry.Amount * (-1));
                end;

                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");
                FALedgEntry.SetRange("FA Posting Category", FALedgEntry."FA Posting Category"::" ");
                FALedgEntry.SetRange("FA Posting Date", StartDate, EndDate);
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 11, FALedgEntry.Amount);
                    SetListValue(TotalAmountsList, 11, FALedgEntry.Amount);
                end;

                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::Depreciation);
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 12, FALedgEntry.Amount * (-1));
                    SetListValue(TotalAmountsList, 12, FALedgEntry.Amount * (-1));
                end;

                FALedgEntry.SetFilter("FA Posting Category", '<>%1', FALedgEntry."FA Posting Category"::" ");
                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 13, FALedgEntry.Amount * (-1));
                    SetListValue(TotalAmountsList, 13, FALedgEntry.Amount * (-1));
                end;

                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::Depreciation);
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 14, FALedgEntry.Amount);
                    SetListValue(TotalAmountsList, 14, FALedgEntry.Amount);
                end;

                FALedgEntry.SetRange("FA Posting Category");
                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");
                FALedgEntry.SetFilter("FA Posting Date", '..%1', EndDate);
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 15, FALedgEntry.Amount);
                    SetListValue(TotalAmountsList, 15, FALedgEntry.Amount);
                end;

                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::Depreciation);
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 16, FALedgEntry.Amount * (-1));
                    SetListValue(TotalAmountsList, 16, FALedgEntry.Amount * (-1));
                end;

                FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost", FALedgEntry."FA Posting Type"::Depreciation);
                FALedgEntry.CalcSums(Amount);
                if FALedgEntry.Amount <> 0 then begin
                    SetListValue(LineAmountsList, 17, FALedgEntry.Amount);
                    SetListValue(TotalAmountsList, 17, FALedgEntry.Amount);
                end;

                if not IsEmptyCollection(LineAmountsList) then begin
                    FixedAsset.Get("FA Depreciation Book"."FA No.");

                    if not DimValue.Get(GLSetup."Global Dimension 1 Code", FixedAsset."Global Dimension 1 Code") then
                        DimValue.Init();

                    SetListValue(LineAmountsList, 2, FixedAsset.Description);
                    SetListValue(LineAmountsList, 3, StrSubstNo('%1 %2', FixedAsset."Global Dimension 1 Code", DimValue.Name));
                    SetListValue(LineAmountsList, 4, Format("FA Depreciation Book"."No. of Depreciation Months"));
                    if DeprGroup.Get(FixedAsset."Depreciation Group") then
                        SetListValue(LineAmountsList, 5, DeprGroup.Description);
                    if FASubclass.Get(FixedAsset."FA Subclass Code") then
                        SetListValue(LineAmountsList, 6, FASubclass.Name);
                    FALedgEntry.SetRange("FA Posting Date");
                    FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");
                    FALedgEntry.SetRange("FA Posting Category", FALedgEntry."FA Posting Category"::" ");
                    FALedgEntry.SetRange(Reversed, false);
                    if FALedgEntry.FindFirst() then
                        SetListValue(LineAmountsList, 7, Format(FALedgEntry."FA Posting Date"));
                    SetListValue(LineAmountsList, 8, StrSubstNo('%1', FixedAsset."No."));

                    FillLine(LineAmountsList);
                end;
            end;

            trigger OnPostDataItem()
            begin
                FillFooter(TotalAmountsList);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                    }
                    field(EndtDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                    }
                    field(FANo; FANo)
                    {
                        ApplicationArea = All;
                        Caption = 'Fixed Asset No.';
                        TableRelation = "Fixed Asset"."No.";
                    }
                    field(FADeprBookCode; FADeprBookCode)
                    {
                        ApplicationArea = All;
                        Caption = 'FA Deprication Book Code';
                        TableRelation = "Depreciation Book".Code;
                    }
                    field(GlobDim1Filter; GlobDim1Filter)
                    {
                        ApplicationArea = All;
                        Caption = 'Global Dimension 1 Filter';
                        TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
                        CaptionClass = '1,1,1';
                    }
                    field(HideDisposal; HideDisposal)
                    {
                        ApplicationArea = All;
                        Caption = 'Hide Disposal FA';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            FASetup.Get();
            FADeprBookCode := FASetup."Release Depr. Book";
        end;
    }
    trigger OnPreReport()
    begin
        if (StartDate = 0D) or (EndDate = 0D) then
            Error(ErrText001);
        GLSetup.Get();
        FASetup.Get();
        FASetup.TestField("FA Turnover Template Code");
        PrepareExcel();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        FASetup: Record "FA Setup";
        FALedgEntry: Record "FA Ledger Entry";
        ExcelBufferTmp: Record "Excel Buffer Mod" temporary;
        ExcelReportBuilderManager: Codeunit "Excel Report Builder Manager";
        StdRepMgt: Codeunit "Local Report Management";
        TotalAmountsList: Dictionary of [Integer, Decimal];
        StartDate: Date;
        EndDate: Date;
        FANo: Code[20];
        FADeprBookCode: Code[20];
        GlobDim1Filter: Code[150];
        RowNo: Integer;
        HideDisposal: Boolean;
        ErrText001: Label 'You must specify Strat Date and End Date.';
        Text001: Label 'Fixed Assets Turnover';
        Text002: Label 'Period: from %1 to %2';
        Text003: Label 'Total: ';

    local procedure PrepareExcel()
    var
        ExcelTemplate: Record "Excel Template";
        Instream: InStream;
    begin
        ExcelTemplate.Get(FASetup."FA Turnover Template Code");
        ExcelTemplate.CalcFields(BLOB);
        ExcelTemplate.BLOB.CreateInStream(InStream);

        Clear(ExcelBufferTmp);
        ExcelBufferTmp.DeleteAll();
        ExcelBufferTmp.UpdateBookStream(InStream, 'Sheet1', true);
    end;

    local procedure FillHeader()
    var
        ColumnNo: Integer;
    begin
        RowNo := 1;
        ColumnNo := 2;
        EnterCell(RowNo, ColumnNo, StdRepMgt.GetCompanyName, false, ExcelBufferTmp."Cell Type"::Text, false);
        RowNo += 1;
        EnterCell(RowNo, ColumnNo, Text001, true, ExcelBufferTmp."Cell Type"::Text, false);
        RowNo += 1;
        EnterCell(RowNo, ColumnNo, StrSubstNo(Text002, Format(StartDate), Format(EndDate)), true, ExcelBufferTmp."Cell Type"::Text, false);
        RowNo := 9;
    end;

    local procedure FillLine(LineList: Dictionary of [Integer, Text])
    var
        i: Integer;
    begin
        EnterCell(RowNo, 2, GetListValue(LineList, 2), false, ExcelBufferTmp."Cell Type"::Text, true);
        EnterCell(RowNo, 3, GetListValue(LineList, 3), false, ExcelBufferTmp."Cell Type"::Text, true);
        EnterCell(RowNo, 4, GetListValue(LineList, 4), false, ExcelBufferTmp."Cell Type"::Number, true);
        EnterCell(RowNo, 5, GetListValue(LineList, 5), false, ExcelBufferTmp."Cell Type"::Text, true);
        EnterCell(RowNo, 6, GetListValue(LineList, 6), false, ExcelBufferTmp."Cell Type"::Text, true);
        EnterCell(RowNo, 7, GetListValue(LineList, 7), false, ExcelBufferTmp."Cell Type"::Date, true);
        EnterCell(RowNo, 8, GetListValue(LineList, 8), false, ExcelBufferTmp."Cell Type"::Text, true);
        for i := 9 to 17 do
            EnterCell(RowNo, i, GetListValue(LineList, i), false, ExcelBufferTmp."Cell Type"::Number, true);
        RowNo += 1;
    end;

    local procedure FillFooter(LineList: Dictionary of [Integer, Decimal])
    var
        i: Integer;
    begin
        EnterCell(RowNo, 2, Text003, true, ExcelBufferTmp."Cell Type"::Text, true);
        for i := 3 to 8 do
            EnterCell(RowNo, i, '', true, ExcelBufferTmp."Cell Type"::Text, true);
        for i := 9 to 17 do
            EnterCell(RowNo, i, GetListValue(LineList, i), true, ExcelBufferTmp."Cell Type"::Number, true);

        ExcelBufferTmp.WriteSheet(Text001, CompanyName, UserId);
        ExcelBufferTmp.CloseBook;
        ExcelBufferTmp.OpenExcel;
    end;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; IsBorder: Boolean)
    begin
        ExcelBufferTmp.Init();
        ExcelBufferTmp.Validate("Row No.", RowNo);
        ExcelBufferTmp.Validate("Column No.", ColumnNo);
        ExcelBufferTmp."Cell Value as Text" := CellValue;
        ExcelBufferTmp.Formula := '';
        ExcelBufferTmp.Bold := Bold;
        ExcelBufferTmp."Cell Type" := CellType;
        if IsBorder then
            ExcelBufferTmp.SetBorder(true, true, true, true, false, "Border Style"::Thin);
        ExcelBufferTmp.Insert();
    end;

    local procedure GetListValue(LineList: Dictionary of [Integer, Decimal]; KeyValue: Integer) ValueText: Text
    begin
        ValueText := '';
        if LineList.ContainsKey(KeyValue) then
            ValueText := Format(LineList.Get(KeyValue));
    end;

    local procedure GetListValue(LineList: Dictionary of [Integer, Text]; KeyValue: Integer) ValueText: Text
    begin
        ValueText := '';
        if LineList.ContainsKey(KeyValue) then
            ValueText := LineList.Get(KeyValue);
    end;

    local procedure SetListValue(var LineList: Dictionary of [Integer, Decimal]; KeyValue: Integer; ValueDec: Decimal)
    var
        NewValue: Decimal;
    begin
        NewValue := ValueDec;
        if LineList.ContainsKey(KeyValue) then begin
            NewValue += LineList.Get(KeyValue);
            LineList.Remove(KeyValue);
        end;
        LineList.Add(KeyValue, NewValue);
    end;

    local procedure SetListValue(var LineList: Dictionary of [Integer, Text]; KeyValue: Integer; ValueText: Text)
    begin
        if LineList.ContainsKey(KeyValue) then
            LineList.Set(KeyValue, ValueText)
        else
            LineList.Add(KeyValue, ValueText);
    end;

    local procedure SetListValue(var LineList: Dictionary of [Integer, Text]; KeyValue: Integer; ValueDec: Decimal)
    begin
        SetListValue(LineList, KeyValue, FormatDecimal(ValueDec, 2));
    end;

    local procedure IsEmptyCollection(var ColsCollection: Dictionary of [Integer, Text]): Boolean
    var
        Values: List of [Text];
        El: Text;
        ValueDec: Decimal;
    begin
        Values := ColsCollection.Values();
        foreach El in Values do begin
            if Evaluate(ValueDec, El) and (ValueDec <> 0) then
                exit(false);
        end;
        exit(true);
    end;

    local procedure FormatDecimal(ValueDec: Decimal; Precision: Integer): Text
    begin
        exit(ConvertStr(StdRepMgt.FormatReportValue(ValueDec, Precision), ' ', ' ')); // special space to white space
    end;
}