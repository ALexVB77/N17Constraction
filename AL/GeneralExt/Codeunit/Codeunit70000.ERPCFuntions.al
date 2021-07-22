codeunit 70000 "ERPC Funtions"
{
    trigger OnRun()
    begin
    end;

    procedure PostForecastEntry(grPH: Record "Purchase Header")
    begin
        message('Call function PostForecastEntry() in CU 70000 ERPC Funtions')
    end;

    procedure UnpostForecastEntry(grPH: Record "Purchase Header")
    begin
        message('Call function UppostForecastEntry() in CU 70000 ERPC Funtions')
    end;

    procedure GetActStatus(pActCode: code[20]) Ret: code[30]
    var
        lrActLines: record "Act Lines";
        lrActLines1: record "Act Lines";
    begin
        lrActLines.SETRANGE("Act No.", pActCode);
        lrActLines.SETRANGE(Close, TRUE);
        IF lrActLines.FIND('+') THEN
            Ret := lrActLines."Stage Code";
    end;

    procedure GetAgreementActStatus(pAgrCode: code[20]) Ret: code[30]
    var
        lrActLines: record "Act Lines";
        lrActLines1: record "Act Lines";
        lrAct: record "Objects Act";
    begin
        lrAct.SETRANGE("Agreement No.", pAgrCode);
        lrAct.SETFILTER(Status, '<>%1&<>%2', lrAct.Status::New, lrAct.Status::Cancell);
        IF lrAct.FIND('-') THEN Ret := GetActStatus(lrAct."No.");
    end;

    procedure GetCommited(pAgreement: Code[20]; pCP: Code[20]; pCC: Code[20]) ReturnValue: Decimal
    var
        lrProjectsBudgetEntry: Record "Projects Budget Entry";
    begin
        lrProjectsBudgetEntry.SETCURRENTKEY("Work Version", "Agreement No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        lrProjectsBudgetEntry.SETRANGE("Work Version", TRUE);
        lrProjectsBudgetEntry.SETRANGE("Agreement No.", pAgreement);

        IF pCP <> '' THEN
            lrProjectsBudgetEntry.SETRANGE("Shortcut Dimension 1 Code", pCP);
        IF pCC <> '' THEN
            lrProjectsBudgetEntry.SETRANGE("Shortcut Dimension 2 Code", pCC);

        lrProjectsBudgetEntry.CALCSUMS("Without VAT");

        ReturnValue += lrProjectsBudgetEntry."Without VAT";
    end;

    procedure GetLinesDocumentsAmount(pPL: Record "Purchase Line") Ret: Decimal
    var
        lrPL: Record "Purchase Line";
        lrPH: Record "Purchase Header";
        PLt: Record "Purchase Line" temporary;
        TempVATAmountLine0: Record "VAT Amount Line" temporary;
        AmountWOVAT: Decimal;
        AmountVAT: Decimal;
        AmountWVAT: Decimal;
        Amount: Decimal;
    begin
        if lrPH.Get(pPL."Document Type", pPL."Document No.") then begin
            lrPH.Status := lrPH.Status::Released;
            lrPL.SetRange("Document Type", pPL."Document Type");
            lrPL.SetRange("Document No.", pPL."Document No.");

            if lrPL.FindSet() then
                repeat
                    PLt := lrPL;
                    PLt.INSERT;
                until lrPL.Next() = 0;

            //PLt.SetTemp(TRUE);
            PLt.SetPurchHeader(lrPH);
            PLt.CalcVATAmountLines(0, lrPH, PLt, TempVATAmountLine0);
            PLt.UpdateVATOnLines(0, lrPH, PLt, TempVATAmountLine0);

            if PLt.Get(pPL."Document Type", pPL."Document No.", pPL."Line No.") then
                Ret := PLt."Amount Including VAT";
        end;
        exit;

        AmountWOVAT := 0;
        AmountVAT := 0;
        AmountWVAT := 0;

        lrPH.Get(pPL."Document Type", pPL."Document No.");

        lrPL.SetRange("Document Type", pPL."Document Type");
        lrPL.SetRange("Document No.", pPL."Document No.");
        lrPL.SetRange("Line No.", pPL."Line No.");

        IF lrPL.FindFirst() then begin
            repeat
                if lrPH."Currency Factor" <> 0 then
                    Amount := lrPL."Line Amount"
                else
                    Amount := lrPL."Line Amount";

                if lrPH."Prices Including VAT" then begin
                    if lrPL."VAT %" <> 0 then begin
                        AmountVAT := AmountVAT + Round(Amount - (Amount / ((100 + lrPL."VAT %") / 100)), 0.01);
                        AmountWOVAT := AmountWOVAT + (Amount - Round(Amount - (Amount / ((100 + lrPL."VAT %") / 100)), 0.01));
                        AmountWVAT := AmountWVAT + Amount;
                    end else begin
                        AmountWOVAT := AmountWOVAT + Amount;
                        AmountWVAT := AmountWVAT + Amount;
                    end;
                end else begin
                    if lrPL."VAT %" <> 0 then begin
                        AmountVAT := AmountVAT + (Round(Amount * ((100 + lrPL."VAT %") / 100), 0.01) - Amount);
                        AmountWOVAT := AmountWOVAT + Amount;
                        AmountWVAT := AmountWVAT + (Amount + (Round(Amount * ((100 + lrPL."VAT %") / 100), 0.00001) - Amount));
                    end else begin
                        AmountWOVAT := AmountWOVAT + Amount;
                        AmountWVAT := AmountWVAT + Amount;
                    end;
                end;
            until lrPL.Next() = 0;
        end;

        Ret := AmountWVAT;
    end;

    procedure LookUpLocationCode(var LocationCode: code[10]): boolean
    var
        UserSetup: record "User Setup";
        Location: record Location;
        StorekeeperLocation: record "Warehouse Employee";
        LocationList: page "Location List";
        StorekeeperLocationList: page "Warehouse Employees";
        StoreKeeper: boolean;
    begin
        StorekeeperLocation.FILTERGROUP(2);
        StorekeeperLocation.SETRANGE("User ID", USERID);
        StorekeeperLocation.FILTERGROUP(0);
        IF NOT StorekeeperLocation.IsEmpty THEN BEGIN
            StorekeeperLocationList.SETTABLEVIEW(StorekeeperLocation);
            StorekeeperLocationList.LOOKUPMODE(TRUE);
            IF StorekeeperLocationList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                StorekeeperLocationList.GETRECORD(StorekeeperLocation);
                LocationCode := StorekeeperLocation."Location Code";
                EXIT(TRUE);
            END;
        END ELSE BEGIN
            LocationList.LOOKUPMODE(TRUE);
            IF LocationList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                LocationList.GETRECORD(Location);
                LocationCode := Location.Code;
                EXIT(TRUE);
            END;
        END;
    end;

    procedure DeleteBCPreBooking(PurchaseHeader: record "Purchase Header")
    var
        PurchLine: record "Purchase Line";
        VendorAgreementDetails: record "Projects Cost Control Entry";
        Buildingturn: record "Building turn";
        ProjectsLineDimension: record "Projects Line Dimension";
        ProjectsStructureLines: record "Projects Structure Lines";
        VAgreement: record "Vendor Agreement";
        VendorAgreementDetails1: record "Vendor Agreement Details";
        Vendor: record Vendor;
    begin
        VendorAgreementDetails.SETCURRENTKEY("Doc No.");
        VendorAgreementDetails.SETRANGE("Doc No.", PurchaseHeader."No.");
        IF VendorAgreementDetails.FINDFIRST THEN
            VendorAgreementDetails.DELETEALL(TRUE);
        IF Vendor.GET(PurchaseHeader."Buy-from Vendor No.") AND (Vendor."Agreement Posting" = Vendor."Agreement Posting"::Mandatory) THEN
            VAgreement.GET(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Agreement No.")
        ELSE
            VAgreement.WithOut := true;
        IF VAgreement.WithOut THEN BEGIN
            PurchLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
            PurchLine.SETRANGE("Document No.", PurchaseHeader."No.");
            IF PurchLine.FINDSET THEN
                REPEAT
                    VendorAgreementDetails1.SETRANGE("Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                    VendorAgreementDetails1.SETRANGE("Agreement No.", PurchaseHeader."Agreement No.");
                    VendorAgreementDetails1.SETRANGE("Global Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                    VendorAgreementDetails1.SETRANGE("Global Dimension 2 Code", PurchLine."Shortcut Dimension 2 Code");
                    VendorAgreementDetails1.SETRANGE("Cost Type", PurchLine."Cost Type");
                    IF VendorAgreementDetails1.FINDFIRST THEN BEGIN
                        VendorAgreementDetails1.Amount := VendorAgreementDetails1.Amount - PurchLine."Line Amount";
                        VendorAgreementDetails1.MODIFY(TRUE);
                    END;
                UNTIL PurchLine.NEXT = 0;
        END;
    end;

    procedure DeleteInvoice(prInvoice: record "Purchase Header"): boolean
    var
        grPurchPay: record "Purchases & Payables Setup";
        lrGenJnlLine: record "Gen. Journal Line";
        LocText001: Label 'Do you want to delete Payment Invoice %1 for %2?';
        LocText002: Label 'There are Cash Flow linked lines. Continue?';
        LocText50021: Label 'Request %1 in the "Payment" approval status. Unable to delete.\Use the archiving function.';
    begin
        // NC AB:
        // функция подвешена не к кнопке, на на триггер OnDelete, поэтому саму запись prInvoice не удаляем
        // само удаление надо повесть на триггер OnDelete таблицы 38

        //NC 44343 > KGT
        IF prInvoice."Status App" = prInvoice."Status App"::Payment THEN
            ERROR(LocText50021, prInvoice."No.");
        //NC 44343 < KGT

        IF CONFIRM(STRSUBSTNO(LocText001, prInvoice."No.", prInvoice."Buy-from Vendor Name")) THEN BEGIN
            //NC 29594 HR beg
            IF prInvoice.HasBoundedCashFlows THEN BEGIN
                IF NOT CONFIRM(LocText002, FALSE) THEN
                    EXIT(false);
            END;
            //NC 29594 HR end

            grPurchPay.GET;

            Message('Вызвано удаление строк фин. журнала из DeleteInvoice() CU 70000. ПРОВЕРИТЬ!');
            /*
            lrGenJnlLine.SETRANGE("Journal Template Name", grPurchPay."Payment Calendar Tmpl");
            lrGenJnlLine.SETRANGE("Journal Batch Name", grPurchPay."Payment Calendar Batch");
            lrGenJnlLine.SETRANGE("Document No.", prInvoice."No.");
            IF lrGenJnlLine.FINDFIRST THEN 
                lrGenJnlLine.DELETEALL(TRUE);
            */

            // NC AB >>
            // // SWC DD 25.05.17 >>
            // prInvoice.GET(prInvoice."Document Type", prInvoice."No.");
            // // SWC DD 25.05.17 <<
            // prInvoice.DELETE(TRUE);
            // NC AB <<
            exit(true);

        END;
    end;

    procedure CheckShortCutDim1(PurchHeader: Record "Purchase Header")
    var
        PurchSetup: Record "Purchases & Payables Setup";
        DimSetEntry: Record "Dimension Set Entry";
        LocText001: Label 'You must specify %1 and %2 for %3.';
    begin
        PurchSetup.Get();
        PurchSetup.TestField("Cost Place Dimension");
        PurchSetup.TestField("Cost Code Dimension");

        if PurchHeader."Dimension Set ID" = 0 then
            Error(LocText001, PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension", PurchHeader."No.");

        DimSetEntry.SetRange("Dimension Set ID", PurchHeader."Dimension Set ID");
        DimSetEntry.SetFilter("Dimension Code", '%1|%2', PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension");
        if DimSetEntry.Count <> 2 then
            Error(LocText001, PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension", PurchHeader."No.");
    end;

    procedure CheckLineShortCutDim1(PurchLine: Record "Purchase Line"; PurchSetup: Record "Purchases & Payables Setup")
    var
        DimSetEntry: Record "Dimension Set Entry";
        DimValue: Record "Dimension Value";
        LocText001: Label 'You must specify %1 and %2 for %3 line %4.';
    begin
        if PurchLine."Dimension Set ID" = 0 then
            Error(LocText001, PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension", PurchLine."Document No.", PurchLine."Line No.");

        DimSetEntry.SetRange("Dimension Set ID", PurchLine."Dimension Set ID");
        DimSetEntry.SetFilter("Dimension Code", '%1|%2', PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension");
        if DimSetEntry.Count <> 2 then
            Error(LocText001, PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension", PurchLine."Document No.", PurchLine."Line No.");
    end;

    local procedure CheckDimensionComb(PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        DimMgt: Codeunit DimensionManagement;
        DimCausedErr: label 'A dimension used in line %1 has caused an error. %2.';
    begin
        PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
        PurchLine.SETRANGE("Document No.", PurchHeader."No.");
        IF PurchLine.FINDSET THEN
            REPEAT
                // NC AB : переделываем на стандарт
                // DimensionValueCombination.SETRANGE("Dimension 1 Code", 'CP');
                // DimensionValueCombination.SETRANGE("Dimension 1 Value Code", lrPL."Shortcut Dimension 1 Code");
                // DimensionValueCombination.SETRANGE("Dimension 2 Code", 'CC');
                // DimensionValueCombination.SETRANGE("Dimension 2 Value Code", lrPL."Shortcut Dimension 2 Code");
                // IF DimensionValueCombination.FINDFIRST THEN
                //     ERROR(TEST0001, 'CP', lrPL."Shortcut Dimension 1 Code", 'CC', lrPL."Shortcut Dimension 2 Code");
                // DimensionValueCombination.SETRANGE("Dimension 2 Code", 'CP');
                // DimensionValueCombination.SETRANGE("Dimension 2 Value Code", lrPL."Shortcut Dimension 1 Code");
                // DimensionValueCombination.SETRANGE("Dimension 1 Code", 'CC');
                // DimensionValueCombination.SETRANGE("Dimension 1 Value Code", lrPL."Shortcut Dimension 2 Code");
                // IF DimensionValueCombination.FINDFIRST THEN
                //     ERROR(TEST0001, 'CP', lrPL."Shortcut Dimension 1 Code", 'CC', lrPL."Shortcut Dimension 2 Code");
                IF NOT DimMgt.CheckDimIDComb(PurchLine."Dimension Set ID") THEN
                    ERROR(DimCausedErr, PurchLine."Line No.", DimMgt.GetDimValuePostingErr);
            UNTIL PurchLine.NEXT = 0;
    end;

    procedure CheckDocSum(PurchHeader: Record "Purchase Header")
    var
        TempPurchLine: Record "Purchase Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PurchPost: Codeunit "Purch.-Post";
        ErrText001: label 'The invoice Amount including VAT in the header does not match the amount including VAT by lines!';
        ErrText002: label 'The VAT amount in the header does not match the VAT amount by lines!';
    begin
        // NC AB: переделываем на стандарт
        // InvAmountInclVAT := gcERPC.GetTotalsActAmount(pPH, 3);
        // InvVATAmount := gcERPC.GetTotalsActAmount(pPH, 2);
        // InvAmount := gcERPC.GetTotalsActAmount(pPH, 1);
        // IF pPH."Invoice Amount Incl. VAT" <> InvAmountInclVAT THEN
        //   ERROR('Сумма счета с НДС в шапке не совпадает с Суммой включая НДС по строкам!');
        // IF pPH."Invoice VAT Amount" <> InvVATAmount THEN
        //   ERROR('Сумма НДС в шапке не совпадает с Суммой НДС по строкам!');
        // IF pPH."Invoice Amount" <> InvAmount THEN
        //   ERROR('Сумма счета без НДС в шапке не совпадает с Суммой без НДС по строкам!');
        PurchPost.GetPurchLines(PurchHeader, TempPurchLine, 0);
        TempPurchLine.CalcVATAmountLines(0, PurchHeader, TempPurchLine, TempVATAmountLine);
        TempPurchLine.UpdateVATOnLines(0, PurchHeader, TempPurchLine, TempVATAmountLine);
        IF PurchHeader."Invoice Amount Incl. VAT" <> TempVATAmountLine.GetTotalAmountInclVAT() THEN
            ERROR(ErrText001);
        IF PurchHeader."Invoice VAT Amount" <> TempVATAmountLine.GetTotalVATAmount() THEN
            ERROR(ErrText002);
    end;

    local procedure CreatePurchOrder(VAR PurchaseHeader: Record "Purchase Header"; CheckOnly: Boolean)
    var
        InvSetup: Record "Inventory Setup";
        WhseEmpl: Record "Warehouse Employee";
        PurchLine: Record "Purchase Line";
        PHeader: Record "Purchase Header";
        PLine: Record "Purchase Line";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        PurchPost: Codeunit "Purch.-Post";
        Text50016: label 'You must select the real item before document posting.';
    begin
        InvSetup.GET();
        // DEBUG check later
        /*
        InvSetup.TESTFIELD(InvSetup."Warehouse RoleID");
        IF NOT ExistRoles(USERID,InvSetup."Warehouse RoleID") THEN ERROR(Text50020);
        */
        // NC AB: пока просто проверяем что пользователь - сотрудник склада
        WhseEmpl.SetRange("User ID", UserId);
        WhseEmpl.FindFirst();

        PurchLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchLine.SETRANGE("No.", InvSetup."Temp Item Code");
        IF not PurchLine.IsEmpty THEN
            ERROR(Text50016);
        PurchLine.SETRANGE("No.");

        if CheckOnly then
            exit;

        PHeader.INIT;
        PHeader.TRANSFERFIELDS(PurchaseHeader);
        PHeader."Document Type" := PHeader."Document Type"::Order;
        PHeader."No." := '';
        PHeader.Status := PHeader.Status::Open;
        PHeader."Act Type" := PHeader."Act Type"::" ";
        PHeader.INSERT(TRUE);

        PHeader."Document Date" := PurchaseHeader."Document Date";
        PHeader.VALIDATE("Location Code", PurchaseHeader."Location Code");
        PHeader.MODIFY();

        IF PurchLine.FINDSET THEN
            REPEAT
                WITH PLine DO BEGIN
                    INIT;
                    TRANSFERFIELDS(PurchLine);
                    "Document Type" := PHeader."Document Type";
                    "Document No." := PHeader."No.";
                    VALIDATE(Amount, PurchLine."Line Amount");
                    VALIDATE("Cost Type");
                    INSERT;
                END
            UNTIL PurchLine.NEXT = 0;

        ReleasePurchDoc.RUN(PHeader);
        PHeader.Receive := TRUE;
        PHeader.MODIFY;

        // NC AB:
        // PurchPost.SetPreviewMode(FALSE, TRUE);
        // PurchPost.ForceSwitchOffTracert();
        PurchPost.SetSuppressCommit(true);
        PurchPost.RUN(PHeader);

        PurchaseHeader."Invoice No." := PHeader."No.";
        PurchaseHeader.Modify();
    end;

    local procedure UpdateActHeaderDimByMaxLine(var PurchHeader: Record "Purchase Header"; var PurchSetup: record "Purchases & Payables Setup"; HardCheck: Boolean)
    var
        PurchLine: Record "Purchase Line";
        PurchLineMax: Record "Purchase Line";
        DimSetEntryFrom: Record "Dimension Set Entry";
        DimMgtExt: Codeunit "Dimension Management (Ext)";
        MaxAmount: Decimal;
        UpdateHeader: Boolean;
        Text50015: Label 'Lines are not filled.';
    begin

        PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
        PurchLine.SETRANGE("Document No.", PurchHeader."No.");
        IF PurchLine.ISEMPTY and HardCheck THEN
            ERROR(Text50015);
        IF PurchLine.FINDSET THEN BEGIN
            PurchLineMax := PurchLine;
            MaxAmount := PurchLine."Line Amount";
            REPEAT
                // NC AB :
                // PurchLine.TESTFIELD("Shortcut Dimension 1 Code");
                // PurchLine.TESTFIELD("Shortcut Dimension 2 Code");
                // IF STRLEN(PurchLine."Shortcut Dimension 1 Code") >= 10 THEN BEGIN
                //     IF grPurchHeader."Act Type" = grPurchHeader."Act Type"::Act THEN
                //         IF PurchLine."Shortcut Dimension 1 Code"[10] = 'P' THEN
                //             ERROR(Text50010, PurchLine."Line No.", PurchLine."Shortcut Dimension 1 Code", grPurchHeader."Act Type");
                //     IF grPurchHeader."Act Type" = grPurchHeader."Act Type"::"Act (Production)" THEN
                //         IF PurchLine."Shortcut Dimension 1 Code"[10] = 'D' THEN
                //             ERROR(Text50010, PurchLine."Line No.", PurchLine."Shortcut Dimension 1 Code", grPurchHeader."Act Type");
                // END;
                CheckLineShortCutDim1(PurchLine, PurchSetup);

                IF MaxAmount < PurchLine."Line Amount" THEN BEGIN
                    PurchLineMax := PurchLine;
                    MaxAmount := PurchLine."Line Amount";
                END;
            UNTIL PurchLine.NEXT = 0;
            // NC AB:
            // IF (PLmax."Shortcut Dimension 1 Code" <> '') AND
            //   (grPurchHeader."Shortcut Dimension 1 Code" <> PLmax."Shortcut Dimension 1 Code") THEN BEGIN
            //     grPurchHeader.VALIDATE("Shortcut Dimension 1 Code", PLmax."Shortcut Dimension 1 Code");
            //     grPurchHeader.MODIFY;
            // END;
            // IF (PLmax."Shortcut Dimension 2 Code" <> '') AND
            //   (grPurchHeader."Shortcut Dimension 2 Code" <> PLmax."Shortcut Dimension 2 Code") THEN BEGIN
            //     grPurchHeader.VALIDATE("Shortcut Dimension 2 Code", PLmax."Shortcut Dimension 2 Code");
            //     grPurchHeader.MODIFY;
            // END;
            if PurchHeader."Dimension Set ID" <> 0 then begin
                if DimSetEntryFrom.Get(PurchLineMax."Dimension Set ID", PurchSetup."Cost Place Dimension") then
                    UpdateHeader := DimMgtExt.valDimValueWithUpdGlobalDim(
                        DimSetEntryFrom."Dimension Code", DimSetEntryFrom."Dimension Value Code",
                        PurchHeader."Dimension Set ID", PurchHeader."Shortcut Dimension 1 Code", PurchHeader."Shortcut Dimension 2 Code");
                if DimSetEntryFrom.Get(PurchLineMax."Dimension Set ID", PurchSetup."Cost Code Dimension") then
                    UpdateHeader := DimMgtExt.valDimValueWithUpdGlobalDim(
                        DimSetEntryFrom."Dimension Code", DimSetEntryFrom."Dimension Value Code",
                        PurchHeader."Dimension Set ID", PurchHeader."Shortcut Dimension 1 Code", PurchHeader."Shortcut Dimension 2 Code");
                IF UpdateHeader then
                    PurchHeader.MODIFY;
            end
        END;
    end;

    local procedure CheckActByVendAgreementDates(PurchHeader: Record "Purchase Header")
    var
        lrVendorAgreem: Record "Vendor Agreement";
        TEXT70006: Label 'The agreement Starting Date must not be later than the Order Date.';
        TEXT70007: Label 'The agreement Expire Date must not be earlier than the Order Date.';
        TEXT70008: Label 'The agreement Start Date must not be later than the Document Date.';
        TEXT70009: Label 'The agreement Expire Date must not be earlier than the Document Date.';
    begin
        if PurchHeader."Agreement No." = '' then
            exit;
        lrVendorAgreem.GET(PurchHeader."Buy-from Vendor No.", PurchHeader."Agreement No.");
        IF PurchHeader."Order Date" < lrVendorAgreem."Starting Date" THEN
            ERROR(TEXT70006);
        IF PurchHeader."Order Date" > lrVendorAgreem."Expire Date" THEN
            ERROR(TEXT70007);
        IF PurchHeader."Document Date" < lrVendorAgreem."Starting Date" THEN
            ERROR(TEXT70008);
        IF PurchHeader."Document Date" > lrVendorAgreem."Expire Date" THEN
            ERROR(TEXT70009);
    end;

    local procedure CreatePurchInvoice(VAR PurchaseHeader: Record "Purchase Header")
    var
        PHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PLine: Record "Purchase Line";
    begin
        PHeader.INIT;
        PHeader.TRANSFERFIELDS(PurchaseHeader);
        PHeader."Document Type" := PHeader."Document Type"::Invoice;
        PHeader."No." := '';
        PHeader."Act Type" := PHeader."Act Type"::" ";
        PHeader.INSERT(TRUE);

        PHeader."Document Date" := PurchaseHeader."Document Date";
        IF PurchaseHeader."Act Type" = PurchaseHeader."Act Type"::Advance THEN
            PHeader."Posting No." := PHeader."No.";
        PHeader.MODIFY();

        PurchaseHeader."Invoice No." := PHeader."No.";
        PurchaseHeader.Modify();

        PurchLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchLine.SETRANGE("Document No.", PurchaseHeader."No.");
        IF PurchLine.FINDSET THEN
            REPEAT
                WITH PLine DO BEGIN
                    INIT;
                    TRANSFERFIELDS(PurchLine);
                    "Document Type" := PHeader."Document Type";
                    "Document No." := PHeader."No.";
                    VALIDATE(Amount, PurchLine."Line Amount");
                    VALIDATE("Cost Type");
                    VALIDATE("Full Description");
                    INSERT;
                END
            UNTIL PurchLine.NEXT = 0;
    end;

    /*
    // NC AB: не используется
    local procedure CheckDiffApprover(PurchHeader: Record "Purchase Header"): Boolean
    var
        PurchLineLoc: Record "Purchase Line";
    begin
        PurchLineLoc.RESET;
        PurchLineLoc.SETRANGE("Document Type", PurchHeader."Document Type");
        PurchLineLoc.SETRANGE("Document No.", PurchHeader."No.");
        if not PurchLineLoc.FindFirst() then
            exit(false);
        PurchLineLoc.SetFilter(Approver, '<>%1', PurchLineLoc.Approver);
        exit(not PurchLineLoc.IsEmpty);
    end;
    */

    local procedure CheckMasterApproverProduction(PurchHeader: Record "Purchase Header"): Boolean
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchLineLoc: Record "Purchase Line";
        DimValue: Record "Dimension Value";
    begin
        PurchSetup.Get();
        PurchLineLoc.RESET;
        PurchLineLoc.SETRANGE("Document Type", PurchHeader."Document Type");
        PurchLineLoc.SETRANGE("Document No.", PurchHeader."No.");
        PurchLineLoc.SetRange("Linked Dimension Filter", PurchSetup."Cost Code Dimension");
        PurchLineLoc.SetAutoCalcFields("Linked Dimension Value Code");
        if PurchLineLoc.FindSet() then
            repeat
                if PurchLineLoc."Linked Dimension Value Code" = '' then
                    exit(false);
                DimValue.get(PurchSetup."Cost Code Dimension", PurchLineLoc."Linked Dimension Value Code");
                IF DimValue."Cost Code Type" <> DimValue."Cost Code Type"::Production then
                    exit(false);
            until PurchLineLoc.Next = 0;
        exit(true);
    end;

    /*
    // NC AB: вместо нее используем GetApproverFromActLines() CU 50010
    local procedure InsertApproverNCC_FromDocLines(PurchHeader: Record "Purchase Header"): Code[20]
    var
        lrUserSetup: Record "User Setup";
        PurchLineLoc: Record "Purchase Line";
        LocText001: label 'Empty Approver on line!';
    begin
        IF CheckDiffApprover(PurchHeader) THEN BEGIN
            IF CheckMasterApproverProduction(PurchHeader) THEN BEGIN
                lrUserSetup.RESET;
                lrUserSetup.SETRANGE("Master Approver (Production)", TRUE);
                lrUserSetup.FINDFIRST;
                exit(lrUserSetup."User ID");
            END ELSE BEGIN
                lrUserSetup.RESET;
                lrUserSetup.SETRANGE("Master Approver (Development)", TRUE);
                lrUserSetup.FINDFIRST;
                exit(lrUserSetup."User ID");
            END;
        END ELSE BEGIN
            PurchLineLoc.RESET;
            PurchLineLoc.SETRANGE("Document Type", PurchHeader."Document Type");
            PurchLineLoc.SETRANGE("Document No.", PurchHeader."No.");
            PurchLineLoc.SetFilter(Type, '<>%1', PurchLineLoc.Type::" ");
            PurchLineLoc.FINDFIRST;

            if PurchLineLoc.Approver = '' then
                Error(LocText001);
            lrUserSetup.GET(PurchLineLoc.Approver);

            lrUserSetup.RESET;
            lrUserSetup.SETCURRENTKEY("Salespers./Purch. Code");
            lrUserSetup.SETRANGE("Salespers./Purch. Code", PurchHeader."Purchaser Code");
            lrUserSetup.FINDFIRST;
            IF PurchLineLoc.Approver <> lrUserSetup."User ID" THEN
                exit(PurchLineLoc.Approver)
            ELSE BEGIN
                IF CheckMasterApproverProduction(PurchHeader) THEN BEGIN
                    lrUserSetup.RESET;
                    lrUserSetup.SETRANGE("Master Approver (Production)", TRUE);
                    lrUserSetup.FINDFIRST;
                    exit(lrUserSetup."User ID");
                END ELSE BEGIN
                    lrUserSetup.RESET;
                    lrUserSetup.SETRANGE("Master Approver (Development)", TRUE);
                    lrUserSetup.FINDFIRST;
                    exit(lrUserSetup."User ID");
                END;
            END;
        END;
    end;
    */

    procedure ChangeActStatus(VAR grPurchHeader: Record "Purchase Header")
    var
        PurchSetup: Record "Purchases & Payables Setup";
        Location: Record Location;
        lrUserSetup: Record "User Setup";
        PurchLine: Record "Purchase Line";
        DocumentAttachment: Record "Document Attachment";
        lrVendor: Record Vendor;
        DimSetEntry: Record "Dimension Set Entry";
        DimValue: Record "Dimension Value";
        ApprovalMgtExt: Codeunit "Approvals Mgmt. (Ext)";
        NextAppr: Code[50];
        TEXT70001: label 'There is no attachment!';
        TEXT70002: Label 'The document has been approved!';
        TEXT70004: Label 'Vendor does not have to be basic!';
        TEXT70005: Label 'You must specify the Agreement!';
        TEXT70032: Label 'The document is ready to be sent to user %1 for approval.\Send?';
        TEXT70034: Label 'Canceled by user!';
        TEXT70045: label 'The document is signed by the Approver!';
        TEXT70046: Label 'The document has passed all approvals! A purchase invoice for accounting has been generated!';
        Text50013: label 'The document will be posted by quantity and a Posted Purchase Receipt will be created. Proceed?';
        Text1002: label 'Pre-Approver %1 is missing!\The request is being transferred to the Approver: %2';
        Text132: label 'Approving employee %1 is missing!\The request is being transferred to the Substitute: %2';
    begin

        /*    

        IF grPurchHeader."Location Document" THEN BEGIN
            grPurchHeader.TESTFIELD("Location Code");
            Location.GET(grPurchHeader."Location Code");
            Location.TESTFIELD("Bin Mandatory", FALSE);
        END;

        CheckCT(grPurchHeader);

        lrUserSetup.GET(USERID);

        IF grPurchHeader."Status App Act" = grPurchHeader."Status App Act"::Accountant THEN
            ERROR(TEXT70002);

        PurchSetup.Get();
        PurchSetup.TestField("Cost Place Dimension");
        PurchSetup.TestField("Cost Code Dimension");

        // ------- Сontroller -> Checker -------------- >>>>
        IF (grPurchHeader."Status App Act" = grPurchHeader."Status App Act"::Controller) AND
            (grPurchHeader.Check IN [grPurchHeader.Check::" ", grPurchHeader.Check::"Checker rej"])
        THEN BEGIN

            IF grPurchHeader."Location Document" AND (grPurchHeader."Invoice No." = '') THEN begin
                IF NOT CONFIRM(Text50013, FALSE) THEN
                    ERROR('');
                CreatePurchOrder(grPurchHeader, true);
            end;

            IF grPurchHeader."Location Document" THEN BEGIN
                // NC AB:
                // Table 70143 Tracert User Setupis not used. 
                // IF TracertUserSetup.GET(USERID) THEN
                //    IF TracertUserSetup."Ask For Tracing" THEN ERROR(Text50014);

                // NC AB: update dimension code moved to UpdateActHeaderDimByMaxLine()
                UpdateActHeaderDimByMaxLine(grPurchHeader, PurchSetup, true);
            END;

            DocumentAttachment.SetRange("Table ID", DATABASE::"Purchase Header");
            DocumentAttachment.SetRange("Document Type", grPurchHeader."Document Type");
            DocumentAttachment.SetRange("No.", grPurchHeader."No.");
            if DocumentAttachment.IsEmpty then
                ERROR(TEXT70001);

            if grPurchHeader."Buy-from Vendor No." = PurchSetup."Base Vendor No." then
                ERROR(TEXT70004);
            lrVendor.GET(grPurchHeader."Buy-from Vendor No.");
            IF lrVendor."Agreement Posting" = lrVendor."Agreement Posting"::Mandatory then
                grPurchHeader.Testfield("Agreement No.");

            CheckDimensionComb(grPurchHeader);

            IF grPurchHeader."Location Document" THEN
                CheckDocSum(grPurchHeader);

            IF grPurchHeader."Agreement No." <> '' THEN BEGIN
                CheckActByVendAgreementDates(grPurchHeader);
                CheckAgrDetRemain(grPurchHeader);
            END;
            grPurchHeader.TESTFIELD("Purchaser Code");
            grPurchHeader.TESTFIELD("Vendor Invoice No.");

            IF grPurchHeader."Location Document" THEN BEGIN
                // NC AB:
                // GetPurchDocAmount(grPurchHeader, TRUE);
                CheckDocSum(grPurchHeader);

                // NC AB: непонятен смысл, ведь процесс переходит к закупщику
                // NextAppr := InsertApproverNCC_FromDocLines(grPurchHeader);
                // NextAppr := '';
            END;

            lrUserSetup.RESET;
            lrUserSetup.SETRANGE("Salespers./Purch. Code", grPurchHeader."Purchaser Code");
            lrUserSetup.FINDFIRST;

            grPurchHeader."Status App Act" := grPurchHeader."Status App Act"::Checker;
            grPurchHeader.Check := grPurchHeader.Check::"Controler app";

            // Логи не создаем, будет операция утверждения
            // CreateStatusLogAct(grPurchHeader, StatusAppAct::Checker);

            grPurchHeader.VALIDATE("Status App", grPurchHeader."Status App"::Checker);
            grPurchHeader.VALIDATE("Process User", lrUserSetup."User ID");
            grPurchHeader."Date Status App" := TODAY;
            grPurchHeader."Problem Document" := FALSE;
            grPurchHeader."Problem Type" := grPurchHeader."Problem Type"::" ";
            grPurchHeader.MODIFY;

            IF grPurchHeader."Location Document" AND (grPurchHeader."Invoice No." = '') THEN
                CreatePurchOrder(grPurchHeader, false);

            // Уведомления отправляем через шаг рабочего процесса   
            // gcduANM.SendPurchaseMailFromDocAct(grPurchHeader, 0, '');

            // Сообщение шлем через шаг рабочего процесса
            // MESSAGE(TEXT70044);
            EXIT;
        END;
        // ------- Controller -> Checker -------------- <<<<

        IF grPurchHeader."Status App Act" = grPurchHeader."Status App Act"::Checker THEN
            UpdateActHeaderDimByMaxLine(grPurchHeader, PurchSetup, false);

        // ------- Checker -> App   -------------- >>>>
        IF (grPurchHeader."Status App Act" = grPurchHeader."Status App Act"::Checker) AND
            (grPurchHeader.Check in [grPurchHeader.Check::"Approver rej", grPurchHeader.Check::"Controler app"])
        THEN BEGIN

            grPurchHeader.TESTFIELD("Purchaser Code");
            SetDefLocation(grPurchHeader);
            CheckDimensionComb(grPurchHeader);
            CheckDocSum(grPurchHeader);

            IF grPurchHeader."Agreement No." <> '' THEN BEGIN
                CheckActByVendAgreementDates(grPurchHeader);
                CheckAgrDetRemain(grPurchHeader);
            END;

            // NC AB: 
            // GetPurchDocAmount(grPurchHeader, TRUE);
            CheckDocSum(grPurchHeader);

            grPurchHeader."Date Status App" := TODAY;
            grPurchHeader."Status App Act" := grPurchHeader."Status App Act"::Approve;
            grPurchHeader.Check := grPurchHeader.Check::"Checker app";
            grPurchHeader.VALIDATE("Status App", grPurchHeader."Status App"::Approve);
            grPurchHeader."Problem Document" := FALSE;
            grPurchHeader."Problem Type" := grPurchHeader."Problem Type"::" ";

            // Логи не создаем, будет операция утверждения
            // CreateStatusLogAct(grPurchHeader, StatusAppAct::Approve);

            grPurchHeader.Status := grPurchHeader.Status::Open;
            grPurchHeader.MODIFY;

            SetDefLocation(grPurchHeader);

            // NC AB: не понял зачем еще переменная
            // lrPurchHeader.RESET;
            // lrPurchHeader.SETRANGE("Document Type", grPurchHeader."Document Type");
            // lrPurchHeader.SETRANGE("No.", grPurchHeader."No.");
            // IF lrPurchHeader.FIND('-') THEN;

            NextAppr := InsertApproverNCC_FromDocLines(grPurchHeader);

            grPurchHeader."Next Approver" := NextAppr;
            grPurchHeader.Approver := NextAppr;
            grPurchHeader.MODIFY;

            if grPurchHeader."Pre-Approver" <> '' then
                if lrUserSetup.GET(grPurchHeader."Pre-Approver") THEN BEGIN
                    IF lrUserSetup.Absents THEN BEGIN
                        MESSAGE(Text1002, grPurchHeader."Pre-Approver", NextAppr)
                    END ELSE
                        NextAppr := grPurchHeader."Pre-Approver";
                END;

            IF NextAppr <> '' THEN
                IF lrUserSetup.GET(NextAppr) then
                    if lrUserSetup.Absents AND (lrUserSetup.Substitute <> '') THEN BEGIN
                        MESSAGE(Text132, lrUserSetup."User ID", lrUserSetup.Substitute);
                        IF NOT CONFIRM(STRSUBSTNO(TEXT70032, lrUserSetup.Substitute)) THEN
                            ERROR(TEXT70034);
                    END ELSE BEGIN
                        IF NOT CONFIRM(STRSUBSTNO(TEXT70032, NextAppr)) THEN
                            ERROR(TEXT70034);
                    END;

            // NC AB: не понял зачем еще переменная
            // lrPurchHeader.RESET;
            // lrPurchHeader.SETRANGE("Document Type", grPurchHeader."Document Type");
            // lrPurchHeader.SETRANGE("No.", grPurchHeader."No.");
            // IF lrPurchHeader.FIND('-') THEN

            // NC AB: не повоторяем существующий функционал создания операций утверждения и проверки по лимитам 
            // CLEAR(ApprovalMgt);
            // ApprovalMgt.SendPurchaseApprovalRequestAct(lrPurchHeader);

            EXIT;
        END;
        // ------- Checker -> App  -------------- <<<<

        //// ------- Approver -> Сhecker -------------- >>>>
        // ------- Approver -> Signing -------------- >>>>
        IF (grPurchHeader."Status App Act" = grPurchHeader."Status App Act"::Approve) AND
            (grPurchHeader.Check = grPurchHeader.Check::"Checker app")
        THEN BEGIN
            PurchSetup.TestField("Base Vendor No.");
            if grPurchHeader."Buy-from Vendor No." = PurchSetup."Base Vendor No." then
                ERROR(TEXT70004);
            IF (lrVendor."Agreement Posting" = lrVendor."Agreement Posting"::Mandatory) AND (grPurchHeader."Agreement No." = '') THEN
                ERROR(TEXT70005);

            CheckDimensionComb(grPurchHeader);
            IF grPurchHeader."Agreement No." <> '' THEN
                CheckActByVendAgreementDates(grPurchHeader);
            grPurchHeader.TESTFIELD("Purchaser Code");
            grPurchHeader.TESTFIELD("Vendor Invoice No.");

            grPurchHeader."Status App Act" := grPurchHeader."Status App Act"::Signing;
            grPurchHeader.Check := grPurchHeader.Check::"Approver app";
            grPurchHeader.VALIDATE("Status App", grPurchHeader."Status App"::Checker);

            // DEBUG check later
            // CreateStatusLogAct(grPurchHeader, StatusAppAct::Signing);

            lrUserSetup.RESET;
            lrUserSetup.SETRANGE("Salespers./Purch. Code", grPurchHeader."Purchaser Code");
            IF lrUserSetup.FindFirst() THEN
                grPurchHeader.VALIDATE("Process User", lrUserSetup."User ID");

            grPurchHeader."Date Status App" := TODAY;
            grPurchHeader."Problem Document" := FALSE;
            grPurchHeader."Problem Type" := grPurchHeader."Problem Type"::" ";
            grPurchHeader.MODIFY;

            // NC AB: Act (Production) - не используется
            // IF grPurchHeader."Act Type" = grPurchHeader."Act Type"::"Act (Production)" THEN
            //     CreateBCPreBookingAct(grPurchHeader);       

            // DEBUG check later               
            // gcduANM.SendPurchaseMailFromDocAct(grPurchHeader, 0, '');
            // ApprovalMgt.CancelPurchaseApprovals(grPurchHeader);

            MESSAGE(TEXT70045);

            IF NOT grPurchHeader."Location Document" THEN
                EXIT
            ELSE
                grPurchHeader."Status App Act" := grPurchHeader."Status App Act"::Signing;

        END;
        //// ------- Approver -> Сhecker -------------- <<<<
        // ------- Approver -> Signing -------------- <<<<

        IF grPurchHeader."Status App Act" = grPurchHeader."Status App Act"::Checker THEN BEGIN
            PurchSetup.TestField("Cost Code Dimension");
            PurchLine.RESET;
            PurchLine.SETRANGE("Document Type", grPurchHeader."Document Type");
            PurchLine.SETRANGE("Document No.", grPurchHeader."No.");
            PurchLine.SetFilter("Dimension Set ID", '<>0');
            IF PurchLine.FindFirst() THEN
                if DimSetEntry.GET(PurchLine."Dimension Set ID", PurchSetup."Cost Code Dimension") then
                    if DimValue.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code") then
                        if DimValue."Cost Holder" <> '' then begin
                            grPurchHeader.TESTFIELD(PreApprover);
                            grPurchHeader.TESTFIELD("Pre-Approver");
                        end;
        END;

        //// ------- Checker -> Payment   -------------- >>>>
        // ------- Signing -> Payment   -------------- >>>>
        IF (grPurchHeader."Status App Act" = grPurchHeader."Status App Act"::Signing) AND
            (grPurchHeader.Check = grPurchHeader.Check::"Approver app")
        THEN BEGIN
            grPurchHeader.Status := grPurchHeader.Status::Open;
            grPurchHeader."Date Status App" := TODAY;
            grPurchHeader."Status App Act" := grPurchHeader."Status App Act"::Accountant;

            // DEBUG check later    
            // CreateStatusLogAct(grPurchHeader, StatusAppAct::Accountant);

            grPurchHeader.VALIDATE("Status App", grPurchHeader."Status App"::Payment);
            grPurchHeader."Pre-booking Accept" := FALSE;
            grPurchHeader.MODIFY;

            //NC 22512 > DP
            IF NOT grPurchHeader."Location Document" THEN BEGIN
                CreatePurchInvoice(grPurchHeader);
                MESSAGE(TEXT70046);
            END;
            EXIT;
        END;
        // ------- App -> Payment  -------------- <<<<
        */

    end;

    procedure CreateBCPreBookingJConstr(BudCorrJnl: Record "Budget Correction Journal") ret: Boolean
    var
        PCCE: Record "Projects Cost Control Entry";
        ProjectRec: Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
        VendAgr: Record "Vendor Agreement";
        VendAgrDetails: Record "Vendor Agreement Details";
        txtDocNo: Text[20];
        txtDocNo1: Text[20];
        // UniT: Record "Universal Temporary Table";
        PInvLine: Record "Purch. Inv. Line";
    begin
        ret := false;
        Message('cu70000.CreateBCPreBookingJConstr');

    end;

    procedure FiltersForCommitted(pProjectCode: Code[20]; pCostPlaceflt: Code[1024]; pCostType: Code[20])
    var
        lPCCE: Record "Projects Cost Control Entry";
        lComDet: Record "Commited Detail";
        lDelAllComDet: Boolean;
    begin
        lPCCE.Reset();

        IF pProjectCode <> '' THEN
            lPCCE.SETRANGE("Project Code", pProjectCode);
        IF pCostPlaceflt <> '' THEN
            lPCCE.SetFilter("Shortcut Dimension 1 Code", pCostPlaceflt);
        IF pCostType <> '' THEN
            lPCCE.SETRANGE("Cost Type", pCostType);
        //SWC 200 AP 100714 >>
        IF pProjectCode <> '' THEN
            lComDet.SETRANGE("Project Code", pProjectCode);
        IF pCostType <> '' THEN
            lComDet.SETRANGE(CT, pCostType);
        lDelAllComDet := TRUE;
        //SWC 200 AP 100714 <<
        ReFillCommitment(lPCCE, lComDet, lDelAllComDet);
        //SWC 183 EN 020714 <<
    end;

    procedure ReFillCommitment(pPCCE: Record "Projects Cost Control Entry"; pComDet: Record "Commited Detail"; pDelAllComDet: Boolean)
    var
        lrPCCE: Record "Projects Cost Control Entry";
        lrVD: Record "Vendor Agreement Details";
        lrPCCE1: Record "Projects Cost Control Entry";
        lrVD1: Record "Vendor Agreement Details";
        lCommitmentDetail: Record "Commited Detail";
        lrAgreement: Record "Vendor Agreement";
        lCommitDetTMP: Record "Commited Detail" temporary;
    begin

        //SWC 200 AP 100714 >>
        IF pDelAllComDet THEN
            lCommitmentDetail.COPYFILTERS(pComDet);
        //SWC 200 AP 100714 <<
        // SWC996 DD 06.02.17 >>
        lCommitmentDetail.SETFILTER(Comment, '<>''''');
        IF lCommitmentDetail.FINDSET THEN
            REPEAT
                lCommitDetTMP := lCommitmentDetail;
                lCommitDetTMP.INSERT;
            UNTIL lCommitmentDetail.NEXT = 0;
        lCommitmentDetail.SETRANGE(Comment);
        // SWC996 DD 06.02.17 <<
        IF lCommitmentDetail.FINDFIRST THEN lCommitmentDetail.DELETEALL;
        //SWC 183 EN 020714 >>
        IF (pPCCE.GETFILTERS <> '') THEN
            lrPCCE.COPYFILTERS(pPCCE);
        //SWC 183 EN 020714 <<
        lrPCCE.SETCURRENTKEY("Analysis Type", "Close Commitment");
        lrPCCE.SETRANGE("Analysis Type", lrPCCE."Analysis Type"::Actuals);
        //lrPCCE.SETRANGE("Close Commitment",FALSE);
        // SWC DD 12.05.17 >>
        lrPCCE.SETRANGE("Project Storno", FALSE);
        // SWC DD 12.05.17 <<
        IF lrPCCE.FINDSET THEN BEGIN
            REPEAT
                lCommitmentDetail."Vendor No." := lrPCCE."Contragent No.";
                lCommitmentDetail."Agreement No." := lrPCCE."Agreement No.";
                lCommitmentDetail.CP := lrPCCE."Shortcut Dimension 1 Code";
                lCommitmentDetail.CC := lrPCCE."Shortcut Dimension 2 Code";
                lCommitmentDetail.CT := lrPCCE."Cost Type";
                lCommitmentDetail."Turn Code" := lrPCCE."Project Turn Code";
                lCommitmentDetail."Project Code" := lrPCCE."Project Code";
                lCommitmentDetail."Line No." := lrPCCE."Line No.";
                IF lrAgreement.GET(lrPCCE."Contragent No.", lrPCCE."Agreement No.") THEN
                    lCommitmentDetail.ByOrder := lrAgreement.WithOut;


                IF lrPCCE."Line No." <> 0 THEN BEGIN
                    IF lCommitmentDetail.INSERT THEN;


                    lrPCCE1.SETRANGE("Project Code", lrPCCE."Project Code");
                    lrPCCE1.SETRANGE("Entry No.", lrPCCE."Entry No.");
                    IF lrPCCE1.FINDFIRST THEN BEGIN
                        lrPCCE1."Close Commitment" := TRUE;
                        lrPCCE1.MODIFY;
                    END;
                END;
            UNTIL lrPCCE.NEXT = 0;
        END;

        lrVD.SETCURRENTKEY("Close Commitment");
        //lrVD.SETRANGE("Close Commitment",FALSE);
        IF lrVD.FINDSET THEN BEGIN
            REPEAT
                lCommitmentDetail."Vendor No." := lrVD."Vendor No.";
                lCommitmentDetail."Agreement No." := lrVD."Agreement No.";
                lCommitmentDetail.CP := lrVD."Global Dimension 1 Code";
                lCommitmentDetail.CC := lrVD."Global Dimension 2 Code";
                lCommitmentDetail.CT := lrVD."Cost Type";
                lCommitmentDetail."Turn Code" := lrVD."Building Turn All";
                lCommitmentDetail."Line No." := lrVD."Project Line No.";
                lCommitmentDetail."Project Code" := lrVD."Project Code";
                IF lrAgreement.GET(lrVD."Vendor No.", lrVD."Agreement No.") THEN
                    lCommitmentDetail.ByOrder := lrAgreement.WithOut;

                IF lrVD."Project Line No." <> 0 THEN BEGIN
                    IF lCommitmentDetail.INSERT THEN;

                    lrVD1.SETRANGE("Vendor No.", lrVD."Vendor No.");
                    lrVD1.SETRANGE("Agreement No.", lrVD."Agreement No.");
                    lrVD1.SETRANGE("Line No.", lrVD."Line No.");
                    IF lrVD1.FINDFIRST THEN BEGIN
                        lrVD1."Close Commitment" := TRUE;
                        lrVD1.MODIFY;
                    END;
                END;
            UNTIL lrVD.NEXT = 0;
        END;
        //SWC 183 EN 020714 >>
        pPCCE.RESET;
        //SWC 183 EN 020714 <<

        // SWC996 DD 06.02.17 >>
        IF lCommitDetTMP.FINDSET THEN
            REPEAT
                IF lCommitmentDetail.GET(lCommitDetTMP."Vendor No.", lCommitDetTMP."Agreement No.", lCommitDetTMP.CP,
                   lCommitDetTMP.CC, lCommitDetTMP.CT, lCommitDetTMP."Project Code", lCommitDetTMP."Line No.") THEN BEGIN
                    lCommitmentDetail.Comment := lCommitDetTMP.Comment;
                    lCommitmentDetail.MODIFY;
                END;
            UNTIL lCommitDetTMP.NEXT = 0;
        // SWC996 DD 06.02.17 <<
    end;

}