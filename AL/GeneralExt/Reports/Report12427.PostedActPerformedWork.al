report 92427 "Posted Act Performed Work"
{
    //ПРСЧ-23-00026
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

                        ExcelReportBuilderMgr.AddSection('HeaderLine');
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

                            ExcelReportBuilderMgr.AddSection('BODY');
                            IF SalesLine1.Type = SalesLine1.Type::" " THEN BEGIN
                                ExcelReportBuilderMgr.AddDataToSection('LineNo', '');
                                ExcelReportBuilderMgr.AddDataToSection('Description', SalesLine1.Description + ' ' + SalesLine1."Description 2");
                                ExcelReportBuilderMgr.AddDataToSection('UoM', '');
                                ExcelReportBuilderMgr.AddDataToSection('Qty', '');
                                ExcelReportBuilderMgr.AddDataToSection('Price', '');
                                ExcelReportBuilderMgr.AddDataToSection('LineAmount', '');

                            END ELSE BEGIN
                                ExcelReportBuilderMgr.AddDataToSection('LineNo', FORMAT(ItemLineNo));
                                ExcelReportBuilderMgr.AddDataToSection('Description', SalesLine1.Description + ' ' + SalesLine1."Description 2");
                                ExcelReportBuilderMgr.AddDataToSection('UoM', SalesLine1."Unit of Measure");
                                ExcelReportBuilderMgr.AddDataToSection('Qty', FORMAT(SalesLine1.Quantity, 0, 1));
                                ExcelReportBuilderMgr.AddDataToSection('Price', FORMAT(UnitPriceLCY, 0, 1));
                                ExcelReportBuilderMgr.AddDataToSection('LineAmount', FORMAT(SalesLine1."Amount (LCY)"));
                            END;
                        END;
                        // SWC1070 DD 06.07.17 <<
                    end;

                    trigger OnPostDataItem()
                    begin

                        // SWC1070 DD 06.07.17 >>
                        IF ExportExcel THEN BEGIN
                            ExcelReportBuilderMgr.AddSection('REPORTFOOTER');
                            ExcelReportBuilderMgr.AddDataToSection('Amount', FORMAT(TotalAmount[1]));
                            ExcelReportBuilderMgr.AddDataToSection('VAT', FORMAT(TotalAmount[2]));
                            ExcelReportBuilderMgr.AddDataToSection('AmountVat', FORMAT(TotalAmount[3]));
                            ExcelReportBuilderMgr.AddDataToSection('Footer1', 'Всего оказано услуг на сумму: ' + LocMgt.Amount2Text(CurrencyForAmountWritten, TotalAmount[3])
                                        + ', в т.ч.: НДС - ' + LocMgt.Amount2Text(CurrencyForAmountWritten, TotalAmount[2]) + '.');

                            ExcelReportBuilderMgr.AddDataToSection('ActSignedBy', Header."Act Signed by Position" + '/' + Header."Act Signed by Name");
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
                    if Cust.get("Bill-to Customer No.") then;
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
                    ExcelReportBuilderMgr.AddSection('REPORTHEADER');
                    ExcelReportBuilderMgr.AddDataToSection('CompName', CompanyInfo.Name);
                    ExcelReportBuilderMgr.AddDataToSection('CompAddress', 'Адрес: ' + CompanyInfo."Post Code" + ', ' + CompanyInfo.City + ', ' + CompanyInfo.Address + ', тел.:' + CompanyInfo."Phone No.");
                    ExcelReportBuilderMgr.AddDataToSection('DocHeader', STRSUBSTNO(BodyTxt[1], Header."No.", LocMgt.Date2Text(Header."Document Date")));
                    if Cust."Full Name" <> '' then
                        ExcelReportBuilderMgr.AddDataToSection('CustName', Cust."Full Name")
                    else
                        ExcelReportBuilderMgr.AddDataToSection('CustName', CustomerAddr[1]);
                    ExcelReportBuilderMgr.AddDataToSection('CustAddress', CustomerAddr[4] + ', ' + CustomerAddr[5]);
                    ExcelReportBuilderMgr.AddDataToSection('CustVAT', Cust."VAT Registration No.");
                    ExcelReportBuilderMgr.AddDataToSection('CustKPP', Cust."VAT Registration No.");
                    ExcelReportBuilderMgr.AddDataToSection('DocReason', STRSUBSTNO('Договор %1 от %2', CustAgrmt."External Agreement No.",
                                    CustAgrmt."Agreement Date"));
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
                        Visible = false;
                    }

                }
            }

        }
        trigger OnOpenPage()
        begin
            CopiesNumber := 1;
            ExportExcel := true;
        end;

    }

    trigger OnPreReport()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        PurchAndPbleSetup: Record "Purchases & Payables Setup";
    begin

        ExportExcel := true;

        if not CurrReport.UseRequestPage then
            CopiesNumber := 1;
        InitReportTemplate(GetTemplateCode());
    end;


    trigger OnPostReport()
    var
    //AgedAcctPayableCaptionLbl: Label 'Aged Accounts Payable';
    begin
        if FileName <> '' then
            ExportDataFile(FileName)
        else
            ExportData;
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
        StdRepMgt: Codeunit "Local Report Management";
        ExcelReportBuilderMgr: Codeunit "Excel Report Builder Manager";
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
            EB.SetBorder(true, true, true, true, false, "Border Style"::Thin);
        if not EB.Modify() then
            EB.Insert();
    end;

    local procedure AddCellItalic(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; IsBorder: Boolean; FontSize: Integer)
    begin
        EB.Init();
        EB.Validate("Row No.", RowNo);
        EB.Validate("Column No.", ColumnNo);
        EB."Cell Value as Text" := CellValue;
        EB.Formula := '';
        EB.Bold := Bold;
        EB.Italic := true;
        EB."Cell Type" := CellType;
        eb."Font Size" := FontSize;
        if IsBorder then
            EB.SetBorder(true, true, true, true, false, "Border Style"::Thin);
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
        EB.SetBorder(border1, border2, border3, border4, false, "Border Style"::Thin);
        EB.Insert();
    end;

    local procedure GetTemplateCode(): Code[10]
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Posted Act PerfWork Templ Code");
        exit(SalesReceivablesSetup."Posted Act PerfWork Templ Code");
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
