report 70003 "Excel Account Invoices"
{
    // UsageCategory = Tasks;
    // ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(GLE; "G/L Entry")
        {
            DataItemTableView = SORTING("G/L Account No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date");
            RequestFilterFields = "G/L Account No.", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code", "Debit Amount", "Credit Amount", Reversed;
            trigger OnPreDataItem()
            begin

                IF GETFILTER("G/L Account No.") = '' THEN
                    ERROR('Фильтр по Фин. Счету не указан!');

                RowNo := 1;

                AddCell(RowNo, 1, 'Дата Учета', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 2, 'Тип Документа', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 3, 'Номер Документа', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 4, 'Пост/Клиент', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 5, 'Номер Счета ГК', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 6, 'Описание', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 7, 'Сумма', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 8, 'COST PLACE', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 9, 'COST CODE', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 10, 'Номер транзакции', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                RowNo += 1;

                VLE.SETCURRENTKEY("Document No.");
                DVLE.SETCURRENTKEY("Vendor Ledger Entry No.");
                //GLE.SETFILTER("Debit Amount",'<>0');
                SETRANGE(Reversed, FALSE);
                SETRANGE("Document Type", "Document Type"::Invoice);
            end;

            trigger OnAfterGetRecord()
            begin

                AddCell(RowNo, 1, FORMAT("Posting Date"), TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 2, FORMAT("Document Type"), TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 3, "Document No.", TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 4, "Source No.", TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 5, "G/L Account No.", TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 6, Description, TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 7, FORMAT(Amount, 0, 1), TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 8, "Global Dimension 1 Code", TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 9, "Global Dimension 2 Code", TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 10, FORMAT("Transaction No.", 0, 1), TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                RowNo += 1;

                //VLE.SETRANGE("Posting Date","Posting Date");
                VLE.SETRANGE("Document No.", "Document No.");
                IF VLE.FINDSET THEN BEGIN
                    DVLE.SETRANGE("Vendor Ledger Entry No.", VLE."Entry No.");
                    DVLE.SETRANGE("Entry Type", DVLE."Entry Type"::Application);
                    DVLE.SETRANGE(Unapplied, FALSE);
                    IF DVLE.FINDSET THEN
                        REPEAT
                            if DVLE."Vendor Ledger Entry No." = DVLE."Applied Vend. Ledger Entry No." then begin
                                DVLEapp.reset;
                                DVLEapp.SetRange("Applied Vend. Ledger Entry No.", DVLE."Applied Vend. Ledger Entry No.");
                                DVLEapp.SetFilter("Entry No.", '<>%1', DVLE."Vendor Ledger Entry No.");
                                if DVLEapp.FindFirst() then
                                    DVLE."Applied Vend. Ledger Entry No." := DVLEapp."Vendor Ledger Entry No.";
                            end;
                            DVLEt := DVLE;
                            IF DVLEt.INSERT THEN;
                            IF VLE.GET(DVLEt."Applied Vend. Ledger Entry No.") THEN BEGIN
                                Vend.GET(VLE."Vendor No.");
                                AddCell(RowNo, 1, FORMAT(VLE."Posting Date"), FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                AddCell(RowNo, 2, FORMAT(VLE."Document Type"), FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                AddCell(RowNo, 3, VLE."Document No.", FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                AddCell(RowNo, 4, VLE."Vendor No.", FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                AddCell(RowNo, 5, Vend."Full Name", FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                AddCell(RowNo, 7, FORMAT(DVLEt.Amount, 0, 1), FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                AddCell(RowNo, 8, VLE."Global Dimension 1 Code", FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                AddCell(RowNo, 9, VLE."Global Dimension 2 Code", FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                AddCell(RowNo, 10, FORMAT(VLE."Transaction No.", 0, 1), FALSE, TRUE, EB."Cell Type"::Text, FALSE);
                                RowNo += 1;
                            END;
                        UNTIL DVLE.NEXT = 0;
                END;


            end;

            trigger OnPostDataItem()
            begin

                RowNo += 3;
                AddCell(RowNo, 1, 'Поставщик Но.', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 2, 'Поставщик Название', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 3, 'Дата платежа', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 4, 'Номер П/П', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                AddCell(RowNo, 5, 'Сумма П/П', TRUE, FALSE, EB."Cell Type"::Text, FALSE);
                RowNo += 1;

                IF DVLEt.FINDSET THEN
                    REPEAT
                        IF VLE.GET(DVLEt."Applied Vend. Ledger Entry No.") THEN BEGIN
                            Vend.GET(VLE."Vendor No.");
                            AddCell(RowNo, 1, VLE."Vendor No.", FALSE, FALSE, EB."Cell Type"::Text, FALSE);
                            AddCell(RowNo, 2, Vend."Full Name", FALSE, FALSE, EB."Cell Type"::Text, FALSE);
                            AddCell(RowNo, 3, FORMAT(VLE."Posting Date"), FALSE, FALSE, EB."Cell Type"::Text, FALSE);
                            AddCell(RowNo, 4, VLE."Document No.", FALSE, FALSE, EB."Cell Type"::Text, FALSE);
                            AddCell(RowNo, 5, FORMAT(DVLEt.Amount, 0, 1), FALSE, FALSE, EB."Cell Type"::Text, FALSE);
                            RowNo += 1;
                        END;
                    UNTIL DVLEt.NEXT = 0;
            end;
        }
    }
    trigger OnPostReport()
    var
        FileName: text;
        FileMgt: Codeunit "File Management";
    begin
        FileName := FileMgt.ServerTempFileName('xlsx');
        EB.CreateBook(FileName, 'Sheet1');
        EB.WriteSheet('', CompanyName, UserId);
        EB.CloseBook();
        EB.OpenExcel();
    end;



    var
        RowNo: Integer;
        EB: Record "Excel Buffer Mod" temporary;
        VLE: Record "Vendor Ledger Entry";
        DVLE: Record "Detailed Vendor Ledg. Entry";
        DVLEapp: Record "Detailed Vendor Ledg. Entry";
        DVLEt: Record "Detailed Vendor Ledg. Entry" temporary;
        Vend: Record Vendor;

    local procedure AddCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; Italic: boolean; CellType: Integer; IsBorder: Boolean)
    begin
        EB.Init();
        EB.Validate("Row No.", RowNo);
        EB.Validate("Column No.", ColumnNo);
        EB."Cell Value as Text" := CellValue;
        EB.Formula := '';
        EB.Bold := Bold;
        EB.Italic := Italic;
        EB."Cell Type" := CellType;
        if IsBorder then
            EB.SetBorder(true, true, true, true, false, "Border Style"::Thick);
        if not EB.Modify() then
            EB.Insert();
    end;
}