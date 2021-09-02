report 70201 "Fin Operation Import"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(FileName; FileName)
                    {
                        ApplicationArea = All;
                        Caption = 'File Name';

                        trigger OnAssistEdit()
                        begin
                            ServerFileName := FileManagement.UploadFile(Text031, FileName);
                            FileName := FileManagement.GetFileName(ServerFileName);
                            SheetName := '';
                            SheetName := ExcelBuf.SelectSheetsName(ServerFileName);
                        end;
                    }


                }
            }
        }

    }

    var
        FileName, SheetName, ServerFileName : text;
        ExcelBuf: Record "Excel Buffer" temporary;
        FileManagement: Codeunit "File Management";
        Text031: Label 'Import from File';
        Err_fname: Label 'Please select a file to download!';
        Err_sname: label 'The Excel sheet must be specified!';
        DimCode: array[8] of Code[20];
        genJnl: Record "Gen. Journal Line";
        GenJournalLine_: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;


    trigger OnPreReport()
    var
        i: Integer;
        LastRow: integer;
        LastColumn: Integer;
        txt: Text[1024];
        Vendor: Record Vendor;
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        FixedAsset: Record "Fixed Asset";
        dimMgtext: Codeunit "Dimension Management (Ext)";
        dimMgt: Codeunit DimensionManagement;
        salesSetup: record "Sales & Receivables Setup";
        GLSetup: Record "General Ledger Setup";

    begin
        salesSetup.get;
        GLSetup.get;
        IF FileName = '' THEN
            ERROR(Err_fname);
        if SheetName = '' then
            error(Err_sname);


        ExcelBuf.RESET;
        ExcelBuf.DELETEALL;

        ExcelBuf.OpenBook(ServerFileName, SheetName);
        ExcelBuf.ReadSheet;
        ExcelBuf.FindLast();
        LastRow := ExcelBuf."Row No.";
        LastColumn := ExcelBuf."Column No.";
        //DimCode[8]:=getvalue()
        for i := 2 to LastRow do begin
            evaluate(txt, getvalue(i, 1));
            if txt <> '' then begin
                IF Customer.GET(txt) THEN BEGIN
                    GenJnl."Account Type" := GenJnl."Account Type"::Customer;
                    GenJnl.VALIDATE("Account No.", Txt);
                END ELSE
                    IF Vendor.GET(Txt) THEN BEGIN
                        GenJnl."Account Type" := GenJnl."Account Type"::Vendor;
                        GenJnl.VALIDATE("Account No.", Txt);
                    END ELSE
                        IF GLAccount.GET(Txt) THEN BEGIN
                            GenJnl."Account Type" := GenJnl."Account Type"::"G/L Account";
                            GenJnl.VALIDATE("Account No.", Txt);
                        END ELSE
                            // MC IK 20121005 >>
                            IF BankAccount.GET(Txt) THEN BEGIN
                                GenJnl."Account Type" := GenJnl."Account Type"::"Bank Account";
                                GenJnl.VALIDATE("Account No.", Txt);
                            END ELSE
                                IF FixedAsset.GET(Txt) THEN BEGIN
                                    GenJnl."Account Type" := GenJnl."Account Type"::"Fixed Asset";
                                    GenJnl.VALIDATE("Account No.", Txt);
                                END
                                else begin
                                    genJnl."Account No." := '';
                                    Error('Счет %1 не найден', txt);
                                end;
            end;
            /////////////////////////
            if not evaluate(genJnl."Posting Date", getvalue(i, 2))
            then begin
                txt := getvalue(i, 2);
                txt := StrSubstNo('%1-%2-%3', CopyStr(txt, 7, 4), CopyStr(txt, 4, 2), CopyStr(txt, 1, 2));
                evaluate(genJnl."Posting Date", txt);
            end;

            genJnl.Validate("Posting Date");
            evaluate(genJnl."Document No.", getvalue(i, 3));
            genJnl.Validate("Document No.");
            evaluate(genJnl.Description, getvalue(i, 4));
            genJnl.Validate(Description);

            evaluate(txt, getvalue(i, 5));
            if txt <> '' then begin
                IF Customer.GET(Txt) THEN BEGIN
                    genJnl."Bal. Account Type" := genJnl."Account Type"::Customer;
                    genJnl.VALIDATE("Bal. Account No.", Txt);
                END ELSE
                    IF Vendor.GET(Txt) THEN BEGIN
                        genJnl."Bal. Account Type" := genJnl."Account Type"::Vendor;
                        genJnl.VALIDATE("Bal. Account No.", Txt);
                    END ELSE
                        IF GLAccount.GET(Txt) THEN BEGIN
                            genJnl."Bal. Account Type" := genJnl."Account Type"::"G/L Account";
                            genJnl.VALIDATE("Bal. Account No.", Txt);
                        END ELSE
                            // MC IK 20121005 >>
                            IF BankAccount.GET(Txt) THEN BEGIN
                                genJnl."Bal. Account Type" := genJnl."Account Type"::"Bank Account";
                                genJnl.VALIDATE("Bal. Account No.", Txt);
                            END ELSE
                                IF FixedAsset.GET(Txt) THEN BEGIN
                                    genJnl."Bal. Account Type" := genJnl."Account Type"::"Fixed Asset";
                                    genJnl.VALIDATE("Bal. Account No.");
                                END
                                else begin
                                    genJnl."Account No." := '';
                                    Error('Балансовый счет %1 не найден', txt);
                                end;
            end;
            evaluate(genJnl.Amount, getvalue(i, 6));
            genJnl.Validate(Amount);
            if evaluate(genJnl.Correction, getvalue(i, 7)) then
                genJnl.Validate(Correction);
            evaluate(genJnl."External Document No.", getvalue(i, 8));
            genJnl.Validate("External Document No.");
            evaluate(txt, getvalue(i, 9));
            if txt <> '' then
                dimMgtext.valDimValueWithUpdGlobalDim(GLSetup."Shortcut Dimension 1 Code", txt, genJnl."Dimension Set ID", genJnl."Shortcut Dimension 1 Code", genJnl."Shortcut Dimension 2 Code");

            evaluate(txt, getvalue(i, 10));
            if txt <> '' then
                dimMgtext.valDimValueWithUpdGlobalDim(GLSetup."Shortcut Dimension 2 Code", txt, genJnl."Dimension Set ID", genJnl."Shortcut Dimension 1 Code", genJnl."Shortcut Dimension 2 Code");

            evaluate(txt, getvalue(i, 11));
            if txt <> '' then
                dimMgtext.valDimValueWithUpdGlobalDim(GLSetup."Shortcut Dimension 3 Code", txt, genJnl."Dimension Set ID", genJnl."Shortcut Dimension 1 Code", genJnl."Shortcut Dimension 2 Code");

            evaluate(txt, getvalue(i, 12));
            if txt <> '' then
                dimMgtext.valDimValueWithUpdGlobalDim(GLSetup."Shortcut Dimension 5 Code", txt, genJnl."Dimension Set ID", genJnl."Shortcut Dimension 1 Code", genJnl."Shortcut Dimension 2 Code");
            evaluate(txt, getvalue(i, 13));
            if txt <> '' then
                dimMgtext.valDimValueWithUpdGlobalDim(GLSetup."Shortcut Dimension 7 Code", txt, genJnl."Dimension Set ID", genJnl."Shortcut Dimension 1 Code", genJnl."Shortcut Dimension 2 Code");



            //-------------
            GenJournalLine.Reset();
            GenJournalLine.SETRANGE("Journal Template Name", GenJournalLine_."Journal Template Name");
            GenJournalLine.SETRANGE("Journal Batch Name", GenJournalLine_."Journal Batch Name");
            IF GenJournalLine.FINDLAST THEN
                LineNo := GenJournalLine."Line No." + 10000
            ELSE
                LineNo := LineNo + 10000;

            genJnl."Journal Template Name" := GenJournalLine_."Journal Template Name";
            GenJnl."Journal Batch Name" := GenJournalLine_."Journal Batch Name";
            GenJnl."Line No." := LineNo;
            GenJnl."Source Code" := GenJournalTemplate."Source Code";
            genJnl.Insert();



        end;

    end;

    procedure GetParameter(Rec: Record "Gen. Journal Line")
    var
        myInt: Integer;
    begin

        GenJournalLine_ := Rec;
        GenJournalTemplate.GET(GenJournalLine_."Journal Template Name");
    end;

    local procedure getvalue(Row: integer; Col: Integer): Text
    var

    begin
        if ExcelBuf.Get(Row, Col) then begin
            if uppercase(ExcelBuf."Cell Value as Text") = 'ДА'
            then
                exit('true');
            if uppercase(ExcelBuf."Cell Value as Text") = 'НЕТ'
            then
                exit('false');
            exit(ExcelBuf."Cell Value as Text");
        end;
        exit('');
    end;
}













// GenJournalLine: Record "Gen. Journal Line";
//         GenJournalLine_: Record "Gen. Journal Line";
//         LineNo: Integer;
//         Vendor: Record Vendor;
//         Customer: Record Customer;
//         GLAccount: Record "G/L Account";
//         JournalLineDimension: Record "Dimension Set Entry";
//         GeneralLedgerSetup: Record "General Ledger Setup";
//         JournalTemplateName: Code[20];
//         JournalBatchName: Code[20];
//         DimCode: array[8] of Code[20];
//         Dimension: Record Dimension;
//         DimensionValue: Record "Dimension Value";
//         BankAccount: Record "Bank Account";
//         FixedAsset: Record "Fixed Asset";
//         GenJournalTemplate: Record "Gen. Journal Template";
//         i: Integer;
//         LocManagement: Codeunit "Localisation Management";
//         genJnl:Record "Gen. Journal Line";
//         //------------------------------------------------

//         Text001: Label 'Измерение %1 не найдено.';
//         Text002: Label 'Значение измерения %1 не соответствует коду измерения %2! Проверьте правильность заполнения текстового файла.';
