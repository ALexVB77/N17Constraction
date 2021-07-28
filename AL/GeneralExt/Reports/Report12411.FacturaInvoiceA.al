report 92411 "Order Factura-Invoice (A) Ext"
{
    Caption = 'Order Factura-Invoice (A)';
    ProcessingOnly = true;


    dataset
    {
        dataitem(Header; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
            RequestFilterFields = "No.";
            dataitem(CopyCycle; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(LineCycle; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    dataitem(AttachedLineCycle; "Integer")
                    {
                        DataItemTableView = SORTING(Number);

                        trigger OnAfterGetRecord()
                        var
                            LineValues: array[13] of Text;
                        begin
                            if Number = 1 then
                                AttachedSalesLine.FindSet
                            else
                                AttachedSalesLine.Next;

                            CopyArray(LastTotalAmount, TotalAmount, 1);
                            TransferLineDescrValues(LineValues, AttachedSalesLine.Description);
                            FillBody(LineValues);
                        end;

                        trigger OnPreDataItem()
                        begin
                            AttachedSalesLine.SetRange("Attached to Line No.", SalesLine1."Line No.");
                            SetRange(Number, 1, AttachedSalesLine.Count);
                        end;
                    }
                    dataitem(ItemTrackingLine; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));

                        trigger OnAfterGetRecord()
                        var
                            LineValues: array[13] of Text;
                        begin
                            if Number = 1 then
                                TrackingSpecBuffer2.FindSet
                            else
                                TrackingSpecBuffer2.Next;

                            if CDNoInfo.Get(
                                 CDNoInfo.Type::Item, TrackingSpecBuffer2."Item No.", TrackingSpecBuffer2."Variant Code", TrackingSpecBuffer2."CD No.")
                            then begin
                                CountryName := CDNoInfo.GetCountryName;
                                CountryCode := CDNoInfo.GetCountryLocalCode;
                            end;

                            CopyArray(LastTotalAmount, TotalAmount, 1);
                            TransferItemTrLineValues(LineValues, TrackingSpecBuffer2, CountryCode, CountryName, Sign);
                            FillBody(LineValues);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not MultipleCD then
                                CurrReport.Break();

                            SetRange(Number, 1, TrackingSpecCount);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        LineValues: array[14] of Text;
                    begin
                        if Number = 1 then begin
                            if not SalesLine1.Find('-') then
                                CurrReport.Break();
                        end else
                            if SalesLine1.Next(1) = 0 then begin
                                FormatTotalAmounts(
                                  TotalAmountText, TotalAmount, Sign, false, VATExemptTotal);
                                CurrReport.Break();
                            end;

                        CopyArray(LastTotalAmount, TotalAmount, 1);

                        if SalesLine1.Type <> SalesLine1.Type::" " then begin
                            if SalesLine1."Qty. to Invoice" = 0 then
                                CurrReport.Skip();
                            if AmountInvoiceCurrent = AmountInvoiceCurrent::LCY then begin
                                SalesLine1.Amount := SalesLine1."Amount (LCY)";
                                SalesLine1."Amount Including VAT" := SalesLine1."Amount Including VAT (LCY)";
                            end;
                            SalesLine1.Amount :=
                              Round(SalesLine1.Amount * SalesLine1."Qty. to Invoice" / SalesLine1.Quantity,
                                Currency."Amount Rounding Precision");
                            SalesLine1."Amount Including VAT" :=
                              Round(SalesLine1."Amount Including VAT" * SalesLine1."Qty. to Invoice" / SalesLine1.Quantity,
                                Currency."Amount Rounding Precision");
                            SalesLine1."Unit Price" :=
                              Round(SalesLine1.Amount / SalesLine1."Qty. to Invoice",
                                Currency."Unit-Amount Rounding Precision");
                            IncrAmount(SalesLine1);
                            RetrieveCDSpecification;
                            TransferReportValues(LineValues, SalesLine1, CountryName, CDNo, CountryCode);
                        end else begin
                            SalesLine1."No." := '';
                            TransferLineDescrValues(LineValues, SalesLine1.Description);
                        end;

                        FillBody(LineValues);
                    end;

                    trigger OnPostDataItem()
                    var
                        ResponsiblePerson: array[2] of Text;
                    begin
                        FillRespPerson(ResponsiblePerson);
                        FinalizeReport(TotalAmountText, ResponsiblePerson, Proforma);
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AmountInvoiceCurrent = AmountInvoiceCurrent::"Invoice Currency") and (Header."Currency Code" <> '') then
                            Currency.Get(Header."Currency Code")
                        else
                            Currency.InitRoundingPrecision;

                        VATExemptTotal := true;

                        FillHeader(Proforma);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(TotalAmount);
                end;

                trigger OnPostDataItem()
                begin
                    if not Preview then
                        CODEUNIT.Run(CODEUNIT::"Sales-Printed", Header);
                end;

                trigger OnPreDataItem()
                begin
                    if not SalesLine1.Find('-') then
                        CurrReport.Break();

                    if Header."Posting No." = '' then begin
                        Clear(NoSeriesManagement);
                        Header."Posting No." := NoSeriesManagement.GetNextNo(
                            Header."Posting No. Series", Header."Posting Date", not Preview);
                        if not Preview then
                            Header.Modify();
                    end;

                    SetRange(Number, 1, CopiesNumber);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                TestField(Status);
                Customer.Get("Bill-to Customer No.");

                AmountInvoiceCurrent := AmountInvoiceDone;
                if "Currency Code" = '' then
                    AmountInvoiceCurrent := AmountInvoiceCurrent::LCY;

                if "Document Type" = "Document Type"::"Credit Memo" then
                    Sign := -1
                else
                    Sign := 1;

                SalesLine1.Reset();
                SalesLine1.SetRange("Document Type", "Document Type");
                SalesLine1.SetRange("Document No.", "No.");
                SalesLine1.SetFilter("Attached to Line No.", '<>%1', 0);
                if SalesLine1.FindSet then
                    repeat
                        AttachedSalesLine := SalesLine1;
                        AttachedSalesLine.Insert();
                    until SalesLine1.Next = 0;

                SalesLine1.SetRange("Attached to Line No.", 0);

                if "Currency Code" <> '' then begin
                    if not Currency.Get("Currency Code") then
                        Currency.Description := DollarUSATxt;
                end;

                CurrencyWrittenAmount := GetCurrencyAmtCode("Currency Code", AmountInvoiceCurrent);
                GetCurrencyInfo(CurrencyWrittenAmount, CurrencyDigitalCode, CurrencyDescription);

                if PrintShortAddr("Document Type".AsInteger(), "No.") then
                    InitAddressInfo(ConsignorName, ConsignorAddress, Receiver)
                else begin
                    Receiver[1] := StdRepMgt.GetCustInfo(Header, 0, 1);
                    Receiver[2] := StdRepMgt.GetCustInfo(Header, 1, 1);
                    GetConsignorInfo("Consignor No.", ConsignorName, ConsignorAddress);
                end;

                if "KPP Code" <> '' then
                    KPPCode := "KPP Code"
                else
                    KPPCode := Customer."KPP Code";

                ItemTrackingDocMgt.RetrieveDocumentItemTracking(
                  TrackingSpecBuffer, "No.", DATABASE::"Sales Header", "Document Type".AsInteger());

                if not Preview then begin
                    // IF ArchiveDocument THEN
                    //   ArchiveManagement.StoreSalesDocument(Header,LogInteraction);
                    if LogInteraction then begin
                        CalcFields("No. of Archived Versions");
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Contact, "Bill-to Contact No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                SalesSetup.Get();
                CompanyInfo.Get();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CopiesNumber; CopiesNumber)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';

                        trigger OnValidate()
                        begin
                            if CopiesNumber < 1 then
                                CopiesNumber := 1;
                        end;
                    }
                    field(AmountInvoiceDone; AmountInvoiceDone)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Currency';
                        OptionCaption = 'Invoice Currency,LCY';
                        ToolTip = 'Specifies if the currency code is shown in the report.';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        ToolTip = 'Specifies that interactions with the related contact are logged.';
                    }
                    field(Preview; Preview)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Preview';
                        ToolTip = 'Specifies that the report can be previewed.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            CopiesNumber := 1;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        Proforma := false;
        CopiesNumber := 0;
    end;

    trigger OnPostReport()
    begin
        if FileName <> '' then
            ExportDataFile(FileName)
        else
            ExportData;
    end;

    trigger OnPreReport()
    begin
        if (not CurrReport.UseRequestPage) and (CopiesNumber = 0) then
            CopiesNumber := 1;

        InitReportTemplate(GetTemplateCode(Proforma));
    end;

    var
        DollarUSATxt: Label 'US Dollar';
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        SalesLine1: Record "Sales Line";
        AttachedSalesLine: Record "Sales Line" temporary;
        Currency: Record Currency;
        SalesSetup: Record "Sales & Receivables Setup";
        CDNoInfo: Record "CD No. Information";
        TrackingSpecBuffer: Record "Tracking Specification" temporary;
        TrackingSpecBuffer2: Record "Tracking Specification" temporary;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        LocMgt: Codeunit "Localisation Management";
        StdRepMgt: Codeunit "Local Report Management";
        ArchiveManagement: Codeunit ArchiveManagement;
        SegManagement: Codeunit SegManagement;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
        //FacturaInvoiceHelper: Codeunit "Factura-Invoice Report Helper";
        CurrencyDescription: Text;
        TotalAmount: array[3] of Decimal;
        LastTotalAmount: array[3] of Decimal;
        CopiesNumber: Integer;
        AmountInvoiceDone: Option "Invoice Currency",LCY;
        AmountInvoiceCurrent: Option "Invoice Currency",LCY;
        MultipleCD: Boolean;
        CurrencyWrittenAmount: Code[10];
        ConsignorName: Text;
        ConsignorAddress: Text;
        Sign: Decimal;
        CountryCode: Code[10];
        CountryName: Text;
        ValueMissingErr: Label '%1 is missing for %2 items %3 in line %4.';
        LogInteraction: Boolean;
        ArchiveDocument: Boolean;
        CDNo: Text;
        KPPCode: Code[10];
        Receiver: array[2] of Text;
        VATExemptTotal: Boolean;
        TotalAmountText: array[3] of Text;
        TrackingSpecCount: Integer;
        CurrencyDigitalCode: Code[3];
        Preview: Boolean;
        Proforma: Boolean;
        FileName: Text;
        ExcelReportBuilderMgr: Codeunit "Excel Report Builder Manager";
        SameTxt: Label 'Same';
        PrevDocumentPageNo: Integer;
        CurrentDocumentNo: Text;
        CurrentDocumentDate: Text;
        InvoiceTxt: Label 'Invoice %1 from %2 Page %3';

    [Scope('OnPrem')]
    procedure InitializeRequest(NoOfCopies: Integer; PrintCurr: Option; IsLog: Boolean; IsPreview: Boolean; IsProforma: Boolean)
    begin
        CopiesNumber := NoOfCopies;
        AmountInvoiceDone := PrintCurr;
        LogInteraction := IsLog;
        Preview := IsPreview;
        Proforma := IsProforma;
    end;

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
        ReportValues[1] := SalesLine2.Description;
        ReportValues[2] := '-';
        if UoM.Get(SalesLine2."Unit of Measure Code") then
            ReportValues[2] := StdRepMgt.FormatTextValue(UoM."OKEI Code");
        ReportValues[3] := StdRepMgt.FormatTextValue(SalesLine2."Unit of Measure Code");
        ReportValues[4] := Format(Sign * SalesLine2."Qty. to Invoice");
        ReportValues[5] := StdRepMgt.FormatReportValue(SalesLine2."Unit Price", 2);
        ReportValues[6] := StdRepMgt.FormatReportValue(Sign * SalesLine2.Amount, 2);
        ReportValues[7] := Format(SalesLine1."VAT %");
        ReportValues[8] :=
          StdRepMgt.FormatReportValue(Sign * (SalesLine2."Amount Including VAT" - SalesLine2.Amount), 2);
        ReportValues[9] := StdRepMgt.FormatReportValue(Sign * SalesLine2."Amount Including VAT", 2);
        ReportValues[10] := StdRepMgt.FormatTextValue(CountryCode2);
        ReportValues[11] := StdRepMgt.FormatTextValue(CopyStr(CountryName2, 1));
        ReportValues[12] := StdRepMgt.FormatTextValue(CopyStr(CDNo2, 1));

        if StdRepMgt.VATExemptLine(SalesLine2."VAT Bus. Posting Group", SalesLine2."VAT Prod. Posting Group") then
            StdRepMgt.FormatVATExemptLine(ReportValues[7], ReportValues[7])
        else
            VATExemptTotal := false;

        ReportValues[13] := StdRepMgt.GetEAEUItemTariffNo_SalesLine(SalesLine2);
    end;

    [Scope('OnPrem')]
    procedure TransferHeaderValues(var HeaderValue: array[12] of Text)
    begin
        HeaderValue[1] := StdRepMgt.GetCompanyName;
        HeaderValue[2] := StdRepMgt.GetLegalAddress;
        HeaderValue[3] := CompanyInfo."VAT Registration No." + ' / ' + CompanyInfo."KPP Code";
        HeaderValue[4] := ConsignorName + '  ' + ConsignorAddress;
        HeaderValue[5] := Receiver[1] + '  ' + Receiver[2];
        HeaderValue[6] := StdRepMgt.FormatTextValue(Header."External Document Text");
        HeaderValue[7] := StdRepMgt.GetCustName(Header."Bill-to Customer No.");
        HeaderValue[8] := StdRepMgt.GetCustInfo(Header, 1, 2);
        HeaderValue[9] := Customer."VAT Registration No." + ' / ' + KPPCode;
        HeaderValue[10] := CurrencyDigitalCode;
        HeaderValue[11] := CurrencyDescription;
        HeaderValue[12] := '';
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

    [Scope('OnPrem')]
    procedure RetrieveCDSpecification()
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        CDTrackingSetup: Record "CD Tracking Setup";
        ReservEntry: Record "Reservation Entry";
        ReservEntry2: Record "Reservation Entry";
        TrackedQty: Decimal;
    begin
        MultipleCD := false;
        CDNo := '';
        CountryName := '';
        CountryCode := '';
        TrackedQty := 0;

        case SalesLine1.Type of
            SalesLine1.Type::Item:
                begin
                    Item.Get(SalesLine1."No.");
                    if Item."Item Tracking Code" <> '' then begin
                        SalesLine1.TestField("Appl.-to Item Entry", 0);
                        SalesLine1.TestField("Appl.-from Item Entry", 0);
                        ItemTrackingCode.Code := Item."Item Tracking Code";
                        ItemTrackingMgt.GetItemTrackingSetup(ItemTrackingCode, CDTrackingSetup, 1, false, ItemTrackingSetup);
                        if ItemTrackingSetup."CD No. Required" then begin
                            // find tracking specifiation
                            TrackingSpecBuffer.Reset();
                            TrackingSpecBuffer.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Batch Name",
                              "Source Prod. Order Line", "Source Ref. No.");
                            TrackingSpecBuffer.SetRange("Source Type", DATABASE::"Sales Line");
                            TrackingSpecBuffer.SetRange("Source Subtype", SalesLine1."Document Type");
                            TrackingSpecBuffer.SetRange("Source ID", SalesLine1."Document No.");
                            TrackingSpecBuffer.SetRange("Source Ref. No.", SalesLine1."Line No.");
                            TrackingSpecBuffer2.DeleteAll();
                            if TrackingSpecBuffer.FindSet then
                                repeat
                                    TrackingSpecBuffer2.SetRange("CD No.", TrackingSpecBuffer."CD No.");
                                    if TrackingSpecBuffer2.FindFirst then begin
                                        TrackingSpecBuffer2."Quantity (Base)" += TrackingSpecBuffer."Quantity (Base)";
                                        TrackedQty += TrackingSpecBuffer."Quantity (Base)";
                                        TrackingSpecBuffer2.Modify();
                                    end else begin
                                        TrackingSpecBuffer2.Init();
                                        TrackingSpecBuffer2 := TrackingSpecBuffer;
                                        TrackingSpecBuffer2.TestField("Quantity (Base)");
                                        TrackedQty += TrackingSpecBuffer."Quantity (Base)";
                                        TrackingSpecBuffer2."Lot No." := '';
                                        TrackingSpecBuffer2."Serial No." := '';
                                        TrackingSpecBuffer2.Insert();
                                    end;
                                until TrackingSpecBuffer.Next = 0;
                            TrackingSpecBuffer2.Reset();
                            TrackingSpecCount := TrackingSpecBuffer2.Count();
                            if TrackingSpecCount = 0 then begin
                                // find reservation specification
                                SalesLine1.CalcFields("Reserved Qty. (Base)");
                                if SalesLine1."Reserved Qty. (Base)" <> 0 then begin
                                    ReservEntry.Reset();
                                    ReservEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype");
                                    ReservEntry.SetRange("Source Type", DATABASE::"Sales Line");
                                    ReservEntry.SetRange("Source Subtype", SalesLine1."Document Type");
                                    ReservEntry.SetRange("Source ID", SalesLine1."Document No.");
                                    ReservEntry.SetRange("Source Ref. No.", SalesLine1."Line No.");
                                    if ReservEntry.FindSet then
                                        repeat
                                            ReservEntry2.Get(ReservEntry."Entry No.", not ReservEntry.Positive);
                                            TrackingSpecBuffer2.Init();
                                            TrackingSpecBuffer2.TransferFields(ReservEntry2);
                                            TrackedQty += TrackingSpecBuffer2."Quantity (Base)";
                                            TrackingSpecBuffer2."Lot No." := '';
                                            TrackingSpecBuffer2."Serial No." := '';
                                            TrackingSpecBuffer2.Insert();
                                        until ReservEntry.Next = 0;
                                end;
                            end;

                            if TrackedQty <> SalesLine1."Qty. to Ship (Base)" then
                                Error(ValueMissingErr,
                                  TrackingSpecBuffer2.FieldCaption("CD No."),
                                  SalesLine1."Qty. to Ship (Base)" - TrackedQty,
                                  TrackingSpecBuffer2."Item No.", SalesLine1."Line No.");

                            TrackingSpecBuffer2.Reset();
                            TrackingSpecCount := TrackingSpecBuffer2.Count();
                            case TrackingSpecCount of
                                1:
                                    begin
                                        TrackingSpecBuffer2.FindFirst;
                                        CDNo := TrackingSpecBuffer2."CD No.";
                                        if CDNoInfo.Get(
                                             CDNoInfo.Type::Item, TrackingSpecBuffer2."Item No.",
                                             TrackingSpecBuffer2."Variant Code", TrackingSpecBuffer2."CD No.")
                                        then begin
                                            CountryName := CDNoInfo.GetCountryName;
                                            CountryCode := CDNoInfo.GetCountryLocalCode;
                                        end;
                                    end;
                                else
                                    MultipleCD := true;
                            end;
                        end;
                    end;
                end;
            SalesLine1.Type::"Fixed Asset":
                GetFAInfo(SalesLine1."No.", CDNo, CountryName);
        end;
    end;

    local procedure FillDocHeader(var DocNo: Code[20]; var DocDate: Text; var RevNo: Code[20]; var RevDate: Text)
    var
        CorrDocMgt: Codeunit "Corrective Document Mgt.";
    begin
        with Header do
            if "Corrective Doc. Type" = "Corrective Doc. Type"::Revision then begin
                case "Original Doc. Type" of
                    "Original Doc. Type"::Invoice:
                        DocDate := LocMgt.Date2Text(CorrDocMgt.GetSalesInvHeaderPostingDate("Original Doc. No."));
                    "Original Doc. Type"::"Credit Memo":
                        DocDate := LocMgt.Date2Text(CorrDocMgt.GetSalesCrMHeaderPostingDate("Original Doc. No."));
                end;
                DocNo := "Original Doc. No.";
                RevNo := "Revision No.";
                RevDate := LocMgt.Date2Text("Document Date");
            end else begin
                DocNo := "Posting No.";
                DocDate := LocMgt.Date2Text("Document Date");
                RevNo := '-';
                RevDate := '-';
            end;
    end;

    local procedure FillProformaHeader(var DocNo: Code[20]; var DocDate: Text; var RevNo: Code[20]; var RevDate: Text)
    begin
        with Header do begin
            DocNo := "No.";
            DocDate := LocMgt.Date2Text("Document Date");
            RevNo := '';
            RevDate := '';
        end;
    end;

    local procedure FillHeader(IsProforma: Boolean)
    var
        DocNo: Code[20];
        RevNo: Code[20];
        DocDate: Text;
        RevDate: Text;
        HeaderValues: array[12] of Text;
    begin
        if IsProforma then
            FillProformaHeader(DocNo, DocDate, RevNo, RevDate)
        else
            FillDocHeader(DocNo, DocDate, RevNo, RevDate);
        TransferHeaderValues(HeaderValues);

        FillHeader(DocNo, DocDate, RevNo, RevDate, HeaderValues);

    end;

    local procedure FillBody(LineValue: array[13] of Text)
    begin
        FillBody(LineValue, Proforma);
    end;

    local procedure FillRespPerson(var ResponsiblePerson: array[2] of Text)
    begin
        ResponsiblePerson[1] := StdRepMgt.GetDirectorName(false, 36, Header."Document Type".AsInteger(), Header."No.");
        ResponsiblePerson[2] := StdRepMgt.GetAccountantName(false, 36, Header."Document Type".AsInteger(), Header."No.");
    end;

    local procedure GetTemplateCode(IsProforma: Boolean): Code[10]
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        if IsProforma then begin
            SalesReceivablesSetup.TestField("Proforma Template Code");
            exit(SalesReceivablesSetup."Proforma Template Code");
        end;

        SalesReceivablesSetup.TestField("Factura Template Code");
        exit(SalesReceivablesSetup."Factura Template Code");
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
        PrevDocumentPageNo := 0;
    end;

    [Scope('OnPrem')]
    procedure ExportData()
    begin
        ExcelReportBuilderMgr.ExportData;
    end;

    [Scope('OnPrem')]
    procedure FillHeader(DocNo: Code[20]; DocDate: Text; RevNo: Code[20]; RevDate: Text; HeaderDetails: array[12] of Text)
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

        ExcelReportBuilderMgr.AddSection('PAGEHEADER');

        CurrentDocumentNo := DocNo;
        CurrentDocumentDate := DocDate;
    end;

    [Scope('OnPrem')]
    procedure FillPageHeader()
    begin
        ExcelReportBuilderMgr.AddSection('PAGEHEADER');

        ExcelReportBuilderMgr.AddDataToSection(
          'PageNoTxt',
          StrSubstNo(
            InvoiceTxt, CurrentDocumentNo, CurrentDocumentDate,
            ExcelReportBuilderMgr.GetLastPageNo - PrevDocumentPageNo));
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

        PrevDocumentPageNo := ExcelReportBuilderMgr.GetLastPageNo;
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
            ConsignorName := SameTxt;
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

