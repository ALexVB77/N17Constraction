report 50050 "Create Payment Journal"
{
    ApplicationArea = All;
    Caption = 'Create Payment Journal';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Journal)
                {
                    Caption = 'Journal';
                    field(CurrentJnlBatchName; CurrentJnlBatchName)
                    {
                        ApplicationArea = All;
                        Caption = 'Batch Name';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            GenJnlManagement.LookupName(CurrentJnlBatchName, grGenJournalLine);
                        end;

                        trigger OnValidate()
                        begin
                            GenJnlManagement.CheckName(CurrentJnlBatchName, grGenJournalLine);
                            GenJnlManagement.SetName(CurrentJnlBatchName, grGenJournalLine);
                        end;
                    }
                }
                group(General)
                {
                    Caption = 'General';
                    field(DocDate; DocDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Period';
                    }
                    field(DocNo; DocNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            grPurchaseHeader: Record "Purchase Header";
                            PurchaseListController: Page "Purchase List Controller";
                        begin
                            // grPurchaseHeader.SETRANGE("Line No.", 0); // WTF ????

                            CLEAR(PurchaseListController);
                            PurchaseListController.LOOKUPMODE(TRUE);
                            PurchaseListController.SETTABLEVIEW(grPurchaseHeader);
                            IF PurchaseListController.RUNMODAL = ACTION::LookupOK THEN begin
                                PurchaseListController.SetSelectionFilter(grPurchaseHeader);
                                if grPurchaseHeader.FindSet() then
                                    repeat
                                        if DocNo = '' then
                                            DocNo := grPurchaseHeader."No."
                                        else
                                            DocNo := StrSubstNo('%1|%2', DocNo, grPurchaseHeader."No.");
                                    until grPurchaseHeader.next = 0;
                            end;
                        end;
                    }
                    field(VendorCode; VendorCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor';
                        TableRelation = Vendor;
                    }
                    field(AgreementNo; AgreementNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Agreements';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            grVendAgreements: Record "Vendor Agreement";
                        begin
                            grVendAgreements.SETFILTER("Vendor No.", VendorCode);
                            IF Page.RUNMODAL(Page::"Vendor Agreements", grVendAgreements) = ACTION::LookupOK THEN
                                AgreementNo := grVendAgreements."No.";
                        end;
                    }
                    field(CurrencyCode; CurrencyCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Currency';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            grCurrency: Record Currency;
                        begin
                            IF Page.RUNMODAL(0, grCurrency) = ACTION::LookupOK THEN
                                CurrencyCode := grCurrency.Code;
                        end;
                    }
                }
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    field(CostPlace; CostPlace)
                    {
                        ApplicationArea = All;
                        Caption = 'Cost Place';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            DimValue: record "Dimension Value";
                        begin
                            PurchSetup.TestField("Cost Place Dimension");
                            DimValue.SetRange("Dimension Code", PurchSetup."Cost Place Dimension");
                            if Page.RunModal(0, DimValue) = Action::LookupOK then
                                CostPlace := DimValue.Code;
                        end;
                    }
                    field(CostCode; CostCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Cost Code';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            DimValue: record "Dimension Value";
                        begin
                            PurchSetup.TestField("Cost Code Dimension");
                            DimValue.SetRange("Dimension Code", PurchSetup."Cost Code Dimension");
                            if Page.RunModal(0, DimValue) = Action::LookupOK then
                                CostCode := DimValue.Code;
                        end;
                    }
                }
                group(Information)
                {
                    Caption = 'Information';
                    field(LinesQty; GetLinesQty)
                    {
                        ApplicationArea = All;
                        Caption = 'Qty. lines';

                        trigger OnDrillDown()
                        begin

                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            IF gvBath <> '' THEN
                CurrentJnlBatchName := gvBath;
            PurchSetup.Get();
        end;
    }

    trigger OnInitReport()
    var
        grGenJournalTemplate: Record "Gen. Journal Template";
        TemplType: Enum "Gen. Journal Template Type";
        JnlSelected: Boolean;
    begin
        GenJnlManagement.TemplateSelection(Page::"Payment Journal", TemplType::Payments, FALSE, grGenJournalLine, JnlSelected);
        IF NOT JnlSelected THEN
            ERROR('');
        GenJnlManagement.OpenJnl(CurrentJnlBatchName, grGenJournalLine);
        grGenJournalTemplate.SETRANGE("Page ID", Page::"Payment Journal");
        grGenJournalTemplate.SETRANGE(Type, grGenJournalTemplate.Type::Payments);
        IF grGenJournalTemplate.FINDFIRST THEN
            CurrentJnlTmplName := grGenJournalTemplate.Name;
    end;

    trigger OnPreReport()
    begin
        CreateJournal();
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        grGenJournalLine: Record "Gen. Journal Line";
        GenJnlManagement: Codeunit GenJnlManagement;
        CurrentJnlTmplName, CurrentJnlBatchName, VendorCode, gvBath : code[20];
        DocNo, DocDate, AgreementNo, CostCode, CostPlace, CurrencyCode : text;

    local procedure SetPurchHeaderFilters(var PurchaseHeader: record "Purchase Header");
    begin
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SETRANGE(Paid, FALSE);
        PurchaseHeader.SETRANGE("Status App", PurchaseHeader."Status App"::Payment);
        IF CurrencyCode <> '' THEN
            PurchaseHeader.SETFILTER("Currency Code", CurrencyCode);
        IF DocNo <> '' THEN
            PurchaseHeader.SETFILTER("No.", DocNo);
        IF VendorCode <> '' THEN
            PurchaseHeader.SETFILTER("Buy-from Vendor No.", VendorCode);
        IF AgreementNo <> '' THEN
            PurchaseHeader.SETFILTER("Agreement No.", AgreementNo);
        IF CostPlace <> '' THEN
            PurchaseHeader.SETFILTER("Shortcut Dimension 1 Code", CostPlace);
        IF CostCode <> '' THEN
            PurchaseHeader.SETFILTER("Shortcut Dimension 2 Code", CostCode);
        IF DocDate <> '' THEN
            PurchaseHeader.SETFILTER("Due Date", DocDate);
        // PurchaseHeader.SETRANGE("Line No.", 0);   // WTF ????
    end;

    local procedure GetLinesQty(): Integer
    var
        lrPurchaseHeader: Record "Purchase Header";
    begin
        SetPurchHeaderFilters(lrPurchaseHeader);
        IF not lrPurchaseHeader.IsEmpty THEN
            exit(lrPurchaseHeader.COUNT);
    end;

    local procedure LinesQtyDrillDown()
    var
        lrPurchaseHeader: Record "Purchase Header";
    begin
        lrPurchaseHeader.FilterGroup(2);
        SetPurchHeaderFilters(lrPurchaseHeader);
        lrPurchaseHeader.FilterGroup(0);
        IF lrPurchaseHeader.FINDFIRST THEN
            Page.RUNMODAL(Page::"Purchase List Controller", lrPurchaseHeader);
    end;

    local procedure CreateJournal()
    var
        lrPurchaseHeader: Record "Purchase Header";
        PayOrderMgt: Codeunit "Payment Order Management";
        NewLinesCount: Integer;
        TEXT0001: Label 'Create a payment journal?';
        TEXT0002: Label 'Added %1 lines.';
    begin
        IF NOT CONFIRM(TEXT0001) THEN
            EXIT;

        lrPurchaseHeader.FilterGroup(2);
        SetPurchHeaderFilters(lrPurchaseHeader);
        lrPurchaseHeader.FilterGroup(0);

        NewLinesCount := PayOrderMgt.CreateJournalLineFromPaymentInvoice(CurrentJnlTmplName, CurrentJnlBatchName, lrPurchaseHeader);
        if NewLinesCount <> 0 then
            MESSAGE(TEXT0002, NewLinesCount);
    end;

    procedure SetBath(VAR pBath: Code[20])
    begin
        gvBath := pBath;
    end;
}