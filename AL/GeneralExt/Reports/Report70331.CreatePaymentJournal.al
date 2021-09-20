report 70331 "Create Payment Journal"
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
                            // grPurchaseHeader.SETRANGE("Line No.", 0); - не используем, т.к. могут быть частично оплаченные, используем проверку по сумме (ниже)
                            CLEAR(PurchaseListController);
                            PurchaseListController.LOOKUPMODE(TRUE);
                            PurchaseListController.SETTABLEVIEW(grPurchaseHeader);
                            IF PurchaseListController.RUNMODAL = ACTION::LookupOK THEN begin
                                PurchaseListController.SetSelectionFilter(grPurchaseHeader);
                                if grPurchaseHeader.FindSet() then
                                    repeat
                                        grPurchaseHeader.CalcFields("Payments Amount", "Journal Payments Amount");
                                        if grPurchaseHeader."Invoice Amount Incl. VAT" - grPurchaseHeader."Payments Amount" - grPurchaseHeader."Journal Payments Amount" > 0 then begin
                                            if DocNo = '' then
                                                DocNo := grPurchaseHeader."No."
                                            else
                                                DocNo := StrSubstNo('%1|%2', DocNo, grPurchaseHeader."No.");
                                        end;
                                    until grPurchaseHeader.next = 0;
                            end;
                        end;
                    }
                    field(VendorCode; VendorCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor';
                        TableRelation = Vendor;
                        Visible = false;
                    }
                    field(AgreementNo; AgreementNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Agreements';
                        Visible = false;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            grVendAgreements: Record "Vendor Agreement";
                        begin
                            grVendAgreements.SETFILTER("Vendor No.", VendorCode);
                            IF Page.RUNMODAL(Page::"Vendor Agreements", grVendAgreements) = ACTION::LookupOK THEN
                                AgreementNo := Text + grVendAgreements."No.";
                        end;
                    }
                    field(CurrencyCode; CurrencyCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Currency';
                        Visible = false;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            grCurrency: Record Currency;
                        begin
                            IF Page.RUNMODAL(0, grCurrency) = ACTION::LookupOK THEN
                                CurrencyCode := Text + grCurrency.Code;
                        end;
                    }
                    field(SpecBankAccoNo; SpecBankAccoNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Spec. Bank Account No.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            BankAcc: Record "Bank Account";
                        begin
                            IF Page.RUNMODAL(0, BankAcc) = ACTION::LookupOK THEN
                                SpecBankAccoNo := Text + BankAcc."No.";
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
                                CostPlace := Text + DimValue.Code;
                        end;
                    }
                    field(CostCode; CostCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Cost Code';
                        Visible = false;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            DimValue: record "Dimension Value";
                        begin
                            PurchSetup.TestField("Cost Code Dimension");
                            DimValue.SetRange("Dimension Code", PurchSetup."Cost Code Dimension");
                            if Page.RunModal(0, DimValue) = Action::LookupOK then
                                CostCode := Text + DimValue.Code;
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
            PurchSetup.Get();
        end;
    }

    trigger OnPreReport()
    begin
        CreateJournal();
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        grGenJournalLine: Record "Gen. Journal Line";
        GenJnlManagement: Codeunit GenJnlManagement;
        CurrentJnlTmplName, CurrentJnlBatchName, VendorCode : code[20];
        DocNo, DocDate, AgreementNo, CostCode, CostPlace, CurrencyCode, SpecBankAccoNo : text;

    local procedure SetPurchHeaderFilters(var PurchaseHeader: record "Purchase Header");
    begin
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
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
        if SpecBankAccoNo <> '' then
            PurchaseHeader.SetFilter("Spec. Bank Account No.", SpecBankAccoNo);

        // PurchaseHeader.SETRANGE(Paid, FALSE);
        if not PurchaseHeader.IsEmpty then begin
            PurchaseHeader.FindSet();
            repeat
                PurchaseHeader.CalcFields("Payments Amount", "Journal Payments Amount");
                if PurchaseHeader."Invoice Amount Incl. VAT" - PurchaseHeader."Payments Amount" - PurchaseHeader."Journal Payments Amount" > 0 then
                    PurchaseHeader.Mark(true);
            until PurchaseHeader.Next() = 0;
            PurchaseHeader.MarkedOnly(true);
        end;

        // PurchaseHeader.SETRANGE("Line No.", 0); - не используем, т.к. могут быть частично оплаченные, используем проверку по сумме
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
        // IF NOT CONFIRM(TEXT0001) THEN
        //     EXIT;

        lrPurchaseHeader.FilterGroup(2);
        SetPurchHeaderFilters(lrPurchaseHeader);
        lrPurchaseHeader.FilterGroup(0);

        NewLinesCount := PayOrderMgt.CreateJournalLineFromPaymentInvoice(CurrentJnlTmplName, CurrentJnlBatchName, lrPurchaseHeader);
        if NewLinesCount <> 0 then
            MESSAGE(TEXT0002, NewLinesCount);
    end;

    procedure SetParam(JnlTmplName: Code[20]; JnlBatchName: Code[20])
    begin
        CurrentJnlTmplName := JnlTmplName;
        CurrentJnlBatchName := JnlBatchName;
    end;
}