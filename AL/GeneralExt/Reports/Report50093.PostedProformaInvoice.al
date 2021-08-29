report 50093 "Posted Proforma Invoice"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    //DefaultLayout = RDLC;

    //WordLayout = './Reports/Layouts/PostedProformaInvoice.docx';
    //PreviewMode = PrintLayout;
    //WordMergeDataItem = Header;
    ProcessingOnly = true;///

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

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
                                    ExcelReportBuilderMgr.AddSection('BODY');
                                    ExcelReportBuilderMgr.AddDataToSection('Description', SL2.Description + ' ' + SL2."Description 2");
                                    IF SL2.Type = SL2.Type::" " THEN BEGIN
                                        ExcelReportBuilderMgr.AddDataToSection('LineNo', '');
                                        ExcelReportBuilderMgr.AddDataToSection('UoM', '');
                                        ExcelReportBuilderMgr.AddDataToSection('Qty', '');
                                        ExcelReportBuilderMgr.AddDataToSection('Price', '');
                                        ExcelReportBuilderMgr.AddDataToSection('LineAmt', '');
                                    END ELSE BEGIN
                                        ExcelReportBuilderMgr.AddDataToSection('LineNo', FORMAT(ItemLineNo));
                                        ExcelReportBuilderMgr.AddDataToSection('UoM', SL2."Unit of Measure");
                                        ExcelReportBuilderMgr.AddDataToSection('Qty', FORMAT(SL2.Quantity, 0, 1));
                                        ExcelReportBuilderMgr.AddDataToSection('Price', FORMAT(UnitPriceLCY, 0, 1));
                                        ExcelReportBuilderMgr.AddDataToSection('LineAmt', FORMAT(SL2."Amount (LCY)", 0, 1));
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
                            ExcelReportBuilderMgr.AddSection('REPORTFOOTER');
                            ExcelReportBuilderMgr.AddDataToSection('Amt', FORMAT(TotalAmount[1], 0, 1));
                            ExcelReportBuilderMgr.AddDataToSection('VAT', FORMAT(TotalAmount[2], 0, 1));
                            ExcelReportBuilderMgr.AddDataToSection('AmtVat', FORMAT(TotalAmount[3], 0, 1));
                            ExcelReportBuilderMgr.AddDataToSection('Footer1', 'Всего оказано услуг на сумму: ' + LocMgt.Amount2Text(CurrencyForAmountWritten, TotalAmount[3])
                                          + ', в т.ч.: НДС - ' + LocMgt.Amount2Text(CurrencyForAmountWritten, TotalAmount[2]) + '.');
                            ExcelReportBuilderMgr.AddDataToSection('CompMgr', 'Руководитель предприятия_____________________ (' +
                                RepMgt2.GetDirectorName2(TRUE, 112, 0, Header."No.", Header."Posting Date") + ')');
                            ExcelReportBuilderMgr.AddDataToSection('ChiefAccnt', 'Главный бухгалтер____________________________ (' +
                                CompanyInfo."Accountant Name" + ')');
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
                ExcelReportBuilderMgr.AddSection('REPORTHEADER');
                CompanyInfo.GET;
                Header.FindSet();
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
                    //ExcelReportBuilderMgr.AddSection('REPORTHEADER');
                    ExcelReportBuilderMgr.AddDataToSection('CompName', CompanyInfo.Name);
                    ExcelReportBuilderMgr.AddDataToSection('ComAddress', 'Адрес: ' + CompanyInfo."Post Code" + ', ' + CompanyInfo.City + ', ' + CompanyInfo.Address + ', тел.:' + CompanyInfo."Phone No.");
                    ExcelReportBuilderMgr.AddDataToSection('INN', 'ИНН ' + CompanyInfo."VAT Registration No.");
                    ExcelReportBuilderMgr.AddDataToSection('KPP', 'КПП ' + CompanyInfo."KPP Code");
                    ExcelReportBuilderMgr.AddDataToSection('CompName2', CompanyInfo.Name + CompanyInfo."Name 2");
                    ExcelReportBuilderMgr.AddDataToSection('BankName', CompanyInfo."Bank Name" + ' ' + CompanyInfo."Bank City");
                    ExcelReportBuilderMgr.AddDataToSection('DocHeader', STRSUBSTNO(Text019, TitleDoc, LocMgt.Date2Text(DateNameInvoice)));
                    ExcelReportBuilderMgr.AddDataToSection('Agreement', CustAgr."External Agreement No.");
                    ExcelReportBuilderMgr.AddDataToSection('PayToCode', Header."Bill-to Name");
                    ExcelReportBuilderMgr.AddDataToSection('ShipToCode', Header."Ship-to Name");
                    ExcelReportBuilderMgr.AddDataToSection('CustInfo', STRSUBSTNO('ИНН %1, КПП %2, %3, %4, %5', Cust."VAT Registration No.", Cust."KPP Code",
                              CustomerAddr[4], CustomerAddr[3], CustomerAddr[2]));
                    ExcelReportBuilderMgr.AddDataToSection('CompAccNo', CompanyInfo."Bank Corresp. Account No.");
                    ExcelReportBuilderMgr.AddDataToSection('BIC', CompanyInfo."Bank BIC");
                    ExcelReportBuilderMgr.AddDataToSection('BankAccNo', CompanyInfo."Bank Account No.");
                    ExcelReportBuilderMgr.AddSection('PAGEHEADER');
                end;
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
        StdRepMgt: Codeunit "Local Report Management";
        ExcelReportBuilderMgr: Codeunit "Excel Report Builder Manager";
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
        // SalesSetup.Get();
        // EB.DeleteAll();

        // if ExportExcel then begin
        //     FileName := ExcelTemplates.OpenTemplate(SalesSetup."Posted Prof-Inv. Template Code");
        //     //EB.OpenBook(FileName, ExcelTemplates."Sheet Name");
        //     RowNo := 18;

        // end;
        InitReportTemplate(GetTemplateCode());
    end;

    trigger OnPostReport()
    begin

        if ExportExcel then begin
            //EB.SetFriendlyFilename(PostedProformaInvCaption);
            // EB.UpdateBook(Filename, 'Sheet1');
            // EB.WriteSheet(PostedProformaInvCaption, CompanyName, UserId);
            // EB.CloseBook();
            // EB.OpenExcel();
            if FileName <> '' then
                ExportDataFile(FileName)
            else
                ExportData;
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

    //--------------------------------------------
    // [Scope('OnPrem')]
    // procedure InitializeRequest(NoOfCopies: Integer; PrintCurr: Option; IsLog: Boolean; IsPreview: Boolean; IsProforma: Boolean)
    // begin
    //     CopiesNumber := NoOfCopies;
    //     AmountInvoiceDone := PrintCurr;
    //     LogInteraction := IsLog;
    //     Preview := IsPreview;
    //     Proforma := IsProforma;
    // end;

    [Scope('OnPrem')]
    procedure IncrAmount(SalesLine2: Record "Sales Line")
    begin
        with SalesLine2 do begin
            TotalAmount[1] := TotalAmount[1] + Amount;
            TotalAmount[2] := TotalAmount[2] + "Amount Including VAT" - Amount;
            TotalAmount[3] := TotalAmount[3] + "Amount Including VAT";
        end;
    end;

    [Scope('OnPrem')]
    procedure TransferReportValues(var ReportValues: array[13] of Text; SalesLine2: Record "Sales Line"; CountryName2: Text; CDNo2: Text; CountryCode2: Code[10])
    var
        UoM: Record "Unit of Measure";
    begin
        // ReportValues[1] := SalesLine2.Description;
        // ReportValues[2] := '-';
        // if UoM.Get(SalesLine2."Unit of Measure Code") then
        //     ReportValues[2] := StdRepMgt.FormatTextValue(UoM."OKEI Code");
        // ReportValues[3] := StdRepMgt.FormatTextValue(SalesLine2."Unit of Measure Code");
        // ReportValues[4] := Format(Sign * SalesLine2."Qty. to Invoice");
        // ReportValues[5] := StdRepMgt.FormatReportValue(SalesLine2."Unit Price", 2);
        // ReportValues[6] := StdRepMgt.FormatReportValue(Sign * SalesLine2.Amount, 2);
        // ReportValues[7] := Format(SalesLine1."VAT %");
        // ReportValues[8] :=
        //   StdRepMgt.FormatReportValue(Sign * (SalesLine2."Amount Including VAT" - SalesLine2.Amount), 2);
        // ReportValues[9] := StdRepMgt.FormatReportValue(Sign * SalesLine2."Amount Including VAT", 2);
        // ReportValues[10] := StdRepMgt.FormatTextValue(CountryCode2);
        // ReportValues[11] := StdRepMgt.FormatTextValue(CopyStr(CountryName2, 1));
        // ReportValues[12] := StdRepMgt.FormatTextValue(CopyStr(CDNo2, 1));

        // if StdRepMgt.VATExemptLine(SalesLine2."VAT Bus. Posting Group", SalesLine2."VAT Prod. Posting Group") then
        //     StdRepMgt.FormatVATExemptLine(ReportValues[7], ReportValues[7])
        // else
        //     VATExemptTotal := false;

        // ReportValues[13] := StdRepMgt.GetEAEUItemTariffNo_SalesLine(SalesLine2);
    end;

    [Scope('OnPrem')]
    procedure TransferHeaderValues(var HeaderValue: array[12] of Text)
    begin
        // HeaderValue[1] := StdRepMgt.GetCompanyName;
        // HeaderValue[2] := StdRepMgt.GetLegalAddress;
        // HeaderValue[3] := CompanyInfo."VAT Registration No." + ' / ' + CompanyInfo."KPP Code";
        // HeaderValue[4] := ConsignorName + '  ' + ConsignorAddress;
        // HeaderValue[5] := Receiver[1] + '  ' + Receiver[2];
        // HeaderValue[6] := StdRepMgt.FormatTextValue(Header."External Document Text");
        // HeaderValue[7] := StdRepMgt.GetCustName(Header."Bill-to Customer No.");
        // HeaderValue[8] := StdRepMgt.GetCustInfo(Header, 1, 2);
        // HeaderValue[9] := Customer."VAT Registration No." + ' / ' + KPPCode;
        // HeaderValue[10] := CurrencyDigitalCode;
        // HeaderValue[11] := CurrencyDescription;
        // HeaderValue[12] := '';
        // if Header."Government Agreement No." <> '' then
        //     HeaderValue[13] := Header."Government Agreement No.";
    end;

    [Scope('OnPrem')]
    procedure PrintShortAddr(DocType: Option; DocNo: Code[20]): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", DocType);
        SalesLine.SetRange("Document No.", DocNo);
        SalesLine.SetFilter(Type, '%1|%2', SalesLine.Type::Item, SalesLine.Type::"Fixed Asset");
        SalesLine.SetFilter("No.", '<>''''');
        SalesLine.SetFilter("Qty. to Invoice", '<>0');
        exit(SalesLine.IsEmpty);
    end;


    local procedure FillDocHeader(var DocNo: Code[20]; var DocDate: Text; var RevNo: Code[20]; var RevDate: Text)
    var
        CorrDocMgt: Codeunit "Corrective Document Mgt.";
    begin
        // with Header do
        //     if "Corrective Doc. Type" = "Corrective Doc. Type"::Revision then begin
        //         case "Original Doc. Type" of
        //             "Original Doc. Type"::Invoice:
        //                 DocDate := LocMgt.Date2Text(CorrDocMgt.GetSalesInvHeaderPostingDate("Original Doc. No."));
        //             "Original Doc. Type"::"Credit Memo":
        //                 DocDate := LocMgt.Date2Text(CorrDocMgt.GetSalesCrMHeaderPostingDate("Original Doc. No."));
        //         end;
        //         DocNo := "Original Doc. No.";
        //         RevNo := "Revision No.";
        //         RevDate := LocMgt.Date2Text("Document Date");
        //     end else begin
        //         DocNo := "Posting No.";
        //         DocDate := LocMgt.Date2Text("Document Date");
        //         RevNo := '-';
        //         RevDate := '-';
        //     end;
    end;

    local procedure FillHeader()
    var

    begin


    end;

    local procedure FillBody(LineValue: array[13] of Text)
    begin
        FillBody(LineValue);
    end;

    local procedure FillRespPerson(var ResponsiblePerson: array[2] of Text)
    begin
        // ResponsiblePerson[1] := StdRepMgt.GetDirectorName(false, 36, Header."Document Type".AsInteger(), Header."No.");
        // ResponsiblePerson[2] := StdRepMgt.GetAccountantName(false, 36, Header."Document Type".AsInteger(), Header."No.");
    end;

    local procedure GetTemplateCode(): Code[10]
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Posted Prof-Inv. Template Code");
        exit(SalesReceivablesSetup."Posted Prof-Inv. Template Code");
    end;

    [Scope('OnPrem')]
    procedure SetFileNameSilent(NewFileName: Text)
    begin
        FileName := NewFileName;
    end;

    [Scope('OnPrem')]
    procedure InitReportTemplate(TemplateCode: Code[10])
    var
        SheetName: Text;
    begin
        SheetName := 'Sheet1';
        ExcelReportBuilderMgr.InitTemplate(TemplateCode);
        ExcelReportBuilderMgr.SetSheet(SheetName);
        //PrevDocumentPageNo := 0;
    end;

    [Scope('OnPrem')]
    procedure ExportData()
    begin
        ExcelReportBuilderMgr.ExportData;
    end;

    [Scope('OnPrem')]
    procedure FillHeaderHelper(DocNo: Code[20]; DocDate: Text; RevNo: Code[20]; RevDate: Text; HeaderDetails: array[13] of Text)
    begin
        ExcelReportBuilderMgr.AddSection('REPORTHEADER');

        ExcelReportBuilderMgr.AddDataToSection('FactureNum', DocNo);
        ExcelReportBuilderMgr.AddDataToSection('FactureDate', DocDate);
        ExcelReportBuilderMgr.AddDataToSection('RevisionNum', RevNo);
        ExcelReportBuilderMgr.AddDataToSection('RevisionDate', RevDate);

        ExcelReportBuilderMgr.AddDataToSection('SellerName', HeaderDetails[1]);
        ExcelReportBuilderMgr.AddDataToSection('SellerAddress', HeaderDetails[2]);
        ExcelReportBuilderMgr.AddDataToSection('SellerINN', HeaderDetails[3]);
        ExcelReportBuilderMgr.AddDataToSection('ConsignorAndAddress', HeaderDetails[4]);
        ExcelReportBuilderMgr.AddDataToSection('ConsigneeAndAddress', HeaderDetails[5]);
        ExcelReportBuilderMgr.AddDataToSection('DocumentNumDate', HeaderDetails[6]);
        ExcelReportBuilderMgr.AddDataToSection('BuyerName', HeaderDetails[7]);
        ExcelReportBuilderMgr.AddDataToSection('BuyerAddress', HeaderDetails[8]);
        ExcelReportBuilderMgr.AddDataToSection('BuyerINN', HeaderDetails[9]);
        ExcelReportBuilderMgr.AddDataToSection('CurrencyCode', HeaderDetails[10]);
        ExcelReportBuilderMgr.AddDataToSection('CurrencyName', HeaderDetails[11]);
        ExcelReportBuilderMgr.AddDataToSection('VATAgentText', HeaderDetails[12]);
        ExcelReportBuilderMgr.AddDataToSection('GovernmentAgreement', HeaderDetails[13]);


        ExcelReportBuilderMgr.AddSection('PAGEHEADER');

        //CurrentDocumentNo := DocNo;
        //CurrentDocumentDate := DocDate;
    end;

    [Scope('OnPrem')]
    procedure FillPageHeader()
    begin
        ExcelReportBuilderMgr.AddSection('PAGEHEADER');

        // ExcelReportBuilderMgr.AddDataToSection(
        //   'PageNoTxt',
        //   StrSubstNo(
        //     InvoiceTxt, CurrentDocumentNo, CurrentDocumentDate,
        //     ExcelReportBuilderMgr.GetLastPageNo - PrevDocumentPageNo));
    end;

    [Scope('OnPrem')]
    procedure FillBody(LineValue: array[13] of Text; IsProforma: Boolean)
    begin
        if not ExcelReportBuilderMgr.TryAddSection('BODY') then begin
            ExcelReportBuilderMgr.AddPagebreak;
            FillPageHeader;
            ExcelReportBuilderMgr.AddSection('BODY');
        end;

        ExcelReportBuilderMgr.AddDataToSection('ItemName', LineValue[1]);
        ExcelReportBuilderMgr.AddDataToSection('Unit', LineValue[2]);
        ExcelReportBuilderMgr.AddDataToSection('UnitName', LineValue[3]);
        ExcelReportBuilderMgr.AddDataToSection('Quantity', LineValue[4]);
        ExcelReportBuilderMgr.AddDataToSection('Price', LineValue[5]);
        ExcelReportBuilderMgr.AddDataToSection('Amount', LineValue[6]);
        ExcelReportBuilderMgr.AddDataToSection('TaxRate', LineValue[7]);
        ExcelReportBuilderMgr.AddDataToSection('TaxAmount', LineValue[8]);
        ExcelReportBuilderMgr.AddDataToSection('AmountInclTax', LineValue[9]);
        ExcelReportBuilderMgr.AddDataToSection('CountryCode', LineValue[10]);
        ExcelReportBuilderMgr.AddDataToSection('Country', LineValue[11]);
        ExcelReportBuilderMgr.AddDataToSection('GTD', LineValue[12]);

        if (not IsProforma) and (LineValue[13] <> '') then
            ExcelReportBuilderMgr.AddDataToSection('TariffNo', LineValue[13]);
    end;

    [Scope('OnPrem')]
    procedure FillReportFooter(AmountArrayTxt: array[3] of Text; ResponsiblePerson: array[2] of Text; IsProforma: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        if not ExcelReportBuilderMgr.TryAddSectionWithPlaceForFooter('REPORTFOOTER', 'FOOTER') then begin
            ExcelReportBuilderMgr.AddPagebreak;
            FillPageHeader;
            ExcelReportBuilderMgr.AddSection('REPORTFOOTER');
        end;

        ExcelReportBuilderMgr.AddDataToSection('AmountTotal', AmountArrayTxt[1]);
        ExcelReportBuilderMgr.AddDataToSection('TaxAmountTotal', AmountArrayTxt[2]);
        ExcelReportBuilderMgr.AddDataToSection('AmountInclTaxTotal', AmountArrayTxt[3]);

        if IsProforma then begin
            CompanyInformation.Get();
            ExcelReportBuilderMgr.AddDataToSection('BankName', CompanyInformation."Bank Name");
            ExcelReportBuilderMgr.AddDataToSection('BankCity', CompanyInformation."Bank City");
            ExcelReportBuilderMgr.AddDataToSection('CompanyINN', CompanyInformation."VAT Registration No.");
            ExcelReportBuilderMgr.AddDataToSection('CompanyKPP', CompanyInformation."KPP Code");
            ExcelReportBuilderMgr.AddDataToSection('CompanyName', StdRepMgt.GetCompanyName);
            ExcelReportBuilderMgr.AddDataToSection('BankBranchNo', CompanyInformation."Bank Branch No.");
            ExcelReportBuilderMgr.AddDataToSection('BankBIC', CompanyInformation."Bank BIC");
            ExcelReportBuilderMgr.AddDataToSection('BankCorrespAccNo', CompanyInformation."Bank Corresp. Account No.");
            ExcelReportBuilderMgr.AddDataToSection('BankAccountNo', CompanyInformation."Bank Account No.");
        end;

        ExcelReportBuilderMgr.AddDataToSection('DirectorName', ResponsiblePerson[1]);
        ExcelReportBuilderMgr.AddDataToSection('AccountantName', ResponsiblePerson[2]);

        ExcelReportBuilderMgr.AddSection('FOOTER');

        //PrevDocumentPageNo := ExcelReportBuilderMgr.GetLastPageNo;
    end;

    [Scope('OnPrem')]
    procedure FinalizeReport(AmountArrayTxt: array[3] of Text; ResponsiblePerson: array[2] of Text; IsProforma: Boolean)
    begin
        FillReportFooter(AmountArrayTxt, ResponsiblePerson, IsProforma);
        ExcelReportBuilderMgr.AddPagebreak;
    end;

    [Scope('OnPrem')]
    procedure GetCurrencyInfo(CurrencyCode: Code[10]; var CurrencyDigitalCode: Code[3]; var CurrencyDescription: Text)
    var
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
    begin
        CurrencyDigitalCode := '';
        CurrencyDescription := '';
        if CurrencyCode = '' then begin
            GLSetup.Get();
            CurrencyCode := GLSetup."LCY Code";
        end;

        if Currency.Get(CurrencyCode) then begin
            CurrencyDigitalCode := Currency."RU Bank Digital Code";
            CurrencyDescription := LowerCase(CopyStr(Currency.Description, 1, 1)) + CopyStr(Currency.Description, 2);
        end;
    end;

    [Scope('OnPrem')]
    procedure GetFAInfo(FANo: Code[20]; var CDNo: Text; var CountryName: Text)
    var
        FA: Record "Fixed Asset";
        CDNoInfo: Record "CD No. Information";
    begin
        CDNo := '';
        CountryName := '';

        FA.Get(FANo);
        if FA."CD No." <> '' then begin
            CDNo := FA."CD No.";
            CDNoInfo.Get(
              CDNoInfo.Type::"Fixed Asset", FA."No.", '', FA."CD No.");
            CountryName := CDNoInfo.GetCountryName;
            // CountryCode := CDNoInfo.GetCountryLocalCode;
        end;
    end;

    [Scope('OnPrem')]
    procedure GetConsignorInfo(VendorNo: Code[20]; var ConsignorName: Text; var ConsignorAddress: Text)
    var
        Vendor: Record Vendor;
    begin
        if VendorNo = '' then begin
            //ConsignorName := SameTxt;
            ConsignorAddress := '';
        end else begin
            Vendor.Get(VendorNo);
            ConsignorName := StdRepMgt.GetVendorName(VendorNo);
            ConsignorAddress := Vendor."Post Code" + ', ' + Vendor.City + ', ' + Vendor.Address + ' ' + Vendor."Address 2";
        end;
    end;

    [Scope('OnPrem')]
    procedure GetCurrencyAmtCode(CurrencyCode: Code[20]; AmountInvoiceCurrent: Option "Invoice Currency",LCY) CurrencyWrittenAmount: Code[20]
    begin
        CurrencyWrittenAmount := '';
        if AmountInvoiceCurrent = AmountInvoiceCurrent::"Invoice Currency" then
            CurrencyWrittenAmount := CurrencyCode;
    end;

    [Scope('OnPrem')]
    procedure InitAddressInfo(var ConsignorName: Text; var ConsignorAddress: Text; var Receiver: array[2] of Text)
    begin
        ConsignorName := '-';
        ConsignorAddress := '';
        Receiver[1] := '-';
        Receiver[2] := '';
    end;

    [Scope('OnPrem')]
    procedure FormatTotalAmounts(var TotalAmountTxt: array[3] of Text; TotalAmount: array[3] of Decimal; Sign: Integer; Prepayment: Boolean; VATExemptTotal: Boolean)
    begin
        if Prepayment then
            TotalAmountTxt[1] := '-'
        else
            TotalAmountTxt[1] := StdRepMgt.FormatReportValue(Sign * TotalAmount[1], 2);

        if VATExemptTotal then
            TotalAmountTxt[2] := '-'
        else
            TotalAmountTxt[2] := StdRepMgt.FormatReportValue(Sign * TotalAmount[2], 2);

        TotalAmountTxt[3] := StdRepMgt.FormatReportValue(Sign * TotalAmount[3], 2);
    end;

    [Scope('OnPrem')]
    procedure TransferItemTrLineValues(var LineValues: array[12] of Text; var TrackingSpecBuf: Record "Tracking Specification" temporary; CountryCode: Code[10]; CountryName: Text; Sign: Integer)
    var
        I: Integer;
    begin
        for I := 1 to 3 do
            LineValues[I] := '';

        LineValues[4] := Format(Sign * TrackingSpecBuf."Quantity (Base)");

        for I := 5 to 9 do
            LineValues[I] := '-';

        LineValues[10] := StdRepMgt.FormatTextValue(CountryCode);
        LineValues[11] := StdRepMgt.FormatTextValue(CopyStr(CountryName, 1, 1024));
        LineValues[12] := StdRepMgt.FormatTextValue(TrackingSpecBuf."CD No.")
    end;

    [Scope('OnPrem')]
    procedure TransferLineDescrValues(var LineValues: array[12] of Text; LineDescription: Text)
    var
        I: Integer;
    begin
        LineValues[1] := LineDescription;

        for I := 2 to 12 do
            LineValues[I] := '';
    end;

    [Scope('OnPrem')]
    procedure ExportDataFile(FileName: Text)
    begin
        ExcelReportBuilderMgr.ExportDataToClientFile(FileName);
    end;



}