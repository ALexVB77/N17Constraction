codeunit 50006 "Base App. Subscribers Mgt."
{
    // t 17 >>
    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure onAfterModifyT17(Rec: record "G/L Entry"; xRec: record "G/L Entry"; RunTrigger: boolean)
    var
        gleVeLink: record "G/L Entry - VAT Entry Link";
        ve: record "Vat Entry";
    begin
        if not Rec.IsTemporary() then begin
            if (Rec."Global Dimension 1 Code" <> xRec."Global Dimension 1 Code") or (Rec."Global Dimension 2 Code" <> xRec."Global Dimension 2 Code") then begin
                gleVeLink.reset();
                gleVeLink.setrange("G/L Entry No.", Rec."Entry No.");
                if (gleVeLink.findset()) then begin
                    repeat
                        if (ve.get(gleVeLink."VAT Entry No.")) then begin
                            ve.validate("Global Dimension 1 Code", Rec."Global Dimension 1 Code");
                            ve.validate("Global Dimension 2 Code", Rec."Global Dimension 2 Code");
                            ve.modify(true);
                        end;
                    until (gleVeLink.next() = 0);
                end;

            end;
        end;
    end;
    // t 17 <<

    // t 81 >>
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Prepayment', false, false)]
    local procedure onAfterValidatePrepayment(Rec: Record "Gen. Journal Line"; xRec: Record "Gen. Journal Line"; CurrFieldNo: Integer)
    begin
        if Rec.Prepayment then begin
            if (xRec."Prepayment Document No." = '') then begin
                Rec."Prepayment Document No." := '';
                SetPrepaymentDoc(Rec);
            end;
        end;

    end;

    local procedure SetPrepaymentDoc(var GenJnlLine2: Record "Gen. Journal Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        ReleaseDoc: Codeunit "Release Sales Document";
        LText001: Label 'Advance %1';
        Text50000: label 'Create sales invoice?';
    begin
        //NC 23904 HR beg
        IF NOT CONFIRM(Text50000, FALSE) THEN
            EXIT;

        SalesSetup.GET;
        SalesSetup.TESTFIELD("Invoice Nos.");
        SalesSetup.TESTFIELD("Prepay. Inv. G/L Acc. No. (ac)");

        SalesHeader.INIT;
        SalesHeader.VALIDATE("No. Series", SalesSetup."Invoice Nos.");
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.VALIDATE("Posting Date", GenJnlLine2."Posting Date");
        SalesHeader."No." := '';
        SalesHeader.INSERT(TRUE);

        SalesHeader."External Document No." := GenJnlLine2."Document No.";
        SalesHeader.VALIDATE("Sell-to Customer No.", GenJnlLine2."Account No.");
        SalesHeader.VALIDATE("Agreement No.", GenJnlLine2."Agreement No.");
        SalesHeader."Posting Description" :=
          COPYSTR(STRSUBSTNO(LText001, GenJnlLine2.Description), 1, MAXSTRLEN(SalesHeader."Posting Description"));
        SalesHeader.VALIDATE("Shortcut Dimension 1 Code", GenJnlLine2."Shortcut Dimension 1 Code");
        SalesHeader.VALIDATE("Shortcut Dimension 2 Code", GenJnlLine2."Shortcut Dimension 2 Code");
        SalesHeader.MODIFY(TRUE);

        SalesLine.INIT;
        SalesLine.VALIDATE("Document Type", SalesHeader."Document Type");
        SalesLine.VALIDATE("Document No.", SalesHeader."No.");
        SalesLine."Line No." := 10000;
        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        //SalesLine.VALIDATE("Bill-to Customer No.", SalesHeader."Bill-to Customer No.");
        SalesLine.VALIDATE(Type, SalesLine.Type::"G/L Account");
        SalesLine.VALIDATE("No.", SalesSetup."Prepay. Inv. G/L Acc. No. (ac)"); //'901034110'
        SalesLine.VALIDATE(Quantity, 1);
        SalesLine.VALIDATE("Unit of Measure Code", 'УСЛ');
        SalesLine.VALIDATE("Unit Price", ABS(GenJnlLine2.Amount));
        SalesLine.INSERT(TRUE);

        ReleaseDoc.RUN(SalesHeader);

        GenJnlLine2.VALIDATE("Prepayment Document No.", SalesHeader."No.");

        Page.RUN(page::"Sales Invoice", SalesHeader);

        //NC 23904 HR end
    end;
    // t 81 <<

    // t 179 >>
    [EventSubscriber(ObjectType::Table, Database::"Reversal Entry", 'onAfterSetRegisterReverseFilter', '', false, false)]
    local procedure onAfterSetRegisterReverseFilter(
        var GLEntry: Record "G/L Entry";
        var CustLedgEntry: Record "Cust. Ledger Entry";
        var VendLedgEntry: Record "Vendor Ledger Entry";
        var BankAccLedgEntry: Record "Bank Account Ledger Entry";
        var VATEntry: Record "VAT Entry";
        var FALedgEntry: Record "FA Ledger Entry";
        var MaintenanceLedgEntry: Record "Maintenance Ledger Entry";
        var ValueEntry: Record "Value Entry";
        var TaxDiffLedgEntry: Record "Tax Diff. Ledger Entry"
    )
    begin

        //CSS GS 21.02.2012 >>
        GLEntry.SETRANGE(Reversed, FALSE);
        CustLedgEntry.SETRANGE(Reversed, FALSE);
        VendLedgEntry.SETRANGE(Reversed, FALSE);
        BankAccLedgEntry.SETRANGE(Reversed, FALSE);
        FALedgEntry.SETRANGE(Reversed, FALSE);
        MaintenanceLedgEntry.SETRANGE(Reversed, FALSE);
        VATEntry.SETRANGE(Reversed, FALSE);
        ValueEntry.SETRANGE(Reversed, FALSE);
        TaxDiffLedgEntry.SETRANGE(Reversed, FALSE);
        //CSS GS 21.02.2012 <<
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reversal Entry", 'OnBeforeReverseEntries', '', false, false)]
    local procedure OnBeforeReverseEntries(Number: Integer; RevType: Integer; var IsHandled: Boolean);
    var
        vatEntry: Record "VAT Entry";
        Text50000: label 'Нельзя сторнировать, так как есть НДС операции с типом распределения НДС Расходы';
    begin
        IsHandled := false; // NC GG: false специально, это не ошибка!
        VATEntry.SetRange("Transaction No.", Number);
        VATEntry.SetRange("VAT Allocation Type", VATEntry."VAT Allocation Type"::Charge);
        if not VATEntry.IsEmpty then
            Error(Text50000);
    end;

    // t 179 <<

    // t 253 >>
    [EventSubscriber(ObjectType::Table, Database::"G/L Entry - VAT Entry Link", 'OnAfterInsertEvent', '', false, false)]
    local procedure onAfterInsertT253(Rec: record "G/L Entry - VAT Entry Link"; RunTrigger: boolean)
    var
        gle: Record "G/L Entry";
        ve: Record "Vat Entry";
    begin
        if not rec.IsTemporary() then begin
            if (gle.get(rec."G/L Entry No.")) and (ve.get(rec."VAT Entry No.")) then begin
                ve.validate("Global Dimension 1 Code", gle."Global Dimension 1 Code");
                ve.validate("Global Dimension 2 Code", gle."Global Dimension 2 Code");
                ve.modify(true);
            end;
        end;

    end;
    // t 253 << 

    // t 5740 >>
    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterInitRecord', '', false, false)]
    local procedure onAfterInitRecord(var TransferHeader: Record "Transfer Header");
    var
        StorekeeperLocation: Record "Warehouse Employee";
        DefaultLocation: Code[20];
    begin
        //if not RunTrigger then exit;

        //NC 22512 > DP
        DefaultLocation := StorekeeperLocation.GetDefaultLocation('', false);
        IF DefaultLocation <> '' THEN BEGIN
            // xRec."Transfer-from Code" := '';
            TransferHeader.SetHideValidationDialog(TRUE);
            TransferHeader.VALIDATE("Transfer-from Code", DefaultLocation);
            TransferHeader.SetHideValidationDialog(FALSE);
            //TransferHeader.modify();
        END;
        //NC 22512 < DP
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnUpdateTransLines', '', false, false)]
    local procedure OnUpdateTransLines(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; FieldID: Integer);
    var
        Location: Record Location;
    begin
        case FieldID of
            TransferHeader.FieldNo("Vendor No."):
                begin
                    //NC 22512 > DP
                    IF Location.GET(TransferLine."Transfer-to Code") AND Location."Bin Mandatory" THEN
                        TransferLine.VALIDATE("Transfer-To Bin Code", TransferHeader."Vendor No.");
                    //NC 22512 < DP
                end;
            // NC 51144 GG >>
            TransferHeader.FieldNo("New Shortcut Dimension 1 Code"):
                begin
                    TransferLine.Validate("New Shortcut Dimension 1 Code", TransferHeader."New Shortcut Dimension 1 Code");
                end;
            TransferHeader.FieldNo("New Shortcut Dimension 2 Code"):
                begin
                    TransferLine.Validate("New Shortcut Dimension 2 Code", TransferHeader."New Shortcut Dimension 2 Code");
                end;
        // NC 51144 GG <<
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'onLookupTransferFromCode', '', false, false)]
    local procedure onLookupTransferFromCode(var TransHeader: Record "Transfer Header");
    var
        ERPCFuntions: Codeunit "ERPC Funtions";
    begin
        //NC 22512 > DP
        IF ERPCFuntions.LookUpLocationCode(TransHeader."Transfer-from Code") THEN TransHeader.VALIDATE("Transfer-from Code");
        //NC 22512 < DP
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterGetNoSeriesCode', '', false, false)]
    local procedure OnAfterGetNoSeriesCodeTransferHeader(var TransferHeader: Record "Transfer Header"; var NoSeriesCode: Code[20]);
    var
        InventorySetup: Record "Inventory Setup";
    begin
        // NC 51410 > EP
        // Используем отдельную серию номеров для заказов на передачу материалов в переработку
        if TransferHeader."Giv. Type" = TransferHeader."Giv. Type"::"To Contractor" then begin
            InventorySetup.Get();
            InventorySetup.TestField("Giv. Transfer Order Nos.");
            NoSeriesCode := InventorySetup."Giv. Transfer Order Nos.";
        end;
        // NC 51410 < EP
    end;

    // t 5740 <<

    // t 12450 >>

    [EventSubscriber(ObjectType::Table, Database::"Item Document Header", 'onAfterInitRecord', '', false, false)]
    local procedure onAfterInitRecordIDH(var ItemDocumentHeader: Record "Item Document Header")
    var
        StorekeeperLocation: Record "Warehouse Employee";
        DefaultLocation: Code[20];
    begin
        //if not RunTrigger then exit;

        //NC 22512 > DP
        DefaultLocation := StorekeeperLocation.GetDefaultLocation('', false);
        IF DefaultLocation <> '' THEN begin
            ItemDocumentHeader.VALIDATE("Location Code", DefaultLocation);
            //ItemDocumentHeader.modify();
        end;
        //NC 22512 < DP
    end;


    [EventSubscriber(ObjectType::Table, Database::"Item Document Header", 'onLookupLocationCode', '', false, false)]
    local procedure onLookupLocationCode(var ItemDocumentHeader: Record "Item Document Header");
    var
        ERPCFuntions: Codeunit "ERPC Funtions";
    begin
        //NC 22512 > DP
        IF ERPCFuntions.LookUpLocationCode(ItemDocumentHeader."Location Code") THEN ItemDocumentHeader.VALIDATE("Location Code");
        //NC 22512 < DP
    end;

    // t 12450 <<
    // t 12477 >>
    [EventSubscriber(ObjectType::Table, Database::"FA Document Line", 'OnAfterValidateEvent', 'Posting Date', false, false)]
    local procedure onAfterValidatePostingDate(var Rec: Record "Fa Document Line");
    begin
        Rec.CalcQty();
    end;
    // t 12477 <<

    // cu 12 >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertVAT', '', false, false)]
    local procedure OnBeforeInsertVAT(var GenJournalLine: Record "Gen. Journal Line"; var VATEntry: Record "VAT Entry"; var UnrealizedVAT: Boolean; var AddCurrencyCode: Code[10]; var VATPostingSetup: Record "VAT Posting Setup"; var GLEntryAmount: Decimal; var GLEntryVATAmount: Decimal; var GLEntryBaseAmount: Decimal; var SrcCurrCode: Code[10]; var SrcCurrGLEntryAmt: Decimal; var SrcCurrGLEntryVATAmt: Decimal; var SrcCurrGLEntryBaseAmt: Decimal);
    var
        ism: Codeunit "Isolated Storage Management GE";
    begin
        ism.init();
        ism.setBool('VatAllocation', VATPostingSetup."VAT Allocation");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertVATOnAfterAssignVATEntryFields', '', false, false)]
    local procedure OnInsertVATOnAfterAssignVATEntryFields(GenJnlLine: Record "Gen. Journal Line"; var VATEntry: Record "VAT Entry"; CurrExchRate: Record "Currency Exchange Rate");
    var
        ism: Codeunit "Isolated Storage Management GE";
    begin
        ism.getBool('VatAllocation', VATEntry."VAT Allocation", true);
    end;


    // cu 12 <<

    // cu 241 >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean);
    var
        ism: Codeunit "Isolated Storage Management GE";
    begin
        ism.getBool('NotAsk', HideDialog, true);
    end;

    // cu 241 <<

    // cu 367 >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::CheckManagement, 'OnBeforeVoidCheckGenJnlLine2Modify', '', false, false)]
    local procedure OnBeforeVoidCheckGenJnlLine2Modify(var GenJournalLine2: Record "Gen. Journal Line"; GenJournalLine: Record "Gen. Journal Line");
    begin
        GenJournalLine2."Document No." := GenJournalLine."Document No.";
    end;

    // cu 367 <<
    [EventSubscriber(ObjectType::Table, DATABASE::"Report Selections", 'OnBeforeSetReportLayoutCustom', '', true, true)]
    local procedure SetDocumentPrintBufferUserFilter(RecordVariant: Variant; ReportUsage: Integer; var DocumentPrintBuffer: Record "Document Print Buffer")
    begin
        DocumentPrintBuffer.SetRange("User ID", UserId());
        if DocumentPrintBuffer.FindFirst() then;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Document-Post", 'OnBeforePostFAReleaseMovement', '', false, false)]
    local procedure CustomPostFAReleaseMovement(sender: Codeunit "FA Document-Post"; DocType: Option; var FADocLine: Record "FA Document Line"; var FADeprBook: Record "FA Depreciation Book"; var FADeprBook2: Record "FA Depreciation Book"; var FAReclassJnlLine: Record "FA Reclass. Journal Line"; var FAJnlSetup: Record "FA Journal Setup"; var GenJnlLine: Record "Gen. Journal Line"; var TaxRegisterSetup: Record "Tax Register Setup"; var FA: Record "Fixed Asset"; var FAJnlLine: Record "FA Journal Line"; var PostedFADocHeader: Record "Posted FA Doc. Header"; var FAReclassCheckLine: Codeunit "FA Reclass. Check Line"; var FAReclassTransferLine: Codeunit "FA Reclass. Transfer Line"; var DimMgt: Codeunit DimensionManagement; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var FAJnlPostLine: Codeunit "FA Jnl.-Post Line"; var ReclassDone: Boolean; var PreviewMode: Boolean; var IsHandled: Boolean)
    var
        FADocHeader: Record "FA Document Header";
        FAReclassTransferLineExt: Codeunit "FA Reclass. Transfer Line Ext";
    begin
        if (DocType = FADocHeader."Document Type"::Release) or
           (FADocLine."FA No." <> FADocLine."New FA No.") or
           (FADocLine."Depreciation Book Code" <> FADocLine."New Depreciation Book Code") or // reclassification
           (FADocLine."FA Posting Group" <> FADocLine."New FA Posting Group")
        then begin
            FADeprBook.Get(FADocLine."FA No.", FADocLine."Depreciation Book Code");
            FADeprBook2.Get(FADocLine."New FA No.", FADocLine."New Depreciation Book Code");
            if (DocType = FADocHeader."Document Type"::Release) or
                (FADocLine."FA No." <> FADocLine."New FA No.") or
                (FADocLine."Depreciation Book Code" <> FADocLine."New Depreciation Book Code")
            then begin
                FADeprBook2."Depreciation Starting Date" := CalcDate('<CM+1D>', FADocLine."FA Posting Date");
                if FADeprBook."No. of Depreciation Years" > 0 then
                    FADeprBook2.Validate("No. of Depreciation Years", FADeprBook."No. of Depreciation Years")
                else
                    FADeprBook2.Validate("No. of Depreciation Years");
            end;
            FADeprBook2.Modify();

            FAReclassJnlLine.Init();
            FAReclassJnlLine.Validate("FA No.", FADocLine."FA No.");
            if FADocLine."New FA No." <> '' then
                FAReclassJnlLine.Validate("New FA No.", FADocLine."New FA No.")
            else
                FAReclassJnlLine.Validate("New FA No.", FADocLine."FA No.");
            FAReclassJnlLine."FA Posting Date" := FADocLine."FA Posting Date";
            FAReclassJnlLine."Posting Date" := FADocLine."Posting Date";
            FAReclassJnlLine."Depreciation Book Code" := FADocLine."Depreciation Book Code";
            FAReclassJnlLine."New Depreciation Book Code" := FADocLine."New Depreciation Book Code";
            FAReclassJnlLine.Description := FADocLine.Description;
            FAReclassJnlLine."Document No." := PostedFADocHeader."No.";
            FAReclassJnlLine."FA Location Code" := FADocLine."FA Location Code";
            FAReclassJnlLine."Employee No." := FADocLine."FA Employee No.";
            FAReclassJnlLine."FA Posting Group" := FADocLine."FA Posting Group";
            FAReclassJnlLine."New FA Posting Group" := FADocLine."New FA Posting Group";
            FAReclassJnlLine.Validate(Quantity, FADocLine.Quantity);
            FAReclassJnlLine."Reclassify Acquisition Cost" := true;
            FAReclassJnlLine."Reclassify Write-Down" := true;
            FAReclassJnlLine."Reclassify Appreciation" := true;
            FAReclassJnlLine."Reclassify Depreciation" := DocType = FADocHeader."Document Type"::Movement;
            FAReclassCheckLine.Run(FAReclassJnlLine);
            FAReclassTransferLineExt.FAReclassLine(FAReclassJnlLine, ReclassDone);

            if (FADocLine."New FA Posting Group" <> '') and (FADeprBook2."FA Posting Group" <> FADocLine."New FA Posting Group") then begin
                FADeprBook2.Get(FADocLine."New FA No.", FADocLine."New Depreciation Book Code");
                FADeprBook2."FA Posting Group" := FADocLine."New FA Posting Group";
                FADeprBook2.modify;
            end;

            // Post G/L or FA Journal Lines
            Clear(FAJnlSetup);
            if not FAJnlSetup.Get(FADocLine."Depreciation Book Code", UserId) then
                FAJnlSetup.Get(FADocLine."Depreciation Book Code", '');

            GenJnlLine.SetRange("Document No.", PostedFADocHeader."No.");
            GenJnlLine.SetRange("Object Type", GenJnlLine."Account Type"::"Fixed Asset");
            GenJnlLine.SetRange("Object No.", FADocLine."FA No.");
            if GenJnlLine.FindSet then begin
                repeat
                    GenJnlLine."Shortcut Dimension 1 Code" := FADocLine."Shortcut Dimension 1 Code";
                    GenJnlLine."Shortcut Dimension 2 Code" := FADocLine."Shortcut Dimension 2 Code";
                    GenJnlLine."Dimension Set ID" := FADocLine."Dimension Set ID";
                    GenJnlLine."Reason Code" := FADocLine."Reason Code";
                    GenJnlLine."Tax Difference Code" := TaxRegisterSetup."Default FA TD Code";
                    if GenJnlLine.Quantity < 1 then
                        GetFADefaultDim(
                          FA."No.",
                          GenJnlLine."Shortcut Dimension 1 Code",
                          GenJnlLine."Shortcut Dimension 2 Code",
                          GenJnlLine."Dimension Set ID",
                          FADocLine."Source Code",
                          DimMgt);

                    GenJnlPostLine.SetPreviewMode(PreviewMode);
                    GenJnlPostLine.RunWithCheck(GenJnlLine);
                until GenJnlLine.Next = 0;
                GenJnlLine.DeleteAll(true);
            end;

            FAJnlLine.SetRange("Document No.", PostedFADocHeader."No.");
            FAJnlLine.SetRange("FA No.", FADocLine."FA No.");
            if FAJnlLine.FindSet then begin
                repeat
                    FAJnlLine."Shortcut Dimension 1 Code" := FADocLine."Shortcut Dimension 1 Code";
                    FAJnlLine."Shortcut Dimension 2 Code" := FADocLine."Shortcut Dimension 2 Code";
                    FAJnlLine."Dimension Set ID" := FADocLine."Dimension Set ID";
                    FAJnlPostLine.FAJnlPostLine(FAJnlLine, true);
                until FAJnlLine.Next = 0;
                FAJnlLine.DeleteAll(true);
            end;
        end else // Just FA Entry posting
            sender.FAPostTransfer(FADocLine, true);
        FA.Get(FADocLine."FA No.");
        FA.Validate("Global Dimension 1 Code", FADocLine."Shortcut Dimension 1 Code");
        FA.Validate("Global Dimension 2 Code", FADocLine."Shortcut Dimension 2 Code");
        if DocType = FADocHeader."Document Type"::Release then begin
            FA.Status := FA.Status::Operation;
            FA."Initial Release Date" := PostedFADocHeader."FA Posting Date";
        end;
        if DocType = FADocHeader."Document Type"::Movement then begin
            FA.Status := FADocLine.Status;
            FA."Status Date" := PostedFADocHeader."FA Posting Date";
        end;
        FA."Status Document No." := PostedFADocHeader."No.";
        FA.Modify();

        IsHandled := true;
    end;

    local procedure GetFADefaultDim(FANo: Code[20]; var GlobalDimCode1: Code[20]; var GlobalDimCode2: Code[20]; var DimSetID: Integer; SourceCode: Code[20]; var DimMgt: Codeunit DimensionManagement)
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        TableID[1] := DATABASE::"Fixed Asset";
        No[1] := FANo;
        GlobalDimCode1 := '';
        GlobalDimCode2 := '';
        DimSetID := DimMgt.GetDefaultDimID(TableID, No, SourceCode, GlobalDimCode1, GlobalDimCode2, 0, 0);
    end;
    // cu 5600 >>
    [EventSubscriber(ObjectType::Codeunit, COdeunit::"FA Insert Ledger Entry", 'OnBeforeCheckFADocNo', '', true, true)]
    local procedure CheckFADocNo(FALedgEntry: Record "FA Ledger Entry"; var IsHandled: Boolean)
    var
        FA: Record "Fixed Asset";
        OldFALedgEntry: Record "FA Ledger Entry";
        FALedgEntry2: Record "FA Ledger Entry";
        DepreciationCalc: Codeunit "Depreciation Calculation";
        ErrText001: Label '%1 = %2 already exists for %5 (%3 = %4).';
    begin
        if FA.Get(FALedgEntry."FA No.") then;
        OldFALedgEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Document No.");
        OldFALedgEntry.SetRange("FA No.", FALedgEntry."FA No.");
        OldFALedgEntry.SetRange("Depreciation Book Code", FALedgEntry."Depreciation Book Code");
        OldFALedgEntry.SetRange("FA Posting Category", FALedgEntry."FA Posting Category");
        OldFALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type");
        OldFALedgEntry.SetRange("Document No.", FALedgEntry."Document No.");
        OldFALedgEntry.SetRange("Entry No.", 0, FALedgEntry2.GetLastEntryNo());
        OldFALedgEntry.SetRange("FA Posting Group", FALedgEntry."FA Posting Group");
        if OldFALedgEntry.FindFirst then
            Error(
              ErrText001,
              OldFALedgEntry.FieldCaption("Document No."),
              OldFALedgEntry."Document No.",
              OldFALedgEntry.FieldCaption("FA Posting Type"),
              OldFALedgEntry."FA Posting Type",
              DepreciationCalc.FAName(FA, FALedgEntry."Depreciation Book Code"));

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, COdeunit::"FA Insert Ledger Entry", 'OnBeforeClearTransactionNoInFALedgEntry', '', true, true)]
    local procedure onBeforeClearTransactionNoInFALedgEntry(FALedgEntry: Record "FA Ledger Entry"; FALedgEntry2: Record "FA Ledger Entry"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    // cu 5600 <<

    // cu 12411 >>

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Settlement Management", 'onAfterInsertGenJnlLine', '', false, false)]
    local procedure onAfterInsertGenJnlLine(cvLedgerEntryNo: integer; vatEntryNo: integer; dimDetId: integer)
    var
        vatAllocLine: Record "VAT Allocation Line";
        dimMgt: Codeunit DimensionManagement;
        dimSetIdArr: array[10] of integer;
    begin
        vatAllocLine.reset();
        vatAllocLine.SetRange("CV Ledger Entry No.", cvLedgerEntryNo);
        vatAllocLine.SetRange("VAT Entry No.", vatEntryNo);

        if (vatAllocLine.findset()) then begin
            repeat
                clear(dimSetIdArr);
                dimSetIdArr[1] := dimDetId;
                dimSetIdArr[2] := VATAllocLine."Dimension Set ID";
                dimSetIdArr[3] := 0;
                VATAllocLine."Dimension Set ID" := dimMgt.GetCombinedDimensionSetID(dimSetIdArr, VATAllocLine."Shortcut Dimension 1 Code", VATAllocLine."Shortcut Dimension 2 Code");
                VATAllocLine.modify();
            until (vatAllocLine.next() = 0)
        end;

    end;
    // NC 50118 GG >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Settlement Management", 'onAfterSetVatEntryFilter', '', false, false)]
    local procedure onAfterSetVatEntryFilter(var VATEntry: Record "VAT Entry"; var VATDocEntryBuffer: Record "VAT Document Entry Buffer")
    begin
        VATEntry.SetFilter("Global Dimension 1 Code", VATDocEntryBuffer.getfilter("Global Dimension 1 Filter"));
        VATEntry.SetFilter("Global Dimension 2 Code", VATDocEntryBuffer.getfilter("Global Dimension 2 Filter"));
        vatentry.SetFilter("Cost Code Type", VATDocEntryBuffer.GetFilter("Cost Code Type Filter"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Settlement Management", 'onBeforeInsertTempVATDocBuf', '', false, false)]
    local procedure onBeforeInsertTempVATDocBuf(var TempVATDocBuf: record "VAT Document Entry Buffer"; var VATEntry: record "Vat Entry")
    begin
        TempVATDocBuf.validate("VAT Allocation", VATEntry."VAT Allocation");
    end;

    // NC 50118 GG <<


    // cu 12411 <<

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', true, true)]
    local procedure OnBeforeDrillDownDocAttFackBox(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        VendAgreement: Record "Vendor Agreement";
    begin
        case DocumentAttachment."Table ID" of
            DATABASE::"Vendor Agreement":
                begin
                    RecRef.Open(DATABASE::"Vendor Agreement");
                    VendAgreement.Reset();
                    if DocumentAttachment."PK Key 2" <> '' then
                        VendAgreement.SetRange("Vendor No.", DocumentAttachment."PK Key 2");
                    VendAgreement.SetRange("No.", DocumentAttachment."No.");
                    if VendAgreement.FindFirst() then
                        RecRef.GetTable(VendAgreement);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', true, true)]
    local procedure OnAfterOpenForRecRefDocAttDet(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var FlowFieldsEditable: Boolean)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        PKNo: Code[20];
    begin
        case RecRef.Number of
            DATABASE::"Vendor Agreement":
                begin
                    FieldRef := RecRef.Field(1);
                    PKNo := FieldRef.Value;
                    FieldRef := RecRef.Field(2);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("PK Key 2", PKNo);
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertRecordDocAttDetails(VAR Rec: Record "Document Attachment"; BelowxRec: Boolean; VAR xRec: Record "Document Attachment"; VAR AllowInsert: Boolean)
    var
        CurrFltGr: Integer;
    begin
        if Rec.GetFilter("PK Key 2") <> '' then
            Rec."PK Key 2" := Rec.GetFilter("PK Key 2");
        if Rec."Attachment Link" <> '' then begin
            if IsNullGuid(rec."Attached By") then
                rec."Attached By" := UserSecurityId();
            rec.Insert(false);
            AllowInsert := false;
        end;
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Document Attachment", 'OnBeforeSaveAttachment', '', true, true)]
    local procedure OnBeforeSaveAttachmentDocAtt(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; FileName: Text; var TempBlob: Codeunit "Temp Blob")
    begin
        if DocumentAttachment.GetFilter("PK Key 2") <> '' then
            DocumentAttachment."PK Key 2" := DocumentAttachment.GetFilter("PK Key 2");
    end;

    // Codeunit 5063 ArchiveManagement 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, 'OnAfterStorePurchDocument', '', false, false)]
    local procedure OnAfterStorePurchDocument(var PurchaseHeader: Record "Purchase Header"; var PurchaseHeaderArchive: Record "Purchase Header Archive");
    var
        DocAttach: Record "Document Attachment";
        DocAttachArch: Record "Document Attachment Archive";
    begin
        if PurchaseHeader."Archiving Type" = PurchaseHeader."Archiving Type"::" " then
            exit;

        DocAttach.SetFilter("Table ID", '%1|%2', Database::"Purchase Header", Database::"Purchase Line");
        DocAttach.SetRange("Document Type", PurchaseHeader."Document Type");
        DocAttach.SetRange("No.", PurchaseHeader."No.");
        if DocAttach.FindSet() then
            repeat
                DocAttachArch.Init();
                DocAttachArch.TransferFields(DocAttach);
                IF DocAttach."Table ID" = Database::"Purchase Header" then
                    DocAttachArch."Table ID" := Database::"Purchase Header Archive"
                else
                    DocAttachArch."Table ID" := Database::"Purchase Line Archive";
                DocAttachArch."Version No." := PurchaseHeaderArchive."Version No.";
                DocAttachArch."Doc. No. Occurrence" := PurchaseHeaderArchive."Doc. No. Occurrence";
                DocAttach.CalcFields("Document Reference ID");
                DocAttachArch."Document Reference ID" := DocAttach."Document Reference ID";
                DocAttachArch.INSERT;
            until DocAttach.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Transfer Document", 'OnBeforeCheckTransLines', '', false, false)]
    local procedure OnBeforeCheckTransLines(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean; TransHeader: Record "Transfer Header");
    var
        InvtSetup: Record "Inventory Setup";
    begin
        // NC 51411 > EP
        // Перенес модификацию из cu "Release Transfer Document".OnRun()
        // SWC816 AK 200416 >>
        InvtSetup.Get();
        if InvtSetup."Use Giv. Production Func." then begin
            InvtSetup.TestField("Giv. Materials Loc. Code");
            if (TransHeader."Transfer-from Code" = InvtSetup."Giv. Materials Loc. Code") or
               (TransHeader."Transfer-to Code" = InvtSetup."Giv. Materials Loc. Code") then begin
                TransHeader.TestField("Vendor No.");
                TransHeader.TestField("Agreement No.");
            end;
        end;
        // SWC816 AK 200416 <<
        // NC 51411 < EP
    end;

    // Table 38 Purchase Header

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeTestNoSeries', '', false, false)]
    local procedure OnBeforeTestNoSeries(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean);
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        IsHandled := true;
        PurchSetup.Get();
        with PurchaseHeader do
            case "Document Type" of
                "Document Type"::Quote:
                    PurchSetup.TestField("Quote Nos.");
                "Document Type"::Order:
                    //PurchSetup.TestField("Order Nos.");
                    if "Act Type" = "Act Type"::" " then begin
                        if not "IW Documents" then
                            PurchSetup.TestField("Order Nos.")
                        else
                            PurchSetup.TestField("Payment Request Nos.");
                    end else
                        PurchSetup.TestField("Act Order Nos.");
                "Document Type"::Invoice:
                    begin
                        if "Empl. Purchase" then
                            PurchSetup.TestField("Advance Statement Nos.")
                        else begin
                            PurchSetup.TestField("Invoice Nos.");
                            PurchSetup.TestField("Posted Invoice Nos.");
                        end;
                    end;
                "Document Type"::"Return Order":
                    PurchSetup.TestField("Return Order Nos.");
                "Document Type"::"Credit Memo":
                    begin
                        PurchSetup.TestField("Credit Memo Nos.");
                        PurchSetup.TestField("Posted Credit Memo Nos.");
                    end;
                "Document Type"::"Blanket Order":
                    PurchSetup.TestField("Blanket Order Nos.");
            end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterGetNoSeriesCode', '', false, false)]
    local procedure OnAfterGetNoSeriesCode(var PurchHeader: Record "Purchase Header"; PurchSetup: Record "Purchases & Payables Setup"; var NoSeriesCode: Code[20]);
    begin
        if PurchHeader."Document Type" = PurchHeader."Document Type"::Order then begin
            if PurchHeader."Act Type" = PurchHeader."Act Type"::" " then begin
                if PurchHeader."IW Documents" then
                    NoSeriesCode := PurchSetup."Payment Request Nos.";
            end else
                NoSeriesCode := PurchSetup."Act Order Nos.";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnRecreatePurchLinesOnBeforeInsertPurchLine', '', false, false)]
    local procedure OnRecreatePurchLinesOnBeforeInsertPurchLine(var PurchaseLine: Record "Purchase Line"; var TempPurchaseLine: Record "Purchase Line" temporary; ChangedFieldName: Text[100])
    begin
        PurchaseLine."Full Description" := TempPurchaseLine."Full Description";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNo', '', false, false)]
    procedure OnValidatePurchaseHeaderPayToVendorNo(Vendor: Record Vendor; var PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::"Credit Memo" then
            PurchaseHeader."Payment Details" := Vendor.Name;
    end;

    // Table 39 Purchase Line

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValues(var PurchLine: Record "Purchase Line"; Item: Record Item; CurrentFieldNo: Integer)
    begin
        if CopyStr(Item."Description 2", 1, 1) <> ' ' then
            PurchLine."Full Description" := Item.Description + ' ' + Item."Description 2"
        else
            PurchLine."Full Description" := Item.Description + Item."Description 2";
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure SendVendorAgreementMail(var PurchaseHeader: Record "Purchase Header")
    var
        CompanyInfo: Record "Company Information";
        LocVend: Record Vendor;
        VendAgr: Record "Vendor Agreement";
        CheckLimitDateFilter: Text;
        VendorAgreement: Record "Vendor Agreement";
        Text001: Label 'The amount of purchases exceeds the amount of the limit!';
    begin
        if (PurchaseHeader."Buy-from Vendor No." <> '') AND (PurchaseHeader."Agreement No." <> '') then begin
            CompanyInfo.Get;
            LocVend.GET(PurchaseHeader."Buy-from Vendor No.");

            if CompanyInfo."Use RedFlags in Agreements" then
                if LocVend.GetLineColor = 'Attention' then begin
                    VendAgr.Get(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Agreement No.");
                    CheckLimitDateFilter := VendAgr.GetLimitDateFilter();

                    if CheckLimitDateFilter <> '' then
                        VendAgr.SetFilter("Check Limit Date Filter", CheckLimitDateFilter)
                    else
                        VendAgr.SetRange("Check Limit Date Filter");

                    VendAgr.CalcFields("Purch. Original Amt. (LCY)");

                    if PurchaseHeader."Original Company" = '' then
                        if (VendAgr."Check Limit Amount (LCY)" - VendAgr."Purch. Original Amt. (LCY)" < 0) then begin
                            VendorAgreement.SendVendAgrMail(VendAgr, 1);
                            Error(Text001);
                        end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"MyDim Value Combinations", 'OnLoadDimValCombPage', '', false, false)]
    local procedure OnLoadDimValueCombPage(var Row: Code[20]; var Col: Code[20]; var ShowCaption: Boolean; var DimRecord: Record "Dimension Value")
    var
        IsoMgt: Codeunit "Isolated Storage Management GE";
        ColFilter: Text;
    begin
        if IsoMgt.getString('DimValColumnFilter', ColFilter, true) then begin
            DimRecord.SetFilter(Code, ColFilter);
        end
        else begin
            IsoMgt.init();
            IsoMgt.setBool('ShowCaptionFromPage', ShowCaption);
            IsoMgt.setString('RowFromPage', Row);
            IsoMgt.setString('ColFromPage', Col);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnAfterValidateEvent', 'Substitute', false, false)]
    local procedure OnUserSetupAfterValidateSubstitute(var Rec: Record "User Setup"; xRec: Record "User Setup");
    var
        ApprovalEntry: Record "Approval Entry";
        SubstituteUserId: Code[50];
        LocText001: Label 'You cannot change the value of %1 because there are active approval entries for user %2.';
        LocText002: label 'Unable to find a substitute for %1. Check the substitute chain.';
    begin
        if Rec.Absents then begin
            SubstituteUserId := Rec.GetUserSubstitute(xRec.Substitute, -1);
            if SubstituteUserId = '' then
                error(LocText002, Rec."User ID");
            ApprovalEntry.SetRange("Approver ID", SubstituteUserId);
            ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Created, ApprovalEntry.Status::Open);
            if not ApprovalEntry.IsEmpty then
                Error(LocText001, Rec.FieldCaption(Substitute), SubstituteUserId);
        end;
    end;

    // codeunit 1509 "Notification Entry Dispatcher"

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Entry Dispatcher", 'OnBeforeGetHTMLBodyText', '', false, false)]
    local procedure OnBeforeGetHTMLBodyText(
        var NotificationEntry: Record "Notification Entry"; var BodyTextOut: Text; var IsHandled: Boolean; var BodyTextExist: Boolean;
        var Sender: Codeunit "Notification Entry Dispatcher"; var HtmlBodyFilePath: Text);
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        FileManagement: Codeunit "File Management";
        ErrorMessageMgt: Codeunit "Error Message Management";
        TempBlob: Codeunit "Temp Blob";
        BlobInStream: InStream;
        DataTypeManagement: Codeunit "Data Type Management";
        SourceRecRef: RecordRef;
        ApprovalEntry: Record "Approval Entry";
        ReportID: Integer;
    begin
        if (NotificationEntry.Type <> NotificationEntry.Type::Approval) or (NotificationEntry."Triggered By Record".TableNo <> DATABASE::"Approval Entry") then
            exit;
        DataTypeManagement.GetRecordRef(NotificationEntry."Triggered By Record", SourceRecRef);
        SourceRecRef.SetTable(ApprovalEntry);
        if (ApprovalEntry."Act Type" = ApprovalEntry."Act Type"::" ") and (not ApprovalEntry."IW Documents") then
            exit;

        IsHandled := true;
        ReportID := Report::"Notification Email Act. Inv.";

        HtmlBodyFilePath := FileManagement.ServerTempFileName('html');
        ReportLayoutSelection.SetTempLayoutSelected('');
        if not REPORT.SaveAsHtml(ReportID, HtmlBodyFilePath, NotificationEntry) then begin
            NotificationEntry."Error Message" := GetLastErrorText;
            NotificationEntry.Modify(true);
            ErrorMessageMgt.LogError(NotificationEntry, GetLastErrorText(), '');
            ClearLastError;
            BodyTextExist := false;
            exit;
        end;

        //ConvertHtmlFileToText(HtmlBodyFilePath, BodyTextOut);
        FileManagement.BLOBImportFromServerFile(TempBlob, HtmlBodyFilePath);
        TempBlob.CreateInStream(BlobInStream);
        BlobInStream.ReadText(BodyTextOut);

        BodyTextExist := true;
    end;

    // codeunit 1510 "Notification Management"

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnBeforeGetActionTextFor', '', false, false)]
    local procedure OnBeforeGetActionTextFor(var NotificationEntry: Record "Notification Entry"; var CustomText: Text; var IsHandled: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
        DataTypeManagement: Codeunit "Data Type Management";
        PaymentOrderMgt: Codeunit "Payment Order Management";
        RecRef: RecordRef;
        ApproverType: Text;
        GenAppStatus: Integer;
        MessageResponsNo: Integer;
        ActionApprovedTxt: Label 'has been approved by %1.';
        ActionApprovalRejectedTxt: Label 'approval has been rejected by %1.';
        ResponsText: label 'Reception,Controller,Estimator,Checker,Pre. Approver,Approver,Signer';
        FinalText: Label 'The document passed all approvals!';
    begin
        if NotificationEntry.Type = NotificationEntry.Type::Approval then begin
            DataTypeManagement.GetRecordRef(NotificationEntry."Triggered By Record", RecRef);
            RecRef.SetTable(ApprovalEntry);
            if (ApprovalEntry."Act Type" <> ApprovalEntry."Act Type"::" ") or ApprovalEntry."IW Documents" then begin
                IsHandled := true;
                if ApprovalEntry."IW Documents" then
                    GenAppStatus := ApprovalEntry."Status App".AsInteger()
                else
                    GenAppStatus := ApprovalEntry."Status App Act".AsInteger();
                MessageResponsNo := PaymentOrderMgt.GetMessageResponsNo(ApprovalEntry."IW Documents", GenAppStatus, ApprovalEntry."Preliminary Approval");
                if not (MessageResponsNo in [8, 9]) then
                    ApproverType := SelectStr(MessageResponsNo, ResponsText);
                case ApprovalEntry.Status of
                    ApprovalEntry.Status::Rejected:
                        CustomText := StrSubstNo(ActionApprovalRejectedTxt, ApproverType);
                    ApprovalEntry.Status::Approved:
                        if MessageResponsNo in [8, 9] then
                            CustomText := FinalText
                        else
                            CustomText := StrSubstNo(ActionApprovedTxt, ApproverType);
                    else
                        IsHandled := false;
                end;
            end;
        end;
    end;
}