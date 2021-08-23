report 92426 "Act Performed Work"
{
    //ПРЗК-23-00015
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Act Performed Work';
    //DefaultLayout = Word;
    //WordLayout = './Reports/Layouts/ActPerformedWork.docx';
    //PreviewMode = PrintLayout;
    //WordMergeDataItem = Header;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Header; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
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
                    column(CompanyAddress1; CompanyAddress[1]) { }
                    column(CompanyAddress2; CompanyAddress[2]) { }
                    column(CompanyAddress3; CompanyAddress[3]) { }
                    column(CompanyAddress4; CompanyAddress[4]) { }
                    column(CompanyAddress5; CompanyAddress[5]) { }
                    column(CompanyAddress6; CompanyAddress[6]) { }
                    column(CompanyAddress7; CompanyAddress[7]) { }
                    column(CompanyAddress8; CompanyAddress[8]) { }
                    column(CompanyAddress9; STRSUBSTNO('р/с %1 в %2 \К/с %3 \БИК %4', CompanyInfo."Bank Account No.", CompanyInfo."Bank Name", BankDirectory."Corr. Account No.", CompanyInfo."Bank BIC")) { }
                    column(CompanyAddress10; STRSUBSTNO('ИНН %1 ', CompanyInfo."VAT Registration No.")) { }
                    column(CompanyAddress11; CompanyInfo."Phone No.") { }
                    column(CompanyAddress12; CompanyInfo."Fax No.") { }
                    column(CustomerAddr1; CustomerAddr[1]) { }
                    column(CustomerAddr2; CustomerAddr[2]) { }
                    column(CustomerAddr3; CustomerAddr[3]) { }
                    column(CustomerAddr4; CustomerAddr[4]) { }
                    column(CustomerAddr5; CustomerAddr[5]) { }
                    column(CustomerAddr6; CustomerAddr[6]) { }
                    column(CustomerAddr7; CustomerAddr[7]) { }
                    column(CustomerAddr8; CustomerAddr[8]) { }
                    column(CustomerAddr9; STRSUBSTNO('р/с %1 в %2 \К/с %3 \БИК %4', CustBankAcc."Bank Account No.", CustBankAcc.Name, CustBankAcc."Bank Corresp. Account No.", CustBankAcc.BIC)) { }
                    column(CustomerAddr10; STRSUBSTNO('ИНН %1', Cust."VAT Registration No.")) { }
                    column(CustomerAddr11; Cust."Phone No.") { }
                    column(CustomerAddr12; Cust."Fax No.") { }
                    column(AddrInfo13; STRSUBSTNO('Акт сдачи-приемки оказанных услуг  № %1\от  %2', Header."Posting No.", LocMgt.Date2Text(Header."Document Date"))) { }
                    column(AddrInfo14; CurrencyInfo) { }
                    column(AddrInfo15; AgreementDescription) { }





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
                    column(No2; SalesLine1."No.") { }
                    column(Description2; SalesLine1.Description) { }
                    column(UoM2; SalesLine1."Unit of Measure") { }
                    column(QtyToInv2; SalesLine1."Qty. to Invoice") { }
                    column(UnitPrice2; UnitPrice) { }
                    column(Amount2; SalesLine1.Amount) { }

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
                                IF "Qty. to Invoice" = 0 THEN
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
                                  ROUND(Amount / "Qty. to Invoice", Currency."Unit-Amount Rounding Precision");
                                UnitPriceLCY :=
                                  ROUND("Amount (LCY)" / "Qty. to Invoice", Currency."Unit-Amount Rounding Precision");
                            END ELSE BEGIN
                                IF CheckSalesInvoiceLine.GET("Document Type", "Document No.", "Attached to Line No.") THEN
                                    IF CheckSalesInvoiceLine."Qty. to Invoice" = 0 THEN
                                        CurrReport.SKIP;

                                "No." := '';
                                ItemLineNo := 0;
                            END;
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

                Header.TESTFIELD(Status);
                CompanyInfo.GET;
                IF BankDirectory.GET(CompanyInfo."Bank BIC") THEN;
                AddressFormat.Company(CompanyAddress, CompanyInfo);
                TitleDoc := STRSUBSTNO(Text14804, "No.");
                IF "Document Type" = "Document Type"::Order THEN
                    DateNameInvoice := "Order Date"
                ELSE
                    DateNameInvoice := "Posting Date";

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

                IF "Agreement No." <> '' THEN BEGIN
                    CustAgrmt.GET("Bill-to Customer No.", "Agreement No.");
                    IF CustBankAcc.GET(Cust."No.", CustAgrmt."Default Bank Code") THEN;
                    AgreementDescription :=
                      STRSUBSTNO(Text14809, CustAgrmt."External Agreement No.", CustAgrmt."Agreement Date");
                END ELSE
                    AgreementDescription := Text14810;

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
                    ManagerText := Text14808;
                END ELSE BEGIN
                    Manager.GET("Salesperson Code");
                    ManagerText := Text14808;
                END;

                AmountInclVAT := "Prices Including VAT";

                SalesLine1.RESET;
                SalesLine1.SETRANGE("Document Type", "Document Type");
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
                if CurrencyCode <> '' then
                    CurrencyInfo := StrSubstNo('Курс %1   %2', CurrencyCode, CurrencyExchRate);

                IF NOT CurrReport.PREVIEW THEN BEGIN
                    IF ArchiveDocument THEN
                        ArchiveManagement.StoreSalesDocument(Header, LogInteraction);


                    IF LogInteraction THEN BEGIN
                        CALCFIELDS("No. of Archived Versions");
                        IF "Bill-to Contact No." <> '' THEN
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Contact, "Bill-to Contact No."
                              , "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        ELSE
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    END;
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
                }
            }
        }


    }

    trigger OnPreReport()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin

        IF NOT CurrReport.UseRequestPage THEN
            CopiesNumber := 1;
        XL.DeleteAll();
        SalesSetup.get;
        Filename := ExcelTemplates.OpenTemplate((SalesSetup."Act PerfWork Templ Code"));
        RowNo := 5;

    end;


    var
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        CompanyInfo: Record "Company Information";
        Currency: Record Currency;
        Cust: Record Customer;
        Manager: Record "Salesperson/Purchaser";
        SalesLine1: Record "Sales Line";
        SalesRecSetup: Record "Sales & Receivables Setup";
        BankDirectory: Record "Bank Directory";
        CustBankAcc: Record "Customer Bank Account";
        CustAgrmt: Record "Customer Agreement";
        PrintingCounter: Codeunit "Sales-Printed";
        AddressFormat: Codeunit "Format Address";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        LocMgt: Codeunit "Localisation Management";
        StandRepManagement: Codeunit "Local Report Management";
        LocRepMgt2: Codeunit "Local Report Management Ext";
        ArchiveManagement: Codeunit ArchiveManagement;
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
        TotalAmount: array[8] of Decimal;
        LastTotalAmount: array[8] of Decimal;
        AmountInvDiscount: Decimal;
        DecPointCourse: Integer;
        CopiesNumber: Integer;
        ItemLineNo: Integer;
        OrderedNo: Integer;
        CurrencyForAmountWritten: Code[10];
        FirstStep: Boolean;
        DocumentType: Option "Quote","Order",Invoice,"Credit Memo","Posted Invoice","Posted Shipment","Posted Credit Mem","Return Order","Posted Return Receipt";
        QtyType: Option General,Invoicing,Shipping;
        Ind: Option "",Quantiy,Price,Amount,AmountInclVAT,VATAmount,"VAT%","Discounts%",PriceCurrDoc,"Sales Tax Amount","GTD No.","Origin Country",ExciseAmount,AmountInclTaxSales,AmountForLine;
        Ins: Option "",Quantity,Amount,AmouontInclVAT,VATAmount,"Sales Tax Amount",ExciseAmount,AmountInclSalesTax,AmountForLine;
        AgreementDescription: Text[250];
        PayComment: Text[250];
        ArchiveDocument: Boolean;
        LogInteraction: Boolean;
        UnitPrice: Decimal;
        UnitPriceLCY: Decimal;
        CurrencyInfo: Text[250];
        XL: Record "Excel Buffer Mod" temporary;
        ExcelTemplates: Record "Excel Template";
        RowNo: Integer;
        FileName: Text[250];
        //----------------------------

        Text14800: Label '%2. Стр. %1';
        Text14801: Label '%1 от %2';
        Text14802: Label 'ИНН %1';
        Text14803: Label 'Курс';
        Text14804: Label 'СЧЕТ %1';
        Text14808: Label 'Менеджер';
        Text020: Label 'Для Клиент Но. %1 не задан Банковский Счет.';
        Text14809: Label 'Мы, нижеподписавшиеся, составили настоящий Акт о том, что результаты работ удовлетворяют условиям Договора %1 от %2 и в надлежащем порядке оформлены.';
        Text14810: Label 'Мы, нижеподписавшиеся, составили настоящий Акт о том, что результаты работ удовлетворяют условиям Договора и в надлежащем порядке оформлены.';



    local procedure IncrAmount(SalesLine2: Record "Sales Line")
    var

    begin

        TotalAmount[1] := TotalAmount[1] + SalesLine2.Amount;
        TotalAmount[2] := TotalAmount[2] + SalesLine2."Amount Including VAT" - SalesLine2.Amount;
        TotalAmount[3] := TotalAmount[3] + SalesLine2."Amount Including VAT";
        TotalAmount[4] := TotalAmount[4] + SalesLine2."Inv. Discount Amount";
    end;

    local procedure AddCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; IsBorder: Boolean; FontSize: Integer)
    begin
        XL.Init();
        XL.Validate("Row No.", RowNo);
        XL.Validate("Column No.", ColumnNo);
        XL."Cell Value as Text" := CellValue;
        XL.Formula := '';
        XL.Bold := Bold;
        XL."Cell Type" := CellType;
        XL."Font Size" := FontSize;
        if IsBorder then
            XL.SetBorder(true, true, true, true, false, "Border Style"::Thick);
        if not XL.Modify() then
            XL.Insert();
    end;

    local procedure AddCellWithBorder(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; border1: Boolean; border2: Boolean; border3: Boolean; border4: Boolean)
    begin
        XL.Init();
        XL.Validate("Row No.", RowNo);
        XL.Validate("Column No.", ColumnNo);
        XL."Cell Value as Text" := CellValue;
        XL.Formula := '';
        XL.Bold := Bold;
        XL."Cell Type" := CellType;
        XL.SetBorder(border1, border2, border3, border4, false, "Border Style"::Medium);
        XL.Insert();
    end;
}
