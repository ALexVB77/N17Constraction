report 70000 "Payment Report"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Payment report';
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {

        dataitem(FBA; "Bank Account")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "Account Type", "No.";
            MaxIteration = 1;


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
                    Caption = 'General';

                    field(boolUnPost; boolUnPost)
                    {
                        ApplicationArea = All;
                        Caption = 'Unposted';
                    }
                    field(boolPost; boolPost)
                    {
                        ApplicationArea = All;
                        Caption = 'Posted';
                    }
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                    }
                }
            }
        }

    }
    trigger OnPreReport()
    begin

        IF (NOT boolUnPost) AND (NOT boolPost) THEN
            CurrReport.QUIT;

        UnPostStartDate := StartDate;
        UnPostEndDate := EndDate;

        PostStartDate := StartDate;
        PostEndDate := EndDate;

        //Check for Correct Dates
        IF (StartDate = 0D) OR (EndDate = 0D) THEN
            ERROR(txtFillDates);
        IF EndDate < StartDate THEN
            ERROR(txtLarger);
        txtNumberFormat := '#0' + COPYSTR(FORMAT(1.1), 2, 1) + '00';
        //"#,##0.000"

        GLSetup.GET;

    end;

    trigger OnPostReport()
    begin

        //Init App
        xlsBufTmp.CreateNewBook('PaymentReport');

        MakeWidth;

        Wind.OPEN(txtWind);

        Ps := 1;

        tUnPost.RESET;
        tUnPost.SETCURRENTKEY("Posting Date");
        tUnPost.SETRANGE("Posting Date", UnPostStartDate, UnPostEndDate);



        tPost.RESET;
        tPost.SETCURRENTKEY("Bank Account No.", "Posting Date");
        tPost.SETRANGE("Posting Date", UnPostStartDate, UnPostEndDate);

        //Shapka
        IF boolPost OR boolUnPost THEN BEGIN
            ShowGlobalHeader;

            Cnt := 0;
            tBA.RESET;
            tBA.COPYFILTERS(FBA);
            MaxCnt := tBA.COUNT;
            IF tBA.FIND('-') THEN BEGIN
                ShowHeader;
                FirstFormulaItem := 0;

                REPEAT
                    Wind.UPDATE(1, tBA.Name);
                    Cnt += 1;
                    Wind.UPDATE(2, ROUND(Cnt / MaxCnt * 10000 + 1, 1, '<'));

                    tPost.SETRANGE("Bank Account No.", tBA."No.");
                    IF boolPost THEN
                        IF tPost.FIND('-') THEN
                            REPEAT
                                ShowPostLine;
                            UNTIL tPost.NEXT = 0;

                    tBatch.RESET;
                    tBatch.SETRANGE("Bal. Account No.", tBA."No.");
                    IF tBatch.FIND('-') THEN BEGIN
                        tUnPost.SETRANGE("Journal Template Name", tBatch."Journal Template Name");
                        tUnPost.SETRANGE("Journal Batch Name", tBatch.Name);
                        tUnPost.SETRANGE("Bal. Account No.", tBA."No.");
                        IF boolUnPost THEN
                            IF tUnPost.FIND('-') THEN
                                REPEAT
                                    ShowUnPostLine;
                                UNTIL tUnPost.NEXT = 0;
                    END;

                UNTIL tBA.NEXT = 0;
                ShowFooter;
            END;
        END;
        xlsbufTmp.WriteSheet('', CompanyName, UserId);
        xlsBufTmp.CloseBook();
        xlsBufTmp.OpenExcel();
        Wind.CLOSE;

    end;

    var
        txtWind: Label 'Data #1#################### \ Progress @2@@@@@@@@@@@@';
        txtUnPost: Label 'Unpost. op.';
        txtPost: label 'Post. op.';
        txtFillDates: label 'Fill Period';
        txtLarger: label 'Start Date must be before End Date';
        txtCustomer: label 'Customer';
        txtVendor: label 'Vendor';
        txtGLAcc: label 'G/L Account';
        txtBA: label 'Bank Account';
        txtFA: label 'FA';
        UnPostStartDate: Date;
        UnPostEndDate: Date;
        PostStartDate: Date;
        PostEndDate: Date;

        tUnPost: Record "Gen. Journal Line";
        tPost: Record "Bank Account Ledger Entry";
        boolUnPost: Boolean;
        boolPost: Boolean;
        Wind: Dialog;
        Cnt: Integer;
        MaxCnt: Integer;
        Ps: Integer;
        tL: integer; //Text[30];
        OldtL: integer; //Text[30];
        txtNumberFormat: Text[30];
        tCustomer: Record Customer;
        tVendor: Record Vendor;
        tBankAcc: Record "Bank Account";
        tBA: Record "Bank Account";
        FirstFormulaItem: integer;//Text[30];
        tCustLedgEntry: Record "Cust. Ledger Entry";
        tVendLedgEntry: Record "Vendor Ledger Entry";
        txtPayment: Text[30];
        tGLAcc: Record "G/L Account";
        StartDate: Date;
        EndDate: Date;
        _BA: Record "Bank Account";
        tFA: Record "Fixed Asset";
        tBatch: Record "Gen. Journal Batch";
        GLSetup: Record "General Ledger Setup";
        DimValue: Record "Dimension Value";
        DimName1: Text[50];
        DimName2: Text[50];
        xlsBufTmp: Record "Excel Buffer Mod" temporary;
        setWidth: Boolean;
        width: Integer;
        valueIsFormula: Boolean;

    local procedure ShowBorder(Pos: Text[50]; Num: integer; W: integer)
    begin
        /*
                xlBorder := xlWorksheet.Range(Pos).Borders.Item(Num);
                xlBorder.LineStyle := 1;
                xlBorder.ColorIndex := 0;
                xlBorder.Weight := W;
        */
    end;

    local procedure AddString()
    begin
        Ps += 1;
        //tL := FORMAT(Ps);
        tl := ps;
    end;

    local procedure ShowHeader()
    var
        col: Integer;
    begin
        /*
                xlWorksheet.Range('A:A').ColumnWidth := 15;
                xlWorksheet.Range('B:B').ColumnWidth := 11;
                xlWorksheet.Range('C:C').ColumnWidth := 10;
                xlWorksheet.Range('D:D').ColumnWidth := 15;
                xlWorksheet.Range('E:E').ColumnWidth := 15;
                xlWorksheet.Range('F:F').ColumnWidth := 15;
                xlWorksheet.Range('G:G').ColumnWidth := 15;
                xlWorksheet.Range('H:H').ColumnWidth := 15;
                xlWorksheet.Range('I:I').ColumnWidth := 30.14;
                xlWorksheet.Range('J:J').ColumnWidth := 40;
                // SWC1134 DD 15.11.17 >>
                xlWorksheet.Range('K:K').ColumnWidth := 20;
                // SWC1134 DD 15.11.17 <<
                xlWorksheet.Range('L:L').ColumnWidth := 10;
                xlWorksheet.Range('M:M').ColumnWidth := 15;
                xlWorksheet.Range('N:N').ColumnWidth := 15;
                xlWorksheet.Range('O:O').ColumnWidth := 15;
                xlWorksheet.Range('P:P').ColumnWidth := 15;
                xlWorksheet.Range('Q:Q').ColumnWidth := 11;
                xlWorksheet.Range('R:R').ColumnWidth := 15;
                xlWorksheet.Range('S:S').ColumnWidth := 11;
                xlWorksheet.Range('T:T').ColumnWidth := 15;
                xlWorksheet.Range('U:U').ColumnWidth := 11;
                */



        AddString;
        setWidth := true;
        width := 15;
        col := 1;
        EnterCell(tL, col, 'Банковский счет', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Дата документа', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Дата учета', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Тип документа', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Номер документа', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Номер договора', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Тип контрагента', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Номер контрагента', true, xlsBufTmp."Cell Type"::Text, true);
        width := 40;
        col += 1;
        EnterCell(tL, col, 'Наименование контрагента', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Цель платежа', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Код причины платежа', true, xlsBufTmp."Cell Type"::Text, true);
        width := 15;
        col += 1;
        EnterCell(tL, col, 'Аванс', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Сумма', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Сумма (руб.)', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;

        width := 0;
        EnterCell(tL, col, 'Дб. (руб.)', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Кр. (руб.)', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Cost place', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Description', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Cost code', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Description', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, 'Учет', true, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        setWidth := false;

        OldtL := tL; //Запомнить для линовки
        /* 
        AddString;
        xlWorksheet.Range('A' + tL).Value := 'Банковский счет';
        xlWorksheet.Range('B' + tL).Value := 'Дата документа';
        xlWorksheet.Range('C' + tL).Value := 'Дата учета';
        xlWorksheet.Range('D' + tL).Value := 'Тип документа';
        xlWorksheet.Range('E' + tL).Value := 'Номер документа';
        xlWorksheet.Range('F' + tL).Value := 'Номер договора';
        xlWorksheet.Range('G' + tL).Value := 'Тип контрагента';
        xlWorksheet.Range('H' + tL).Value := 'Номер контрагента';
        xlWorksheet.Range('I' + tL).Value := 'Наименование контрагента';
        xlWorksheet.Range('J' + tL).Value := 'Цель платежа';
        // SWC1134 DD 15.11.17 >>
        xlWorksheet.Range('K' + tL).Value := 'Код причины платежа';
        // SWC1134 DD 15.11.17 <<
        xlWorksheet.Range('L' + tL).Value := 'Аванс';
        xlWorksheet.Range('M' + tL).Value := 'Сумма';
        xlWorksheet.Range('N' + tL).Value := 'Сумма (руб.)';
        xlWorksheet.Range('O' + tL).Value := 'Дб. (руб.)';
        xlWorksheet.Range('P' + tL).Value := 'Кр. (руб.)';
        xlWorksheet.Range('Q' + tL).Value := 'Cost place';
        xlWorksheet.Range('R' + tL).Value := 'Description';
        xlWorksheet.Range('S' + tL).Value := 'Cost code';
        xlWorksheet.Range('T' + tL).Value := 'Description';
        xlWorksheet.Range('U' + tL).Value := 'Учет';

        xlWorksheet.Range('O:P').EntireColumn.Hidden := TRUE;

        xlWorksheet.Range('A' + tL + ':U' + tL).WrapText := TRUE;
        xlWorksheet.Range('A' + tL + ':U' + tL).Font.Bold := TRUE;
        xlWorksheet.Range('A' + tL + ':U' + tL).HorizontalAlignment := -4108;
        xlWorksheet.Range('A' + tL + ':U' + tL).VerticalAlignment := -4108;

        OldtL := tL; //Запомнить для линовки

        // MC IK 20120605 >>
        xlWorksheet.Range('A' + tL + ':B' + tL).Columns.Group;
        xlWorksheet.Range('E' + tL + ':E' + tL).Columns.Group;
        xlWorksheet.Range('G' + tL + ':H' + tL).Columns.Group;
        xlWorksheet.Range('N' + tL + ':P' + tL).Columns.Group;
        xlWorksheet.Range('U' + tL + ':U' + tL).Columns.Group;
        // MC IK 20120605 <<
        */
    end;

    local procedure ShowUnPostLine()
    var
        txtAType: text[30];
        txtAName: text[250];
        col: integer;
    begin

        AddString;
        IF FirstFormulaItem = 0 THEN
            FirstFormulaItem := tL;

        txtAType := '';
        txtAName := '';
        CASE tUnPost."Account Type" OF
            tUnPost."Account Type"::Customer:
                BEGIN
                    txtAType := txtCustomer;
                    IF tCustomer.GET(tUnPost."Account No.") THEN
                        txtAName := tCustomer.Name + tCustomer."Name 2"
                    ELSE
                        txtAName := tUnPost."Account No.";
                END;
            tUnPost."Account Type"::Vendor:
                BEGIN
                    txtAType := txtVendor;
                    IF tVendor.GET(tUnPost."Account No.") THEN
                        txtAName := tVendor.Name + tVendor."Name 2"
                    ELSE
                        txtAName := tUnPost."Account No.";
                END;
            tUnPost."Account Type"::"G/L Account":
                BEGIN
                    txtAType := txtGLAcc;
                    IF tGLAcc.GET(tUnPost."Account No.") THEN
                        txtAName := tGLAcc.Name
                    ELSE
                        txtAName := tUnPost."Account No.";
                END;
            tUnPost."Account Type"::"Bank Account":
                BEGIN
                    txtAType := txtBA;
                    IF _BA.GET(tUnPost."Account No.") THEN
                        txtAName := _BA.Name
                    ELSE
                        txtAName := tUnPost."Account No.";
                END;
            tUnPost."Account Type"::"Fixed Asset":
                BEGIN
                    txtAType := txtFA;
                    IF tFA.GET(tUnPost."Account No.") THEN
                        txtAName := tFA.Description
                    ELSE
                        txtAName := tUnPost."Account No.";
                END;
        END;

        // MC IK 20120605 >>
        IF DimValue.GET(GLSetup."Global Dimension 1 Code", tUnPost."Shortcut Dimension 1 Code") THEN
            DimName1 := DimValue.Name
        ELSE
            DimName1 := '';
        IF DimValue.GET(GLSetup."Global Dimension 2 Code", tUnPost."Shortcut Dimension 2 Code") THEN
            DimName2 := DimValue.Name
        ELSE
            DimName2 := '';
        // MC IK 20120605 <<
        //SWC551 KAE 080615 KAE >>
        IF (txtAName = '') AND //(tPost."Payment Purpose" = '') AND
            (STRPOS(tPost.Description, 'Аннулирование') <> 0) THEN
            txtAName := tPost.Description;
        //SWC551 KAE 080615 KAE <<

        col += 1;
        EnterCell(tL, col, tUnPost."Bal. Account No.", false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Document Date"), false, xlsBufTmp."Cell Type"::Date, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Posting Date"), false, xlsBufTmp."Cell Type"::date, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Document Type"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Document No."), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Agreement No."), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(txtAType), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Account No."), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(txtAName), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Payment Purpose"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Reason Code"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(BoolText(tUnPost.Prepayment)), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost.Amount), false, xlsBufTmp."Cell Type"::Number, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Amount (LCY)"), false, xlsBufTmp."Cell Type"::Number, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Debit Amount (LCY)"), false, xlsBufTmp."Cell Type"::Number, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Credit Amount (LCY)"), false, xlsBufTmp."Cell Type"::Number, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Shortcut Dimension 1 Code"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(DimName1), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tUnPost."Shortcut Dimension 2 Code"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(DimName2), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(''), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        /*
        xlWorksheet.Range('M' + tL + ':N' + tL).NumberFormat := txtNumberFormat;
        xlWorksheet.Range('A' + tL + ':U' + tL).VerticalAlignment := -4160;
        xlWorksheet.Range('A' + tL + ':U' + tL).HorizontalAlignment := -4131;
        xlWorksheet.Range('M' + tL + ':P' + tL).HorizontalAlignment := -4152;
        xlWorksheet.Range('B' + tL).HorizontalAlignment := -4108;
        xlWorksheet.Range('C' + tL).HorizontalAlignment := -4108;
        xlWorksheet.Range('L' + tL).HorizontalAlignment := -4108;
        xlWorksheet.Range('U' + tL).HorizontalAlignment := -4108;

        xlWorksheet.Range('A' + tL).Value := tUnPost."Bal. Account No.";
        xlWorksheet.Range('B' + tL).Value := tUnPost."Document Date";
        xlWorksheet.Range('C' + tL).Value := tUnPost."Posting Date";
        xlWorksheet.Range('D' + tL).Value := FORMAT(tUnPost."Document Type");
        xlWorksheet.Range('E' + tL).Value := tUnPost."Document No.";
        xlWorksheet.Range('F' + tL).Value := tUnPost."Agreement No.";
        xlWorksheet.Range('G' + tL).Value := txtAType;
        xlWorksheet.Range('H' + tL).Value := tUnPost."Account No.";
        //SWC551 KAE 080615 KAE >>
        IF (txtAName = '') AND (tPost."Payment Purpose" = '') AND
            (STRPOS(tPost.Description, 'Аннулирование') <> 0) THEN
            txtAName := tPost.Description;
        //SWC551 KAE 080615 KAE <<

        xlWorksheet.Range('I' + tL).Value := txtAName;
        xlWorksheet.Range('J' + tL).Value := tUnPost."Payment Purpose";
        // SWC1134 DD 15.11.17 >>
        xlWorksheet.Range('K' + tL).Value := tUnPost."Reason Code";
        // SWC1134 DD 15.11.17 <<
        xlWorksheet.Range('L' + tL).Value := BoolText(tUnPost.Prepayment);
        xlWorksheet.Range('M' + tL).Value := tUnPost.Amount;
        xlWorksheet.Range('N' + tL).Value := tUnPost."Amount (LCY)";
        xlWorksheet.Range('O' + tL).Value := tUnPost."Debit Amount (LCY)";
        xlWorksheet.Range('P' + tL).Value := tUnPost."Credit Amount (LCY)";
        xlWorksheet.Range('Q' + tL).Value := tUnPost."Shortcut Dimension 1 Code";
        xlWorksheet.Range('S' + tL).Value := tUnPost."Shortcut Dimension 2 Code";
        xlWorksheet.Range('U' + tL).Value := '';
        // MC IK 20120605 >>
        xlWorksheet.Range('R' + tL).Value := DimName1;
        xlWorksheet.Range('T' + tL).Value := DimName2;
        // MC IK 20120605 <<

        //xlWorksheet.Range('S' + tL).Value := tUnPost."Line No.";
        //xlWorksheet.Range('T' + tL).Value := tUnPost."Journal Batch Name";
        //xlWorksheet.Range('U' + tL).Value := tUnPost."Journal Template Name";

        // MC IK 20120605 >>
        xlWorksheet.Range('A' + tL).RowHeight := 30;
        xlWorksheet.Range('J' + tL).WrapText := TRUE;
        xlWorksheet.Range('R' + tL).WrapText := TRUE;
        xlWorksheet.Range('T' + tL).WrapText := TRUE;
        // MC IK 20120605 <<
        // SWC1134 DD 15.11.17 >>
        //xlWorksheet.Range('K' + tL).WrapText := TRUE;
        // SWC1134 DD 15.11.17 <<
        */
    end;

    local procedure ShowPostLine()
    var
        txtAType: text[30];
        txtAName: text[250];
        col: integer;
    begin

        AddString;
        IF FirstFormulaItem = 0 THEN
            FirstFormulaItem := tL;

        txtAType := '';
        txtAName := '';

        IF tPost."Bank Account No." <> '' THEN
            IF tBankAcc.GET(tPost."Bank Account No.") THEN;

        //txtAType := FORMAT(tPost."Bal. Account Type");

        txtPayment := '';

        CASE tPost."Bal. Account Type" OF
            tPost."Bal. Account Type"::Customer:
                BEGIN
                    txtAType := txtCustomer;
                    IF tCustomer.GET(tPost."Bal. Account No.") THEN
                        txtAName := tCustomer.Name + tCustomer."Name 2"
                    ELSE
                        txtAName := tPost."Bal. Account No.";
                    tCustLedgEntry.RESET;
                    tCustLedgEntry.SETRANGE("Customer No.", tPost."Bal. Account No.");
                    tCustLedgEntry.SETRANGE("Transaction No.", tPost."Transaction No.");
                    IF tCustLedgEntry.FIND('-') THEN
                        txtPayment := BoolText(tCustLedgEntry.Prepayment);
                END;
            tPost."Bal. Account Type"::Vendor:
                BEGIN
                    txtAType := txtVendor;
                    IF tVendor.GET(tPost."Bal. Account No.") THEN
                        txtAName := tVendor.Name + tVendor."Name 2"
                    ELSE
                        txtAName := tPost."Bal. Account No.";
                    //tCustLedgEntry.RESET;
                    //tCustLedgEntry.SETRANGE("Customer No.",tPost."Bal. Account No.");
                    //tCustLedgEntry.SETRANGE("Transaction No.",tPost."Transaction No.");
                    //IF tCustLedgEntry.FIND('-') THEN
                    //  txtPayment := BoolText(tCustLedgEntry.Prepayment);
                    //END;
                    // MC IK 20120518 >>  èñïðàâëåí Customer íà Vendor
                    tVendLedgEntry.RESET;
                    tVendLedgEntry.SETRANGE("Vendor No.", tPost."Bal. Account No.");
                    tVendLedgEntry.SETRANGE("Transaction No.", tPost."Transaction No.");
                    IF tVendLedgEntry.FIND('-') THEN
                        txtPayment := BoolText(tVendLedgEntry.Prepayment);
                END;
            // MC IK 20120518 <<
            tPost."Bal. Account Type"::"G/L Account":
                BEGIN
                    txtAType := txtGLAcc;
                    IF tGLAcc.GET(tPost."Bal. Account No.") THEN
                        txtAName := tGLAcc.Name
                    ELSE
                        txtAName := tPost."Bal. Account No.";
                END;
            tPost."Bal. Account Type"::"Bank Account":
                BEGIN
                    txtAType := txtBA;
                    IF _BA.GET(tPost."Bal. Account No.") THEN
                        txtAName := _BA.Name
                    ELSE
                        txtAName := tPost."Bal. Account No.";
                END;
            tPost."Bal. Account Type"::"Fixed Asset":
                BEGIN
                    txtAType := txtFA;
                    IF tFA.GET(tPost."Bal. Account No.") THEN
                        txtAName := tFA.Description
                    ELSE
                        txtAName := tPost."Bal. Account No.";
                END;
        END;

        // MC IK 20120605 >>
        IF DimValue.GET(GLSetup."Global Dimension 1 Code", tPost."Global Dimension 1 Code") THEN
            DimName1 := DimValue.Name
        ELSE
            DimName1 := '';
        IF DimValue.GET(GLSetup."Global Dimension 2 Code", tPost."Global Dimension 2 Code") THEN
            DimName2 := DimValue.Name
        ELSE
            DimName2 := '';
        // MC IK 20120605 <<
        //SWC551 KAE 080615 KAE >>
        IF (txtAName = '') AND //(tPost."Payment Purpose" = '') AND
            (STRPOS(tPost.Description, 'Аннулирование') <> 0) THEN
            txtAName := tPost.Description;
        //SWC551 KAE 080615 KAE <<

        col += 1;
        EnterCell(tL, col, format(tPost."Bank Account No."), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Document Date"), false, xlsBufTmp."Cell Type"::date, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Posting Date"), false, xlsBufTmp."Cell Type"::date, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Document Type"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Document No."), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Agreement No."), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(txtAType), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Bal. Account No."), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(txtAName), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tPost.Description /*tPost."Payment Purpose"*/), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Reason Code"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(txtPayment), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(-tPost.Amount), false, xlsBufTmp."Cell Type"::Number, true);
        col += 1;
        EnterCell(tL, col, format(-tPost."Amount (LCY)"), false, xlsBufTmp."Cell Type"::Number, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Debit Amount (LCY)"), false, xlsBufTmp."Cell Type"::Number, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Credit Amount (LCY)"), false, xlsBufTmp."Cell Type"::Number, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Global Dimension 1 Code"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(DimName1), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(tPost."Global Dimension 2 Code"), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format(DimName2), false, xlsBufTmp."Cell Type"::Text, true);
        col += 1;
        EnterCell(tL, col, format('Да'), false, xlsBufTmp."Cell Type"::Text, true);
        /*
        xlWorksheet.Range('M' + tL + ':P' + tL).NumberFormat := txtNumberFormat;
        xlWorksheet.Range('A' + tL + ':U' + tL).VerticalAlignment := -4160;
        xlWorksheet.Range('A' + tL + ':U' + tL).HorizontalAlignment := -4131;
        xlWorksheet.Range('L' + tL + ':P' + tL).HorizontalAlignment := -4152;
        xlWorksheet.Range('B' + tL).HorizontalAlignment := -4108;
        xlWorksheet.Range('C' + tL).HorizontalAlignment := -4108;
        xlWorksheet.Range('L' + tL).HorizontalAlignment := -4108;
        xlWorksheet.Range('U' + tL).HorizontalAlignment := -4108;


        xlWorksheet.Range('A' + tL).Value := tPost."Bank Account No.";
        xlWorksheet.Range('B' + tL).Value := tPost."Document Date";
        xlWorksheet.Range('C' + tL).Value := tPost."Posting Date";
        xlWorksheet.Range('D' + tL).Value := FORMAT(tPost."Document Type");
        xlWorksheet.Range('E' + tL).Value := tPost."Document No.";
        xlWorksheet.Range('F' + tL).Value := tPost."Agreement No.";
        xlWorksheet.Range('G' + tL).Value := txtAType;
        xlWorksheet.Range('H' + tL).Value := tPost."Bal. Account No.";
        //SWC551 KAE 080615 KAE >>
        IF (txtAName = '') AND (tPost."Payment Purpose" = '') AND
            (STRPOS(tPost.Description, 'Àííóëèðîâàíèå') <> 0) THEN
            txtAName := tPost.Description;
        //SWC551 KAE 080615 KAE <<
        xlWorksheet.Range('I' + tL).Value := txtAName;
        xlWorksheet.Range('J' + tL).Value := tPost."Payment Purpose";
        // SWC1134 DD 15.11.17 >>
        xlWorksheet.Range('K' + tL).Value := tPost."Reason Code";
        // SWC1134 DD 15.11.17 <<
        xlWorksheet.Range('L' + tL).Value := txtPayment;
        xlWorksheet.Range('M' + tL).Value := -tPost.Amount;
        xlWorksheet.Range('N' + tL).Value := -tPost."Amount (LCY)";
        xlWorksheet.Range('O' + tL).Value := tPost."Debit Amount (LCY)";
        xlWorksheet.Range('P' + tL).Value := tPost."Credit Amount (LCY)";
        xlWorksheet.Range('Q' + tL).Value := tPost."Global Dimension 1 Code";
        xlWorksheet.Range('S' + tL).Value := tPost."Global Dimension 2 Code";
        xlWorksheet.Range('U' + tL).Value := 'Äà';
        // MC IK 20120605 >>
        xlWorksheet.Range('R' + tL).Value := DimName1;
        xlWorksheet.Range('T' + tL).Value := DimName2;
        // MC IK 20120605 <<

        xlWorksheet.Range('M' + tL + ':N' + tL).NumberFormat := txtNumberFormat;

        // MC IK 20120605 >>
        xlWorksheet.Range('A' + tL).RowHeight := 30;
        xlWorksheet.Range('J' + tL).WrapText := TRUE;
        xlWorksheet.Range('R' + tL).WrapText := TRUE;
        xlWorksheet.Range('T' + tL).WrapText := TRUE;
        // MC IK 20120605 <<
        */
    end;

    local procedure ShowFooter()

    begin
        AddString;

        EnterCell(tL, 3, format('Итого:'), true, xlsBufTmp."Cell Type"::Number, false);
        IF FirstFormulaItem <> 0 THEN BEGIN
            valueIsFormula := true;
            EnterCell(7, 13, strsubstno('=SUM(M%1:M%2)', FirstFormulaItem, ps - 1), true, xlsBufTmp."Cell Type"::Number, false);
            EnterCell(tl, 14, strsubstno('=SUM(N%1:N%2)', FirstFormulaItem, ps - 1), true, xlsBufTmp."Cell Type"::Number, false);
            EnterCell(tl, 15, strsubstno('=SUM(O%1:O%2)', FirstFormulaItem, ps - 1), true, xlsBufTmp."Cell Type"::Number, false);
            EnterCell(tl, 16, strsubstno('=SUM(P%1:P%2)', FirstFormulaItem, ps - 1), true, xlsBufTmp."Cell Type"::Number, false);
            valueIsFormula := false;
        END;

        /*
        ShowBorders('A' + OldtL + ':U' + tL);
        AddString;
        xlWorksheet.Range('C' + tL).Value := 'Èòîãî:';
        IF FirstFormulaItem <> '' THEN BEGIN
            xlWorksheet.Range('M7').Formula := '=SUM(M' + FirstFormulaItem + ':M' + FORMAT(Ps - 1) + ')';
            xlWorksheet.Range('N' + tL).Formula := '=SUM(N' + FirstFormulaItem + ':N' + FORMAT(Ps - 1) + ')';
            xlWorksheet.Range('O' + tL).Formula := '=SUM(O' + FirstFormulaItem + ':O' + FORMAT(Ps - 1) + ')';
            xlWorksheet.Range('P' + tL).Formula := '=SUM(P' + FirstFormulaItem + ':P' + FORMAT(Ps - 1) + ')';
        END;

        xlWorksheet.Range('C' + tL + ':P' + tL).Font.Bold := TRUE;
        */
    end;

    local procedure MakeWidth()
    begin
        /*
        xlWorksheet.Range('A:A').ColumnWidth := 15;
        xlWorksheet.Range('B:B').ColumnWidth := 11;
        xlWorksheet.Range('C:C').ColumnWidth := 10;
        xlWorksheet.Range('D:D').ColumnWidth := 15;
        xlWorksheet.Range('E:E').ColumnWidth := 15;
        xlWorksheet.Range('F:F').ColumnWidth := 15;
        xlWorksheet.Range('G:G').ColumnWidth := 15;
        xlWorksheet.Range('H:H').ColumnWidth := 15;
        xlWorksheet.Range('I:I').ColumnWidth := 30.14;
        xlWorksheet.Range('J:J').ColumnWidth := 40;
        // SWC1134 DD 15.11.17 >>
        xlWorksheet.Range('K:K').ColumnWidth := 20;
        // SWC1134 DD 15.11.17 <<
        xlWorksheet.Range('L:L').ColumnWidth := 10;
        xlWorksheet.Range('M:M').ColumnWidth := 15;
        xlWorksheet.Range('N:N').ColumnWidth := 15;
        xlWorksheet.Range('O:O').ColumnWidth := 15;
        xlWorksheet.Range('P:P').ColumnWidth := 15;
        xlWorksheet.Range('Q:Q').ColumnWidth := 11;
        xlWorksheet.Range('R:R').ColumnWidth := 15;
        xlWorksheet.Range('S:S').ColumnWidth := 11;
        xlWorksheet.Range('T:T').ColumnWidth := 15;
        xlWorksheet.Range('U:U').ColumnWidth := 11;
        */
    end;

    local procedure ShowGlobalHeader()

    begin
        AddString;
        EnterCell(tl, 4, format('Отчет по платежам'), true, xlsBufTmp."Cell Type"::Text, false);
        AddString;
        AddString;
        EnterCell(tl, 3, format('Тип счета'), true, xlsBufTmp."Cell Type"::Text, false);
        EnterCell(tl, 4, format(FBA.GETFILTER("Account Type")), true, xlsBufTmp."Cell Type"::Text, false);
        AddString;
        EnterCell(tl, 3, format('Номер счета'), true, xlsBufTmp."Cell Type"::Text, false);
        EnterCell(tl, 4, format(FBA.GETFILTER("No.")), true, xlsBufTmp."Cell Type"::Text, false);
        AddString;
        EnterCell(tl, 3, format('Период'), true, xlsBufTmp."Cell Type"::Text, false);
        EnterCell(tl, 4, 'с ' + FORMAT(StartDate) + ' по ' + FORMAT(EndDate), true, xlsBufTmp."Cell Type"::Text, false);
        AddString;
        /*
        AddString;
        xlWorksheet.Range('D' + tL).Value := 'Отчет по платежам';
        xlWorksheet.Range('D' + tL).Font.Size := 15;
        xlWorksheet.Range('D' + tL).Font.Bold := TRUE;
        AddString;
        AddString;
        xlWorksheet.Range('C' + tL).Value := 'Тип счета:';
        xlWorksheet.Range('C' + tL).Font.Bold := TRUE;
        xlWorksheet.Range('D' + tL).Value := FORMAT(FBA.GETFILTER("Account Type"));
        AddString;
        xlWorksheet.Range('C' + tL).Value := 'Но. счета:';
        xlWorksheet.Range('C' + tL).Font.Bold := TRUE;
        xlWorksheet.Range('D' + tL).Value := FORMAT(FBA.GETFILTER("No."));
        AddString;
        xlWorksheet.Range('C' + tL).Value := 'Период:';
        xlWorksheet.Range('C' + tL).Font.Bold := TRUE;
        xlWorksheet.Range('D' + tL).Value := 'с ' + FORMAT(StartDate) + ' по ' + FORMAT(EndDate);
        AddString;
        */
    end;

    local procedure BoolText(inBool: Boolean) ret: text[30]
    var
        txtYes: label 'Yes';
    begin
        IF inBool THEN
            EXIT(txtYes)
        ELSE
            EXIT('');
    end;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; IsBorder: Boolean)
    begin
        xlsBufTmp.Init();
        xlsBufTmp.Validate("Row No.", RowNo);
        xlsBufTmp.Validate("Column No.", ColumnNo);
        if (valueIsFormula) then begin
            xlsBufTmp.SetFormula(CellValue);
        end
        else begin
            xlsBufTmp."Cell Value as Text" := CellValue;
        end;
        xlsBufTmp.Bold := Bold;
        xlsBufTmp."Cell Type" := CellType;
        if IsBorder then
            xlsBufTmp.SetBorder(true, true, true, true, false, "Border Style"::Thin);
        xlsBufTmp.Insert();

        if (setWidth) then begin
            xlsBufTmp.SetColumnWidth(xlsBufTmp.xlColID, width);
        end;
    end;
}