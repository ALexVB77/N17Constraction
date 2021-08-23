report 92427 "Posted Act Performed Work"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Posted Act Performed Work';
    // DefaultLayout = Word;
    // WordLayout = './Reports/Layouts/PostedActPerformedWork.docx';
    // PreviewMode = PrintLayout;
    // WordMergeDataItem = Header;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            dataitem(CopyCycle; Integer)
            {
                DataItemTableView = SORTING(Number);
                dataitem("Company Information"; "Company Information")
                {
                    DataItemTableView = SORTING("Primary Key");
                    MaxIteration = 1;
                }
                dataitem(CopyHeader; Integer)
                {
                    DataItemTableView = SORTING(Number);
                    trigger OnPreDataItem()
                    begin

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
                    end;
                }
                dataitem(CopyLine; Integer)
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    trigger OnPreDataItem()
                    begin

                        LinesWereFinished := FALSE;
                        OrderedNo := 0;
                        IF (CurrentCurrencyAmountPrice IN
                           [CurrentCurrencyAmountPrice::Currency, CurrentCurrencyAmountPrice::"LCY+Currency"]) AND
                           (Header."Currency Code" <> '')
                        THEN
                            Currency.GET(Header."Currency Code")
                        ELSE
                            Currency.InitRoundingPrecision;
                    end;

                    trigger OnAfterGetRecord()
                    var
                        CheckSalesInvoiceLine: Record "Sales Line";
                    begin


                        IF Number = 1 THEN BEGIN
                            IF NOT SalesLine1.FIND('-') THEN
                                CurrReport.BREAK;
                        END ELSE
                            IF SalesLine1.NEXT(1) = 0 THEN
                                CurrReport.BREAK;

                        COPYARRAY(LastTotalAmount, TotalAmount, 1);

                        IF Header."Prices Including VAT" THEN
                            LastTotalAmount[1] := TotalAmount[3];

                        WITH SalesLine1 DO
                            IF Type <> Type::" " THEN BEGIN
                                IF Quantity = 0 THEN
                                    CurrReport.SKIP;
                                OrderedNo := OrderedNo + 1;
                                ItemLineNo := OrderedNo;
                                IF CurrentCurrencyAmountPrice = CurrentCurrencyAmountPrice::LCY THEN BEGIN
                                    Amount := "Amount (LCY)";
                                    "Amount Including VAT" := "Amount Including VAT (LCY)";
                                END;
                                IncrAmount(SalesLine1);
                                IF Header."Prices Including VAT" THEN BEGIN
                                    Amount := "Amount Including VAT";
                                    "Amount (LCY)" := "Amount Including VAT (LCY)";
                                END;
                                UnitPrice :=
                                  ROUND(Amount / Quantity, Currency."Unit-Amount Rounding Precision");
                                UnitPriceLCY :=
                                  ROUND("Amount (LCY)" / Quantity, Currency."Unit-Amount Rounding Precision");
                            END ELSE BEGIN
                                IF CheckSalesInvoiceLine.GET("Document No.", "Attached to Line No.") THEN
                                    IF CheckSalesInvoiceLine.Quantity = 0 THEN
                                        CurrReport.SKIP;
                                "No." := '';
                                ItemLineNo := 0;
                            END;

                        // SWC1070 DD 06.07.17 >>
                        IF ExportExcel THEN BEGIN
                            RowNo += 1;
                            //IF RowNo <> ExcelTemplates."Top Margin" THEN
                            //EB.CopyRow(ExcelTemplates."Top Margin");

                            AddCell(RowNo, 3, SalesLine1.Description + ' ' + SalesLine1."Description 2", FALSE, EB."Cell Type"::Text, FALSE, 9);
                            IF SalesLine1.Type = SalesLine1.Type::" " THEN BEGIN
                                AddCell(RowNo, 2, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                AddCell(RowNo, 4, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                AddCell(RowNo, 5, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                AddCell(RowNo, 6, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                                AddCell(RowNo, 7, '', FALSE, EB."Cell Type"::Text, FALSE, 9);
                            END ELSE BEGIN
                                AddCell(RowNo, 2, FORMAT(ItemLineNo), FALSE, EB."Cell Type"::Text, FALSE, 9);
                                AddCell(RowNo, 4, SalesLine1."Unit of Measure", FALSE, EB."Cell Type"::Text, FALSE, 9);
                                AddCell(RowNo, 5, FORMAT(SalesLine1.Quantity, 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                                AddCell(RowNo, 6, FORMAT(UnitPriceLCY, 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                                AddCell(RowNo, 7, FORMAT(SalesLine1."Amount (LCY)", 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                            END;
                        END;
                        // SWC1070 DD 06.07.17 <<
                    end;

                    trigger OnPostDataItem()
                    begin

                        // SWC1070 DD 06.07.17 >>
                        IF ExportExcel THEN BEGIN
                            AddCell(RowNo + 1, 7, FORMAT(TotalAmount[1], 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 2, 7, FORMAT(TotalAmount[2], 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 3, 7, FORMAT(TotalAmount[3], 0, 1), FALSE, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 5, 2, 'Всего оказано услуг на сумму: ' + LocMgt.Amount2Text(CurrencyForAmountWritten, TotalAmount[3])
                                        + ', в т.ч.: НДС - ' + LocMgt.Amount2Text(CurrencyForAmountWritten, TotalAmount[2]) + '.', FALSE, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 7, 3, RepMgt2.GetDirectorName2(TRUE, 112, 0, Header."No.", Header."Posting Date"), FALSE, EB."Cell Type"::Text, FALSE, 9);
                            AddCell(RowNo + 7, 6, Header."Act Signed by Position" + '/' + Header."Act Signed by Name", FALSE, EB."Cell Type"::Text, FALSE, 9);
                        END;
                        // SWC1070 DD 06.07.17 <<
                    end;
                }
                dataitem(CopyEndingOfReport; Integer)
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                }

                trigger OnPreDataItem()
                begin

                    IF NOT SalesLine1.FIND('-') THEN
                        CurrReport.BREAK;

                    SETRANGE(Number, 1, CopiesNumber);
                end;

                trigger OnAfterGetRecord()
                begin

                    CLEAR(TotalAmount);
                    ItemLineNo := 0;

                    IF NOT (Number = 1) THEN BEGIN
                        //CurrReport.NEWPAGE;
                        //CurrReport.PAGENO := 1;
                    END;
                    NewInvoce := TRUE;
                end;

                trigger OnPostDataItem()
                begin

                    IF NOT CurrReport.PREVIEW THEN
                        PrintingCounter.RUN(Header);
                end;

            }
            trigger OnPreDataItem()
            begin
                FirstStep := TRUE;
            end;

            trigger OnAfterGetRecord()
            begin


                CompanyInfo.GET;
                IF BankDirectory.GET(CompanyInfo."Bank BIC") THEN;
                // SWC833 DD 18.05.16 >>
                //AddressFormat.SetRepDate("Posting Date");
                // SWC833 DD 18.05.16 <<
                AddressFormat.Company(CompanyAddress, CompanyInfo);
                IF "Order No." <> '' THEN BEGIN
                    TitleDoc := STRSUBSTNO(Text014, "No.", "Order No.");
                    DateNameInvoice := "Order Date";
                END ELSE BEGIN
                    TitleDoc := STRSUBSTNO(Text015, "No.", "Pre-Assigned No.");
                    DateNameInvoice := "Posting Date";
                END;

                IF NOT FirstStep THEN BEGIN
                    //CurrReport.NEWPAGE;
                    //CurrReport.PAGENO := 1;
                END ELSE
                    FirstStep := FALSE;
                NewInvoce := TRUE;

                IF NOT ShipmentMethod.GET("Shipment Method Code") THEN
                    ShipmentMethod.INIT;
                IF NOT PaymentTerms.GET("Payment Terms Code") THEN
                    PaymentTerms.INIT;

                Cust.GET("Bill-to Customer No.");

                //NCC002 CITRU\ROMB 11.01.12 >
                CASE ActType OF
                    ActType::Default:
                        BEGIN
                            HeaderTxt[1] := 'Название Исполнителя';
                            HeaderTxt[2] := 'Название Заказчика';
                            BodyTxt[1] := 'Акт сдачи-приемки оказанных услуг  № %1 от %2';
                            BodyTxt[2] := 'результаты работ';
                            FooterTxt[1] := 'От Исполнителя';
                            FooterTxt[2] := 'От Заказчика';
                        END;
                    ActType::Sublease:
                        BEGIN
                            HeaderTxt[1] := 'Название Субарендодателя';
                            HeaderTxt[2] := 'Название Субарендатора';
                            BodyTxt[1] := 'Акт сдачи-приемки № %1 от %2';
                            BodyTxt[2] := 'оказанные услуги';
                            FooterTxt[1] := 'От Субарендодателя';
                            FooterTxt[2] := 'От Субарендатора';
                        END;
                END;
                //NCC002 CITRU\ROMB 11.01.12 <


                IF "Agreement No." <> '' THEN BEGIN
                    CustAgrmt.GET("Bill-to Customer No.", "Agreement No.");
                    IF CustBankAcc.GET(Cust."No.", CustAgrmt."Default Bank Code") THEN;
                    AgreementDescription :=
                      //STRSUBSTNO(Text14809,CustAgrmt."External Agreement No.",CustAgrmt."Agreement Date");   //NCC002 CITRU\ROMB 11.01.12 commented
                      STRSUBSTNO(Text50809, CustAgrmt."External Agreement No.", CustAgrmt."Agreement Date", BodyTxt[2]);
                    //NCC002 CITRU\ROMB 11.01.12 in
                END ELSE
                    //AgreementDescription := Text14810;                        //NCC002 CITRU\ROMB 11.01.12 commented
                    AgreementDescription := STRSUBSTNO(Text50810, BodyTxt[2]);  //NCC002 CITRU\ROMB 11.01.12 inserted

                IF CustBankAcc.Code = '' THEN BEGIN
                    CustBankAcc.RESET;
                    CustBankAcc.SETRANGE("Customer No.", Cust."No.");
                    IF NOT CustBankAcc.FIND('-') THEN;
                END;

                AddressFormat.Customer(CustomerAddr, Cust);

                CurrentCurrencyAmountPrice := CurrencyPriceAmount;

                ExcludingDiscount := NOT ShowDiscount;

                IF NOT ("Currency Code" = '') THEN
                    TESTFIELD("Currency Factor");
                IF (CurrentCurrencyAmountPrice IN
                     [CurrentCurrencyAmountPrice::Currency, CurrentCurrencyAmountPrice::"LCY+Currency"]) AND
                   ("Currency Code" = '')
                THEN
                    CurrentCurrencyAmountPrice := CurrentCurrencyAmountPrice::LCY;

                IF DecPointCourse < 1 THEN
                    DecPointCourse := 5;

                CurrencyExchRate := '';
                IF (CurrentCurrencyAmountPrice IN [CurrentCurrencyAmountPrice::Currency, CurrentCurrencyAmountPrice::"LCY+Currency"]) THEN BEGIN
                    CurrencyCode := "Currency Code";
                    IF CurrentCurrencyAmountPrice = CurrentCurrencyAmountPrice::"LCY+Currency" THEN
                        CurrencyExchRate := FORMAT(ROUND(1 / "Currency Factor", POWER(10, 0 - DecPointCourse)),
                            0, '<Integer Thousand><Decimals,' + FORMAT(DecPointCourse + 1) + '>');
                END ELSE
                    CurrencyCode := '';

                IF "Salesperson Code" = '' THEN BEGIN
                    Manager.INIT;
                    ManagerText := PADSTR('', MAXSTRLEN(ManagerText), ' ');
                    ManagerText := Text001;
                END ELSE BEGIN
                    Manager.GET("Salesperson Code");
                    ManagerText := Text001;
                END;

                AmountInclVAT := "Prices Including VAT";

                SalesLine1.RESET;
                SalesLine1.SETRANGE("Document No.", "No.");

                SalesRecSetup.GET;
                IF CurrentCurrencyAmountPrice = CurrentCurrencyAmountPrice::Currency THEN BEGIN
                    IF NOT Currency.GET("Currency Code") THEN
                        Currency.Description := 'доллар США';
                    PayComment :=
                      COPYSTR(STRSUBSTNO(SalesRecSetup."Invoice Comment",
                        LOWERCASE(Currency.Description)),
                        1, MAXSTRLEN(PayComment));
                    CurrencyForAmountWritten := Currency.Code;
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
                IF ExportExcel THEN BEGIN
                    AddCell(1, 2, CompanyInfo.Name, TRUE, EB."Cell Type"::Text, FALSE, 10);
                    AddCell(2, 2, 'Адрес: ' + CompanyInfo."Post Code" + ', ' + CompanyInfo.City + ', ' + CompanyInfo.Address + ', тел.:' + CompanyInfo."Phone No.",
                              TRUE, EB."Cell Type"::Text, FALSE, 10);
                    AddCell(4, 2, STRSUBSTNO(BodyTxt[1], Header."No.", LocMgt.Date2Text(Header."Document Date")), TRUE, EB."Cell Type"::Text, FALSE, 12);
                    AddCell(6, 2, 'Заказчик: ' + CustomerAddr[1], FALSE, EB."Cell Type"::Text, FALSE, 10);
                    AddCell(7, 3, CustomerAddr[2] + ', ' + CustomerAddr[3], FALSE, EB."Cell Type"::Text, FALSE, 10);
                    AddCell(8, 3, STRSUBSTNO('ИНН %1, КПП %2', Cust."VAT Registration No.", Cust."KPP Code"), FALSE, EB."Cell Type"::Text, FALSE, 10);
                    AddCell(10, 2, STRSUBSTNO('Договор %1 от %2', CustAgrmt."External Agreement No.",
                                    CustAgrmt."Agreement Date"), FALSE, EB."Cell Type"::Text, FALSE, 10);
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
                group(GroupName)
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
                    field(ActType; ActType)
                    {
                        Caption = 'Act Type';
                    }
                    field(ExportExcel; ExportExcel)
                    {
                        ApplicationArea = All;
                        Caption = 'Export Excel';
                    }

                }
            }
        }


    }

    trigger OnPreReport()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        PurchAndPbleSetup: Record "Purchases & Payables Setup";
    begin

        // IF NOT CurrReport.UseRequestPage THEN
        //     CopiesNumber := 1;

        // IF ExportExcel THEN BEGIN
        SalesSetup.Get();
        //     EB.DeleteAll();
        //     ExcelTemplates.Get(SalesSetup."Posted Act PerfWork Templ Code");
        //     if ExportExcel then begin
        //         FileName := ExcelTemplates.OpenTemplate(SalesSetup."Posted Act PerfWork Templ Code");


        //         RowNo := 12;
        EB.DeleteAll();
        //Clear(XL);
        if ExportExcel then begin
            Filename := ExcelTemplates.OpenTemplate((SalesSetup."Posted Act PerfWork Templ Code"));
            //XL.OpenBook(Filename, 'Sheet1');
            //xl.OpenBookForUpdate(Filename);
            //xl.SetActiveWriterSheet('Sheet1');
            //FontSize := 11;
            //RowNoBegin := 5;
            RowNo := 5;
        end;
    end;

    trigger OnPostReport()
    var
    //AgedAcctPayableCaptionLbl: Label 'Aged Accounts Payable';
    begin
        if ExportExcel then begin
            EB.SetFriendlyFilename('Posted Act Performed Work');
            EB.UpdateBook(Filename, 'Sheet1');
            EB.WriteSheet('Posted Act Performed Work', CompanyName, UserId);
            EB.CloseBook();
            EB.OpenExcel();
        end;

    end;

    var

        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        CompanyInfo: Record "Company Information";
        Currency: Record Currency;
        Cust: Record Customer;
        Manager: Record "Salesperson/Purchaser";
        SalesLine1: Record "Sales Invoice Line";
        SalesRecSetup: Record "Sales & Receivables Setup";
        BankDirectory: Record "Bank Directory";
        CustBankAcc: Record "Customer Bank Account";
        CustAgrmt: Record "Customer Agreement";
        PrintingCounter: Codeunit "Sales Inv.-Printed";
        AddressFormat: Codeunit "Format Address";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        LocMgt: Codeunit "Localisation Management";
        StandRepManagement: Codeunit "Local Report Management";
        SegManagement: Codeunit SegManagement;
        DateNameInvoice: Date;
        CurrencyPriceAmount: Option Currency,LCY,"LCY+Currency";
        CurrentCurrencyAmountPrice: Option Currency,LCY,"LCY+Currency";
        ExcludingDiscount: Boolean;
        ShowDiscount: Boolean;
        AmountInclVAT: Boolean;
        LinesWereFinished: Boolean;
        NewInvoce: Boolean;
        TitleDoc: Text[100];
        CustomerAddr: array[8] of Text[90];
        CompanyAddress: array[8] of Text[90];
        PageHeader: Text[100];
        CurrencyCode: Text[10];
        CurrencyExchRate: Text[30];
        ManagerText: Text[30];
        ReportValue: Text[30];
        CommentsText: Text[100];
        TotalAmount: array[8] of Decimal;
        LastTotalAmount: array[8] of Decimal;
        AmountInvDiscount: array[8] of Decimal;
        DecPointCourse: Integer;
        CopiesNumber: Integer;
        ItemLineNo: Integer;
        OrderedNo: Integer;
        CurrencyForAmountWritten: Code[10];
        FirstStep: Boolean;
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Posted Shipment","Posted Invoice","Posted Credit Memo","Return Order","Posted Return Receipt";
        QtyType: Option General,Invoicing,Shipping;
        Ind: Option "",Quantiy,Price,Amount,AmountInclVAT,VATAmount,"VAT%","Discounts%",PriceCurrDoc,"Sales Tax Amount","GTD No.","Origin Country",ExciseAmount,AmountInclTaxSales,AmountForLine;
        Ins: Option "",Quantity,Amount,AmouontInclVAT,VATAmount,"Sales Tax Amount",ExciseAmount,AmountInclSalesTax,AmountForLine;
        Director: Text[150];
        AgreementDescription: Text[250];
        PayComment: Text[250];
        LogInteraction: Boolean;
        UnitPrice: Decimal;
        UnitPriceLCY: Decimal;

        HeaderTxt: array[2] of Text[40];
        BodyTxt: array[2] of Text[100];
        FooterTxt: array[2] of Text[40];

        ExportExcel: Boolean;
        ExcelTemplates: Record "Excel Template";
        EB: Record "Excel Buffer Mod" temporary;
        RowNo: Integer;
        FileName: Text[250];
        ActType: Option Default,Sublease;
        RepMgt2: Codeunit "Local Report Management Ext";
        //----------------------------
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
        Text012: Label 'ИНН %1';
        Text013: Label '%2. Стр. %1';
        Text014: Label 'СЧЕТ %1 ПО ЗАКАЗУ № %2';
        Text015: Label 'СЧЕТ № %1 (%2)';
        Text019: Label '%1 от %2';
        Text020: label 'Для Клиент Но. %1 не задан Банковский Счет.';
        Text14809: label 'Мы, нижеподписавшиеся, составили настоящий Акт о том, что результаты работ удовлетворяют условиям Договора %1 от %2 и в надлежащем порядке оформлены.';
        Text14810: Label 'Мы, нижеподписавшиеся, составили настоящий Акт о том, что результаты работ удовлетворяют условиям Договора и в надлежащем порядке оформлены.';
        Text50809: Label 'Мы, нижеподписавшиеся, составили настоящий Акт о том, что %3 удовлетворяют условиям Договора %1 от %2 и в надлежащем порядке оформлены.';
        Text50810: Label 'Мы, нижеподписавшиеся, составили настоящий Акт о том, что %1 удовлетворяют условиям Договора и в надлежащем порядке оформлены.';


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

    local procedure AddCellWithBorder(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; border1: Boolean; border2: Boolean; border3: Boolean; border4: Boolean)
    begin
        EB.Init();
        EB.Validate("Row No.", RowNo);
        EB.Validate("Column No.", ColumnNo);
        EB."Cell Value as Text" := CellValue;
        EB.Formula := '';
        EB.Bold := Bold;
        EB."Cell Type" := CellType;
        EB.SetBorder(border1, border2, border3, border4, false, "Border Style"::Medium);
        EB.Insert();
    end;
}
