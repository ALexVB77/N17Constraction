report 50122 "Import General Journal Lines"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    ShowCaption = false;
                    field(JournalTemplateName; JournalTemplateName)
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Template Name';
                        TableRelation = "Gen. Journal Template";
                    }
                    field(JournalBatchName; JournalBatchName)
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Batch Name';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenJournalBatch: Record "Gen. Journal Batch";
                        begin
                            GenJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
                            if page.RunModal(0, GenJournalBatch) = Action::LookupOK then
                                JournalBatchName := GenJournalBatch.Name;
                        end;
                    }
                }
            }
        }
    }

    var
        ServerFileName: Text;
        SheetName: Text;
        ExcelBuffer: Record "Excel Buffer Mod" temporary;
        TotalColumns: Integer;
        TotalRows: Integer;
        RowNo: Integer;
        GenlJournalLine: Record "Gen. Journal Line";
        JournalTemplateName: Text;
        JournalBatchName: Text;
        LineNo: Integer;
        DimMgtExt: Codeunit "Dimension Management (Ext)";
        SalesSetup: Record "Sales & Receivables Setup";
        DimSetEntry: Record "Dimension Set Entry";

    trigger OnPreReport()
    var
        FileManagement: Codeunit "File Management";
        FileNameText: Label 'Import General Journal Line';
        ExcelExtText: Label '*.xlsx';
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

        SalesSetup.Get();
        SalesSetup.TestField("Cost Place Dimension");
        SalesSetup.TestField("Taxable Period Dimension");
        SalesSetup.TestField("Tax Acc. View Dimension");
        SalesSetup.TestField("Tax Acc. Object Dimension");

        for RowNo := 3 to TotalRows do begin
            LineNo := (RowNo - 2 + 10000);
            if not GenlJournalLine.Get(JournalTemplateName, JournalBatchName, LineNo) then begin
                GenlJournalLine.Init();
                GenlJournalLine.Validate("Journal Template Name", JournalTemplateName);
                GenlJournalLine.Validate("Journal Batch Name", JournalBatchName);
                GenlJournalLine.Validate("Line No.", LineNo);
                GenlJournalLine.Validate("Document Type", Enum::"Gen. Journal Document Type".FromInteger((GetDocTypeAtInteger(RowNo, 2))));
                GenlJournalLine.Validate("Posting Date", GetValueAtDate(RowNo, 3));
                GenlJournalLine.Validate("Document No.", GetValueAtCell(RowNo, 4));
                GenlJournalLine.Validate("Account Type", Enum::"Gen. Journal Account Type".FromInteger(GetAccTypeAtInteger(RowNo, 5)));
                GenlJournalLine.Validate("Posting Group", GetValueAtCell(RowNo, 6));
                GenlJournalLine.Validate("Account No.", GetValueAtCell(RowNo, 7));
                GenlJournalLine.Validate("Bal. Account No.", GetValueAtCell(RowNo, 8));
                GenlJournalLine.Validate("Source Type", Enum::"Gen. Journal Source Type".FromInteger(GetSrcTypeAtInteger(RowNo, 9)));
                GenlJournalLine.Validate("Source No.", GetValueAtCell(RowNo, 10));
                GenlJournalLine.Validate("Depreciation Book Code", GetValueAtCell(RowNo, 11));
                GenlJournalLine.Validate("Agreement No.", GetValueAtCell(RowNo, 12));
                GenlJournalLine.Validate("Amount (LCY)", GetValueAtDecimal(RowNo, 13));
                GenlJournalLine.Validate(Description, GetValueAtCell(RowNo, 14));
                if ((SalesSetup."Cost Place Dimension" <> '') and (GetValueAtCell(RowNo, 15) <> '')) then
                    DimMgtExt.valDimValueWithUpdGlobalDim(SalesSetup."Cost Place Dimension",
                                                          GetValueAtCell(RowNo, 15),
                                                          GenlJournalLine."Dimension Set ID",
                                                          GenlJournalLine."Shortcut Dimension 1 Code",
                                                          GenlJournalLine."Shortcut Dimension 2 Code");
                GenlJournalLine.Validate("Vendor VAT Invoice Date", GetValueAtDate(RowNo, 16));
                GenlJournalLine.Validate(Amount, GetValueAtDecimal(RowNo, 17));
                GenlJournalLine.Validate("Debit Amount", GetValueAtDecimal(RowNo, 18));
                GenlJournalLine.Validate("Credit Amount", GetValueAtDecimal(RowNo, 19));
                GenlJournalLine.Validate("Debit Amount (LCY)", GetValueAtDecimal(RowNo, 20));
                GenlJournalLine.Validate("Credit Amount (LCY)", GetValueAtDecimal(RowNo, 21));
                GenlJournalLine.Validate("Bal. Account Type", Enum::"Gen. Journal Account Type".FromInteger(GetBalAccTypeAtInteger(RowNo, 22)));
                GenlJournalLine.Validate("Bal. Gen. Posting Type", Enum::"General Posting Type".FromInteger(GetBalGenPostingTypeAtInteger(RowNo, 23)));
                GenlJournalLine.Validate("Bal. Gen. Bus. Posting Group", GetValueAtCell(RowNo, 24));
                GenlJournalLine.Validate("Bal. Gen. Prod. Posting Group", GetValueAtCell(RowNo, 25));
                GenlJournalLine.Validate("Vendor VAT Invoice No.", GetValueAtCell(RowNo, 26));
                GenlJournalLine.Validate("Bal. VAT Bus. Posting Group", GetValueAtCell(RowNo, 27));
                GenlJournalLine.Validate("Bal. VAT Prod. Posting Group", GetValueAtCell(RowNo, 28));
                if ((SalesSetup."Taxable Period Dimension" <> '') and (GetValueAtCell(RowNo, 29) <> '')) then
                    DimMgtExt.valDimValueWithUpdGlobalDim(SalesSetup."Taxable Period Dimension",
                                                          GetValueAtCell(RowNo, 29),
                                                          GenlJournalLine."Dimension Set ID",
                                                          GenlJournalLine."Shortcut Dimension 1 Code",
                                                          GenlJournalLine."Shortcut Dimension 2 Code");
                if ((SalesSetup."Tax Acc. View Dimension" <> '') and (GetValueAtCell(RowNo, 30) <> '')) then
                    DimMgtExt.valDimValueWithUpdGlobalDim(SalesSetup."Tax Acc. View Dimension",
                                                          GetValueAtCell(RowNo, 30),
                                                          GenlJournalLine."Dimension Set ID",
                                                          GenlJournalLine."Shortcut Dimension 1 Code",
                                                          GenlJournalLine."Shortcut Dimension 2 Code");
                if ((SalesSetup."Tax Acc. Object Dimension" <> '') and (GetValueAtCell(RowNo, 31) <> '')) then
                    DimMgtExt.valDimValueWithUpdGlobalDim(SalesSetup."Tax Acc. Object Dimension",
                                                          GetValueAtCell(RowNo, 31),
                                                          GenlJournalLine."Dimension Set ID",
                                                          GenlJournalLine."Shortcut Dimension 1 Code",
                                                          GenlJournalLine."Shortcut Dimension 2 Code");
                GenlJournalLine.Insert(true);
            end;
            ;
        end;
    end;

    local procedure GetLastRowAndColumn()
    begin
        ExcelBuffer.SetRange("Row No.", 1);
        TotalColumns := ExcelBuffer.Count;

        ExcelBuffer.Reset();
        if ExcelBuffer.FindLast() then
            TotalRows := ExcelBuffer."Row No.";
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            exit(ExcelBuffer."Cell Value as Text");
    end;

    local procedure GetValueAtDate(RowNo: Integer; ColNo: Integer) ReturnValue: Date
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            Evaluate(ReturnValue, ExcelBuffer."Cell Value as Text");
        exit(ReturnValue);
    end;

    local procedure GetValueAtDecimal(RowNo: Integer; ColNo: Integer) ReturnValue: Decimal
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            Evaluate(ReturnValue, ExcelBuffer."Cell Value as Text");
        exit(ReturnValue);
    end;

    local procedure GetDocTypeAtInteger(RowNo: Integer; ColNo: Integer): Integer
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            case ExcelBuffer."Cell Value as Text" of
                Format(GenlJournalLine."Document Type"::" "):
                    exit(GenlJournalLine."Document Type"::" ".AsInteger());
                Format(GenlJournalLine."Document Type"::Payment):
                    exit(GenlJournalLine."Document Type"::" ".AsInteger());
                Format(GenlJournalLine."Document Type"::Invoice):
                    exit(GenlJournalLine."Document Type"::Invoice.AsInteger());
                Format(GenlJournalLine."Document Type"::"Credit Memo"):
                    exit(GenlJournalLine."Document Type"::"Credit Memo".AsInteger());
                Format(GenlJournalLine."Document Type"::"Finance Charge Memo"):
                    exit(GenlJournalLine."Document Type"::"Finance Charge Memo".AsInteger());
                Format(GenlJournalLine."Document Type"::Reminder):
                    exit(GenlJournalLine."Document Type"::Reminder.AsInteger());
                Format(GenlJournalLine."Document Type"::Refund):
                    exit(GenlJournalLine."Document Type"::Refund.AsInteger());
            end;
    end;

    local procedure GetAccTypeAtInteger(RowNo: Integer; ColNo: Integer): Integer
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            case ExcelBuffer."Cell Value as Text" of
                Format(GenlJournalLine."Account Type"::"Bank Account"):
                    exit(GenlJournalLine."Account Type"::"Bank Account".AsInteger());
                Format(GenlJournalLine."Account Type"::Customer):
                    exit(GenlJournalLine."Account Type"::Customer.AsInteger());
                Format(GenlJournalLine."Account Type"::"Fixed Asset"):
                    exit(GenlJournalLine."Account Type"::"Fixed Asset".AsInteger());
                Format(GenlJournalLine."Account Type"::"G/L Account"):
                    exit(GenlJournalLine."Account Type"::"G/L Account".AsInteger());
                Format(GenlJournalLine."Account Type"::"IC Partner"):
                    exit(GenlJournalLine."Account Type"::"IC Partner".AsInteger());
                Format(GenlJournalLine."Account Type"::Vendor):
                    exit(GenlJournalLine."Account Type"::Vendor.AsInteger());
            end;
    end;

    local procedure GetSrcTypeAtInteger(RowNo: Integer; ColNo: Integer): Integer
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            case ExcelBuffer."Cell Value as Text" of
                Format(GenlJournalLine."Source Type"::" "):
                    exit(GenlJournalLine."Source Type"::" ".AsInteger());
                Format(GenlJournalLine."Source Type"::"Bank Account"):
                    exit(GenlJournalLine."Source Type"::"Bank Account".AsInteger());
                Format(GenlJournalLine."Source Type"::Customer):
                    exit(GenlJournalLine."Source Type"::Customer.AsInteger());
                Format(GenlJournalLine."Source Type"::Employee):
                    exit(GenlJournalLine."Source Type"::Employee.AsInteger());
                Format(GenlJournalLine."Source Type"::"Fixed Asset"):
                    exit(GenlJournalLine."Source Type"::"Fixed Asset".AsInteger());
                Format(GenlJournalLine."Source Type"::"Future Expense"):
                    exit(GenlJournalLine."Source Type"::"Future Expense".AsInteger());
                Format(GenlJournalLine."Source Type"::"IC Partner"):
                    exit(GenlJournalLine."Source Type"::"IC Partner".AsInteger());
                Format(GenlJournalLine."Source Type"::Vendor):
                    exit(GenlJournalLine."Source Type"::Vendor.AsInteger());
            end;
    end;

    local procedure GetBalAccTypeAtInteger(RowNo: Integer; ColNo: Integer): Integer
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            case ExcelBuffer."Cell Value as Text" of
                Format(GenlJournalLine."Bal. Account Type"::"Bank Account"):
                    exit(GenlJournalLine."Bal. Account Type"::"Bank Account".AsInteger());
                Format(GenlJournalLine."Bal. Account Type"::Customer):
                    exit(GenlJournalLine."Bal. Account Type"::Customer.AsInteger());
                Format(GenlJournalLine."Bal. Account Type"::"G/L Account"):
                    exit(GenlJournalLine."Bal. Account Type"::"G/L Account".AsInteger());
                Format(GenlJournalLine."Bal. Account Type"::"Fixed Asset"):
                    exit(GenlJournalLine."Bal. Account Type"::"Fixed Asset".AsInteger());
                Format(GenlJournalLine."Bal. Account Type"::"IC Partner"):
                    exit(GenlJournalLine."Bal. Account Type"::"IC Partner".AsInteger());
                Format(GenlJournalLine."Bal. Account Type"::Vendor):
                    exit(GenlJournalLine."Bal. Account Type"::Vendor.AsInteger());
            end;
    end;

    local procedure GetBalGenPostingTypeAtInteger(RowNo: Integer; ColNo: Integer): Integer
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            case ExcelBuffer."Cell Value as Text" of
                Format(GenlJournalLine."Bal. Gen. Posting Type"::" "):
                    exit(GenlJournalLine."Bal. Gen. Posting Type"::" ".AsInteger());
                Format(GenlJournalLine."Bal. Gen. Posting Type"::Purchase):
                    exit(GenlJournalLine."Bal. Gen. Posting Type"::Purchase.AsInteger());
                Format(GenlJournalLine."Bal. Gen. Posting Type"::Sale):
                    exit(GenlJournalLine."Bal. Gen. Posting Type"::Sale.AsInteger());
                Format(GenlJournalLine."Bal. Gen. Posting Type"::Settlement):
                    exit(GenlJournalLine."Bal. Gen. Posting Type"::Settlement.AsInteger());
            end;
    end;
}