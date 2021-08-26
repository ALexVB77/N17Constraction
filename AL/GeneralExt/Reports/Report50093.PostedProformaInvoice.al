report 50093 "Posted Proforma Invoice"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    //DefaultLayout = RDLC;

    //WordLayout = './Reports/Layouts/PostedProformaInvoice.docx';
    //PreviewMode = PrintLayout;
    //WordMergeDataItem = Header;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            // column(Header1; STRSUBSTNO(Text019, TitleDoc, LocMgt.Date2Text(DateNameInvoice))) { }
            // column(Buyer1; STRSUBSTNO(Text012, Cust."VAT Registration No.", Cust."KPP Code")) { }
            // column(Buyer2; CustomerAddr[1]) { }
            // column(Buyer3; CustomerAddr[2]) { }
            // column(Buyer4; CustomerAddr[3]) { }
            // column(Buyer5; CustomerAddr[4]) { }
            // column(Buyer6; CustomerAddr[5]) { }

            // column(Seller1; STRSUBSTNO(Text012, CompanyInfo."VAT Registration No.", CompanyInfo."KPP Code")) { }
            // column(Seller2; CompanyAddress[1]) { }
            // column(Seller3; CompanyAddress[2]) { }
            // column(Seller4; CompanyAddress[3]) { }
            // column(Seller5; CompanyAddress[4]) { }
            // column(Seller6; CompanyAddress[5]) { }

            dataitem("CopyCycle"; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem("Company Information"; "Company Information")
                {
                    DataItemTableView = sorting("Primary Key");
                    MaxIteration = 1;

                }
                dataitem("CopyHeader"; Integer)
                {
                    DataItemTableView = sorting(Number);
                    trigger OnPreDataItem()
                    begin

                        IF (CustomerAddr[2] = '') AND (CompanyAddress[2] = '') THEN
                            SETRANGE(Number, 1, 1)
                        ELSE
                            IF (CustomerAddr[3] = '') AND (CompanyAddress[3] = '') THEN
                                SETRANGE(Number, 1, 2)
                            ELSE
                                IF (CustomerAddr[4] = '') AND (CompanyAddress[4] = '') THEN
                                    SETRANGE(Number, 1, 3)
                                ELSE
                                    IF (CustomerAddr[5] = '') AND (CompanyAddress[5] = '') THEN
                                        SETRANGE(Number, 1, 4)
                                    ELSE
                                        IF (CustomerAddr[6] = '') AND (CompanyAddress[6] = '') THEN
                                            SETRANGE(Number, 1, 5)
                                        ELSE
                                            IF (CustomerAddr[7] = '') AND (CompanyAddress[7] = '') THEN
                                                SETRANGE(Number, 1, 6)
                                            ELSE
                                                IF (CustomerAddr[8] = '') AND (CompanyAddress[8] = '') THEN
                                                    SETRANGE(Number, 1, 7)
                                                ELSE
                                                    SETRANGE(Number, 1, 8);

                        SETRANGE(Number, 1);
                        SalesLine1.SetRange("Document No.", Header."No.");
                    end;


                }
                dataitem("CopyLine"; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = FILTER(1 ..));

                    trigger OnPreDataItem()
                    begin

                        LinesWereFinished := FALSE;
                        OrderedNo := 0;
                        IF (CurrentCurrencyAmountPrice IN
                           [CurrentCurrencyAmountPrice::Currency, CurrentCurrencyAmountPrice::"LCY + Currency"]) AND
                           (Header."Currency Code" <> '')
                        THEN
                            Currency.GET(Header."Currency Code")
                        ELSE
                            Currency.InitRoundingPrecision;
                        SalesLine1.SetRange("No.", Header."No.");
                    end;

                    trigger OnAfterGetRecord()
                    var

                        CheckSalesLine: Record "Sales Invoice Line";
                        SL2: Record "Sales Invoice Line";
                    begin

                        // IF Number = 1 THEN BEGIN
                        //     IF NOT SalesLine1.FIND('-') THEN
                        //         CurrReport.BREAK;
                        // END ELSE
                        //     IF SalesLine1.NEXT(1) = 0 THEN
                        //         CurrReport.BREAK;
                        SL2.SetRange("Document No.", Header."No.");
                        if SL2.FindSet() then begin
                            repeat
                                COPYARRAY(LastTotalAmount, TotalAmount, 1);

                                IF Header."Prices Including VAT" THEN
                                    LastTotalAmount[1] := TotalAmount[3];

                                WITH SL2 DO
                                    IF Type <> Type::" " THEN BEGIN
                                        IF Quantity = 0 THEN
                                            CurrReport.SKIP;
                                        "OrderedNo" := "OrderedNo" + 1;
                                        ItemLineNo := "OrderedNo";
                                        IF CurrentCurrencyAmountPrice = CurrentCurrencyAmountPrice::LCY THEN BEGIN
                                            Amount := "Amount (LCY)";
                                            "Amount Including VAT" := "Amount Including VAT (LCY)";
                                        END;
                                        IncrAmount(SL2);
                                        IF Header."Prices Including VAT" THEN BEGIN
                                            Amount := "Amount Including VAT";
                                            "Amount (LCY)" := "Amount Including VAT (LCY)";
                                        END;
                                        UnitPrice :=
                                          ROUND(Amount / Quantity, Currency."Unit-Amount Rounding Precision");
                                        UnitPriceLCY :=
                                          ROUND("Amount (LCY)" / Quantity, Currency."Unit-Amount Rounding Precision");
                                    END ELSE BEGIN
                                        IF CheckSalesLine.GET("Document No.", "Attached to Line No.") THEN
                                            IF CheckSalesLine.Quantity = 0 THEN
                                                CurrReport.SKIP;

                                        "No." := '';
                                        ItemLineNo := 0;
                                    END;

                                // SWC1070 DD 06.07.17 >>
                                IF ExportExcel THEN BEGIN
                                    RowNo += 1;
                                    EB.NewRow();
                                    //IF RowNo <> ExcelTemplates."Top Margin" THEN!!!!!!!!!!!
                                    //EB.CopyRow(ExcelTemplates."Top Margin");!!!!!!!!!!

                                    AddCell(RowNo, 3, SL2.Description + ' ' + SL2."Description 2", FALSE, EB."Cell Type"::Text, FALSE, 9);
                                    IF SL2.Type = SL2.Type::" " THEN BEGIN
                                        AddCell(RowNo, 2, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                        AddCell(RowNo, 5, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                        AddCell(RowNo, 6, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                        AddCell(RowNo, 7, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                        AddCell(RowNo, 8, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                    END ELSE BEGIN
                                        AddCell(RowNo, 2, FORMAT(ItemLineNo), FALSE, EB."Cell Type"::Text, FALSE, 9);
                                        AddCell(RowNo, 5, SL2."Unit of Measure", FALSE, EB."Cell Type"::Text, FALSE, 9);
                                        AddCell(RowNo, 6, FORMAT(SL2.Quantity, 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                                        AddCell(RowNo, 7, FORMAT(UnitPriceLCY, 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                                        AddCell(RowNo, 8, FORMAT(SL2."Amount (LCY)", 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                                    END;
                                END;
                            until SL2.Next() = 0;
                        end;
                        IF Number = 1 THEN BEGIN
                            //IF NOT SalesLine1.FIND('-') THEN
                            //  CurrReport.BREAK;
                            //END ELSE
                            IF SL2.NEXT = 0 THEN
                                CurrReport.BREAK;
                        end;
                    end;

                    trigger OnPostDataItem()
                    begin

                        // SWC1070 DD 06.07.17 >>
                        IF ExportExcel THEN BEGIN
                            AddCell(RowNo + 1, 7, 'Итого:', true, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 1, 8, 'Итого НДС:', True, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 1, 8, 'Всего к оплате:', true, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 1, 8, FORMAT(TotalAmount[1], 0, 1), true, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 2, 8, FORMAT(TotalAmount[2], 0, 1), true, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 3, 8, FORMAT(TotalAmount[3], 0, 1), true, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 5, 2, 'Всего оказано услуг на сумму: ' + LocMgt.Amount2Text(CurrencyForAmountWritten, TotalAmount[3])
                                          + ', в т.ч.: НДС - ' + LocMgt.Amount2Text(CurrencyForAmountWritten, TotalAmount[2]) + '.', FALSE, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 7, 2, 'Руководитель предприятия_____________________ (' +
                                RepMgt2.GetDirectorName2(TRUE, 112, 0, Header."No.", Header."Posting Date") + ')', FALSE, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 9, 2, 'Главный бухгалтер____________________________ (' +
                                CompanyInfo."Accountant Name" + ')', FALSE, EB."Cell Type"::Text, FALSE, 9);
                        END;
                        // SWC1070 DD 06.07.17 <<
                    end;

                }
                dataitem("CopyEndingOfReport"; Integer)
                {
                    DataItemTableView = sorting(Number);
                    MaxIteration = 1;
                    column(Header1; STRSUBSTNO(Text019, TitleDoc, LocMgt.Date2Text(DateNameInvoice))) { }
                    column(Buyer1; STRSUBSTNO(Text012, Cust."VAT Registration No.", Cust."KPP Code")) { }
                    column(Buyer2; CustomerAddr[1]) { }
                    column(Buyer3; CustomerAddr[2]) { }
                    column(Buyer4; CustomerAddr[3]) { }
                    column(Buyer5; CustomerAddr[4]) { }
                    column(Buyer6; CustomerAddr[5]) { }

                    column(Seller1; STRSUBSTNO(Text012, CompanyInfo."VAT Registration No.", CompanyInfo."KPP Code")) { }
                    column(Seller2; CompanyAddress[1]) { }
                    column(Seller3; CompanyAddress[2]) { }
                    column(Seller4; CompanyAddress[3]) { }
                    column(Seller5; CompanyAddress[4]) { }
                    column(Seller6; CompanyAddress[5]) { }

                }
                trigger OnPreDataitem()
                var
                begin
                    SalesLine1.SetRange("Document No.", Header."No.");
                    IF NOT SalesLine1.FIND('-') THEN
                        CurrReport.BREAK;

                    SETRANGE(Number, 1, CopiesNumber);
                end;

                trigger OnAfterGetRecord()
                begin

                    CLEAR(TotalAmount);
                    ItemLineNo := 0;

                    IF NOT (Number = 1) THEN BEGIN
                        //CurrReport.NEWPAGE;!!!!!!!!
                        //CurrReport.PAGENO := 1;!!!!!!!!
                    END;
                    NewInvoce := TRUE;
                end;

                trigger OnPostDataItem()
                begin

                    IF NOT CurrReport.PREVIEW THEN
                        PrintingCounter.RUN(Header);
                end;


            }
            // column(ColumnName; SourceFieldName)
            // {

            // }
            trigger OnPreDataItem()
            begin

                FirstStep := true;
                SalesRecSetup.get;
                SalesLine1.SetRange("Document No.", Header."No.");
            end;

            trigger OnPostDataItem()
            begin

                CompanyInfo.GET;
                // SWC833 DD 18.05.16 >>
                //AddressFormat.SetRepDate("Posting Date");
                // SWC833 DD 18.05.16 <<
                AddressFormat.Company(CompanyAddress, CompanyInfo);
                IF "Order No." <> '' THEN BEGIN
                    TitleDoc := STRSUBSTNO(Text014, "No.", "Order No.");
                    DateNameInvoice := "Order Date";
                END ELSE BEGIN
                    //TitleDoc := STRSUBSTNO(Text015,"No.","Pre-Assigned No."); //NCC002 AKAM 041011
                    TitleDoc := STRSUBSTNO(Text50001, "No."); //NCC002 AKAM 041011
                    DateNameInvoice := "Document Date";
                END;

                IF NOT FirstStep THEN BEGIN
                    //CurrReport.NEWPAGE;!!!!!!!!
                    //CurrReport.PAGENO := 1!!!!!!!!!!!!!;
                END ELSE
                    FirstStep := FALSE;
                NewInvoce := TRUE;

                IF NOT ShipmentMethod.GET("Shipment Method Code") THEN
                    ShipmentMethod.INIT;
                IF NOT PaymentTerms.GET("Payment Terms Code") THEN
                    PaymentTerms.INIT;

                Cust.GET("Bill-to Customer No.");

                AddressFormat.Customer(CustomerAddr, Cust);

                CurrentCurrencyAmountPrice := CurrencyPriceAmount;

                ExcludingDiscount := NOT ShowDiscount;

                IF NOT ("Currency Code" = '') THEN
                    TESTFIELD("Currency Factor");
                IF (CurrentCurrencyAmountPrice IN
                          [CurrentCurrencyAmountPrice::Currency, CurrentCurrencyAmountPrice::"LCY + Currency"]) AND
                   ("Currency Code" = '')
                THEN
                    CurrentCurrencyAmountPrice := CurrentCurrencyAmountPrice::LCY;

                IF DecPointCourse < 1 THEN
                    DecPointCourse := 5;

                CurrencyExchRate := '';
                IF (CurrentCurrencyAmountPrice IN [CurrentCurrencyAmountPrice::Currency, CurrentCurrencyAmountPrice::"LCY + Currency"]) THEN BEGIN
                    CurrencyCode := "Currency Code";
                    IF CurrentCurrencyAmountPrice = CurrentCurrencyAmountPrice::"LCY + Currency" THEN
                        CurrencyExchRate := FORMAT(ROUND(1 / "Currency Factor", POWER(10, 0 - DecPointCourse)),
                            0, Text000 + FORMAT(DecPointCourse + 1) + '>');
                END ELSE
                    CurrencyCode := '';

                IF "Salesperson Code" = '' THEN BEGIN
                    Manager.INIT;
                    ManagerText := PADSTR('', MAXSTRLEN(ManagerText), ' ');
                    ManagerText := Text50000; //NCC002 AKAM 041011
                END ELSE BEGIN
                    Manager.GET("Salesperson Code");

                    ManagerText := Text50000;
                END;
                AmountInclVAT := "Prices Including VAT";

                SalesLine1.RESET;
                SalesLine1.SETRANGE("Document No.", "No.");

                IF CurrentCurrencyAmountPrice = CurrentCurrencyAmountPrice::Currency THEN BEGIN
                    IF Currency.GET("Currency Code") THEN BEGIN
                        PayComment := Currency."Invoice Comment";
                        CurrencyForAmountWritten := "Currency Code";
                    END;
                END ELSE
                    CurrencyForAmountWritten := '';

                IF LogInteraction THEN
                    IF NOT CurrReport.PREVIEW THEN BEGIN
                        IF "Bill-to Contact No." <> '' THEN
                            SegManagement.LogDocument(
                              4, "No.", 0, 0, DATABASE::Contact, "Bill-to Contact No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '')
                        ELSE
                            SegManagement.LogDocument(
                              4, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '');
                    END;


                IF NOT CustAgr.GET("Sell-to Customer No.", "Agreement No.") THEN
                    CLEAR(CustAgr);

                IF ExportExcel THEN BEGIN
                    AddCell(1, 2, CompanyInfo.Name, TRUE, EB."Cell Type"::Text, FALSE, 10);
                    AddCell(3, 2, 'Адрес: ' + CompanyInfo."Post Code" + ', ' + CompanyInfo.City + ', ' + CompanyInfo.Address + ', тел.:' + CompanyInfo."Phone No.",
                              TRUE, EB."Cell Type"::Text, FALSE, 10);
                    AddCellWithBorder(6, 2, 'ИНН ' + CompanyInfo."VAT Registration No.", FALSE, EB."Cell Type"::Text, true, false, true, true, 10);
                    AddCellWithBorder(6, 4, 'КПП ' + CompanyInfo."KPP Code", FALSE, EB."Cell Type"::Text, true, false, true, true, 10);
                    AddCellWithBorder(8, 2, CompanyInfo.Name + CompanyInfo."Name 2", FALSE, EB."Cell Type"::Text, true, false, false, true, 10);
                    AddCellWithBorder(10, 2, CompanyInfo."Bank Name" + ' ' + CompanyInfo."Bank City", FALSE, EB."Cell Type"::Text, true, false, true, true, 10);
                    AddCell(12, 2, STRSUBSTNO(Text019, TitleDoc, LocMgt.Date2Text(DateNameInvoice)), TRUE, EB."Cell Type"::Text, FALSE, 14);
                    AddCell(13, 2, 'Основание: ' + CustAgr."External Agreement No.", FALSE, EB."Cell Type"::Text, FALSE, 10);
                    AddCell(15, 2, 'Плательщик:        ' + Header."Bill-to Name", FALSE, EB."Cell Type"::Text, FALSE, 10);
                    AddCellWithBorder(16, 2, STRSUBSTNO('ИНН %1, КПП %2, %3, %4, %5', Cust."VAT Registration No.", Cust."KPP Code",
                              CustomerAddr[4], CustomerAddr[3], CustomerAddr[2]), FALSE, EB."Cell Type"::Text, false, false, true, true, 10);
                    AddCellWithBorder(8, 7, CompanyInfo."Bank Corresp. Account No.", FALSE, EB."Cell Type"::Text, true, false, true, true, 10);
                    AddCellWithBorder(9, 7, CompanyInfo."Bank BIC", FALSE, EB."Cell Type"::Text, true, false, true, true, 10);
                    AddCellWithBorder(10, 7, CompanyInfo."Bank Account No.", FALSE, EB."Cell Type"::Text, true, false, true, true, 10);

                END;
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
                    field(CopiesNumber; CopiesNumber)
                    {
                        ApplicationArea = All;
                        Caption = 'Copies Number';
                    }
                    field(CurrencyPriceAmount; CurrencyPriceAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Currency';
                        trigger OnValidate()
                        begin
                            if CopiesNumber < 1 then
                                CopiesNumber := 1;
                        end;
                    }
                    field(ShowDiscount; ShowDiscount)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Discount';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = All;
                        Caption = 'Log Interaction';
                    }
                    field(ExportExcel; ExportExcel)
                    {
                        ApplicationArea = All;
                        Caption = 'Export Excel';
                        Visible = false;
                    }
                }
            }

        }
        trigger OnOpenPage()
        begin

            if CopiesNumber < 1 then
                CopiesNumber := 1;
            ExportExcel := true;
        end;

    }

    var

        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        CompanyInfo: Record "Company Information";
        Currency: Record Currency;
        Cust: Record Customer;
        Manager: Record "Salesperson/Purchaser";
        SalesLine1: Record "Sales Invoice Line";
        SalesRecSetup: Record "Sales & Receivables Setup";
        PrintingCounter: Codeunit "Sales Inv.-Printed";
        AddressFormat: Codeunit "Format Address";
        NoSeriesManagement: Codeunit "NoSeriesManagement";
        LocMgt: Codeunit "Localisation Management";
        StandRepManagement: Codeunit "Local Report Management";
        SegManagement: Codeunit SegManagement;
        DateNameInvoice: Date;
        CurrencyPriceAmount: Option "Валюте счета",Рублях,"Рублях и валюте счета";
        CurrentCurrencyAmountPrice: Option "Currency","LCY","LCY + Currency";
        ExcludingDiscount: Boolean;
        ShowDiscount: Boolean;
        AmountInclVAT: Boolean;
        LinesWereFinished: Boolean;
        NewInvoce: Boolean;
        TitleDoc: Text[100];
        CustomerAddr: array[8] of Text[90];
        CompanyAddress: array[8] of Text[90];
        PageHeader: Text[100];
        InclVAT: Text[11];
        CurrencyCode: Text[10];
        CurrencyExchRate: Text[30];
        ManagerText: Text[30];
        ReportValue: Text[30];
        TotalAmount: array[8] of Decimal;
        LastTotalAmount: array[8] of Decimal;
        AmountInvDiscount: Decimal;
        DecPointCourse: Integer;
        CopiesNumber: Integer;
        ItemLineNo: Integer;
        OrderedNo: Integer;
        CurrencyForAmountWritten: Code[10];
        FirstStep: Boolean;
        DocumentType: Option "Quote","Order","Invoice","Credit Memo","Posted Shipment","Posted Invoice","Posted Credit Memo","Return Order","Posted Return Receipt";
        QtyType: Option "General","Invoicing","Shipping";
        Ind: Option "",Quantiy,Price,Amount,AmountInclVAT,VATAmount,"VAT%","Discounts%",PriceCurrDoc,"Sales Tax Amount","GTD No.","Origin Country",ExciseAmount,"AmountInclTaxSales","AmountForLine";
        Ins: Option "",Quantity,Amount,AmouontInclVAT,VATAmount,"Sales Tax Amount",ExciseAmount,AmountInclSalesTax,AmountForLine;
        PayComment: Text[250];
        LogInteraction: Boolean;
        UnitPrice: Decimal;
        UnitPriceLCY: Decimal;
        CustAgr: Record "Customer Agreement";
        ExportExcel: Boolean;
        ExcelTemplates: Record "Excel Template";
        EB: Record "Excel Buffer Mod" temporary;
        RowNo: Integer;
        FileName: Text[250];
        RepMgt2: Codeunit "Local Report Management Ext";
        PostedProformaInvCaption: Label 'Posted Proforma Invoice';
        //---------------------

        Text000: Label '<Integer Thousand><Decimals,';
        Text001: Label 'Менеджер';
        Text003: Label 'Покупатель';
        Text004: Label 'Продавец';
        Text005: Label 'Курс';
        Text006: Label 'Сумма\РУБ';
        Text007: Label 'Скидка\%%';
        Text008: Label 'Цена\РУБ';
        Text009: Label 'Цена\';
        Text010: Label 'Сумма';
        Text011: Label 'Цена';
        Text012: Label 'ИНН %1, КПП %2';
        Text013: Label '%2. Стр. %1';
        Text014: Label 'СЧЕТ %1 ПО ЗАКАЗУ № %2';
        Text015: Label 'СЧЕТ № %1 (%2)';
        Text019: Label '%1 от %2';
        Text12400: Label 'Тел.:';
        Text12401: Label 'Факс.:';
        Text50000: Label 'Генеральный директор';
        Text50001: Label 'СЧЕТ № %1';



    trigger OnPreReport()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin

        ExportExcel := true;
        SalesLine1.SetRange("Document No.", Header."No.");

        if not CurrReport.UseRequestPage then
            CopiesNumber := 1;
        SalesSetup.Get();
        EB.DeleteAll();

        if ExportExcel then begin
            FileName := ExcelTemplates.OpenTemplate(SalesSetup."Posted Prof-Inv. Template Code");
            //EB.OpenBook(FileName, ExcelTemplates."Sheet Name");
            RowNo := 18;

        end;
    end;

    trigger OnPostReport()
    begin

        if ExportExcel then begin
            EB.SetFriendlyFilename(PostedProformaInvCaption);
            EB.UpdateBook(Filename, 'Sheet1');
            EB.WriteSheet(PostedProformaInvCaption, CompanyName, UserId);
            EB.CloseBook();
            EB.OpenExcel();
        end;
    end;

    local procedure IncrAmount(SalesLine2: Record "Sales Invoice Line")
    var

    begin


        TotalAmount[1] := TotalAmount[1] + SalesLine2.Amount;
        TotalAmount[2] := TotalAmount[2] + SalesLine2."Amount Including VAT" - SalesLine2.Amount;
        TotalAmount[3] := TotalAmount[3] + SalesLine2."Amount Including VAT";
        TotalAmount[4] := TotalAmount[4] + SalesLine2."Inv. Discount Amount";
    end;

    local procedure AddCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; IsBorder: Boolean; FontSize: Integer)
    begin
        EB.Init();
        EB.Validate("Row No.", RowNo);
        EB.Validate("Column No.", ColumnNo);
        EB."Cell Value as Text" := CellValue;
        EB.Formula := '';
        EB.Bold := Bold;
        EB."Cell Type" := CellType;
        eb."Font Size" := FontSize;
        if IsBorder then
            EB.SetBorder(true, true, true, true, false, "Border Style"::Thick);
        if not EB.Modify() then
            EB.Insert();
    end;

    local procedure AddCellWithBorder(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; border1: Boolean; border2: Boolean; border3: Boolean; border4: Boolean; FontSize: Integer)
    begin
        EB.Init();
        EB.Validate("Row No.", RowNo);
        EB.Validate("Column No.", ColumnNo);
        EB."Cell Value as Text" := CellValue;
        EB.Formula := '';
        eb."Font Size" := FontSize;
        EB.Bold := Bold;
        EB."Cell Type" := CellType;
        EB.SetBorder(border1, border2, border3, border4, false, "Border Style"::Thin);
        EB.Insert();
    end;



}