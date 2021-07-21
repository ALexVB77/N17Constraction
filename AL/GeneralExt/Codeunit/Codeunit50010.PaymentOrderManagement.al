codeunit 50010 "Payment Order Management"
{
    trigger OnRun()
    begin

    end;

    var
        InvtSetup: Record "Inventory Setup";
        PurchSetup: record "Purchases & Payables Setup";
        PurchSetupFound: Boolean;
        InvtSetupFound: Boolean;
        ChangeStatusMessage: text;

    procedure CheckUnusedPurchActType(ActTypeOption: enum "Purchase Act Type")
    var
        Text50100: label 'Unused document type.';
    begin
        if ActTypeOption.AsInteger() in [3, 4] then
            error(Text50100);
    end;

    local procedure GetInventorySetup()
    begin
        if not InvtSetupFound then begin
            InvtSetupFound := true;
            InvtSetup.Get();
        end;
    end;

    local procedure GetPurchSetupWithTestDim()
    begin
        if not PurchSetupFound then begin
            PurchSetupFound := true;
            PurchSetup.Get();
            PurchSetup.TestField("Cost Place Dimension");
            PurchSetup.TestField("Cost Code Dimension");
        end;
    end;

    procedure FuncNewRec(PurchHeader: Record "Purchase Header"; ActTypeOption: enum "Purchase Act Type")
    var
        grUS: record "User Setup";
        WhseEmployee: record "Warehouse Employee";
        grPurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Location: Record Location;
        Selected: Integer;
        IsLocationDocument: Boolean;
        LocationCode: code[20];
        // Text50000: Label 'У вас нет прав на создание документа. Данные права имеет контролер.';
        Text50000: Label 'You do not have permission to create the document. The controller has these rights.';
        Text50003: Label 'Warehouse document,Act/KS-2 for the service';
        Text50004: Label 'Select the type of document to create.';
        Text50005: Label 'It is required to select the type of document.';
        LocErrorText1: Label 'The estimator cannot create a document with the type Act!';
    begin
        CheckUnusedPurchActType(ActTypeOption);

        grUS.GET(USERID);
        IF NOT (grUS."Status App Act" IN [grUS."Status App Act"::Сontroller, grUS."Status App Act"::Estimator]) then begin
            MESSAGE(Text50000);
            EXIT;
        end;
        // if (ActTypeOption in [ActTypeOption::Act, ActTypeOption::"Act (Production)"]) and (grUS."Status App Act" = grUS."Status App Act"::Estimator) then
        //    ERROR(LocErrorText1);
        if (ActTypeOption = ActTypeOption::Act) and (grUS."Status App Act" = grUS."Status App Act"::Estimator) then
            ERROR(LocErrorText1);

        GetPurchSetupWithTestDim;
        PurchSetup.TestField("Base Vendor No.");

        WhseEmployee.SetRange("User ID", UserId);
        IF WhseEmployee.FindFirst() THEN BEGIN
            Selected := DIALOG.STRMENU(Text50003, 1, Text50004);
            CASE Selected OF
                1:
                    BEGIN
                        IsLocationDocument := TRUE;
                        Location.GET(WhseEmployee.GetDefaultLocation('', TRUE));
                        Location.TESTFIELD("Bin Mandatory", FALSE);
                        LocationCode := Location.Code;
                    END;
                2:
                    ;
                ELSE
                    ERROR(Text50005);
            END;
        END;

        GetInventorySetup();
        if not IsLocationDocument then
            InvtSetup.TestField("Temp Item Code");

        with grPurchHeader do begin
            RESET;
            INIT;
            "No." := '';
            "Document Type" := "Document Type"::Order;
            "Pre-booking Document" := TRUE;
            "Act Type" := ActTypeOption;
            INSERT(TRUE);
            VALIDATE("Buy-from Vendor No.", PurchSetup."Base Vendor No.");

            if IsLocationDocument then begin
                "Location Document" := TRUE;
                Storekeeper := USERID;
                VALIDATE("Location Code", LocationCode);
            end;

            "Status App Act" := "Status App Act"::Controller;
            "Process User" := USERID;
            "Payment Doc Type" := "Payment Doc Type"::"Payment Request";
            "Date Status App" := TODAY;
            Controller := USERID;
            // if "Act Type" in ["Act Type"::"KC-2", "Act Type"::"KC-2 (Production)"] then
            if "Act Type" = "Act Type"::"KC-2" then
                if PurchSetup."Default Estimator" <> '' then
                    Estimator := PurchSetup."Default Estimator";
            MODIFY(TRUE);

            PurchLine.Init;
            PurchLine."Document Type" := "Document Type";
            PurchLine."Document No." := "No.";
            PurchLine."Line No." := 10000;
            PurchLine.Validate(Type, PurchLine.Type::Item);
            if not "Location Document" then
                PurchLine.Validate("No.", InvtSetup."Temp Item Code")
            else
                PurchLine."Location Code" := LocationCode;
            PurchLine.Insert(true);

            COMMIT;
            PAGE.RUNMODAL(PAGE::"Purchase Order Act", grPurchHeader);
        end;
    end;

    procedure NewOrderApp(PurchHeader: Record "Purchase Header")
    var
        grPurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        grUS: Record "User Setup";
    begin

        GetPurchSetupWithTestDim;
        PurchSetup.TestField("Base Vendor No.");

        grUS.GET(USERID);

        grPurchHeader.RESET;
        grPurchHeader.INIT;
        grPurchHeader."No." := '';
        grPurchHeader."Document Type" := grPurchHeader."Document Type"::Order;
        grPurchHeader."IW Documents" := TRUE;
        grPurchHeader.INSERT(TRUE);

        grPurchHeader.VALIDATE("Buy-from Vendor No.", PurchSetup."Base Vendor No.");
        grPurchHeader.VALIDATE("Status App", grUS."Status App");
        grPurchHeader."Process User" := USERID;
        IF grUS."Status App" <> grUS."Status App"::Reception THEN
            grPurchHeader."Payment Doc Type" := grPurchHeader."Payment Doc Type"::"Payment Request"
        ELSE
            grPurchHeader."Payment Doc Type" := grPurchHeader."Payment Doc Type"::Invoice;
        grPurchHeader."Status App" := grPurchHeader."Status App"::Reception;
        grPurchHeader."Date Status App" := TODAY;

        grPurchHeader.Receptionist := UserId;
        grPurchHeader.MODIFY(TRUE);

        PurchLine.Init;
        PurchLine."Document Type" := grPurchHeader."Document Type";
        PurchLine."Document No." := grPurchHeader."No.";
        PurchLine."Line No." := 10000;
        PurchLine.Validate(Type, PurchLine.Type::Item);
        PurchLine.Validate("No.", InvtSetup."Temp Item Code");
        PurchLine.Insert(true);

        COMMIT;
        Page.RUNMODAL(Page::"Purchase Order App", grPurchHeader);
    end;

    procedure CreatePurchaseOrderAppFromAct(PurchaseHeader: Record "Purchase Header")
    var
        InvtSetup: Record "Inventory Setup";
        PaymentInvoice: Record "Purchase Header";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Currency: Record Currency;
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        RemAmount: Decimal;
        LinkedActExists: Boolean;
        RemActAmount: Decimal;
        FromDocType: Enum "Purchase Document Type From";
    begin
        CalcActRemaingAmount(PurchaseHeader, PaymentInvoice, LinkedActExists, RemAmount);

        PaymentInvoice.RESET;
        PaymentInvoice.INIT;
        PaymentInvoice."No." := '';
        PaymentInvoice."Document Type" := PaymentInvoice."Document Type"::Order;
        PaymentInvoice."IW Documents" := TRUE;
        PaymentInvoice.INSERT(TRUE);

        GetPurchSetupWithTestDim;
        CopyDocMgt.SetProperties(true, true, false, false, false, PurchSetup."Exact Cost Reversing Mandatory", false);
        CopyDocMgt.CopyPurchDoc(FromDocType::Order, PurchaseHeader."No.", PaymentInvoice);

        PaymentInvoice."IW Documents" := TRUE;
        PaymentInvoice."Act Type" := PaymentInvoice."Act Type"::" ";
        if LinkedActExists then begin
            InvtSetup.Get();
            InvtSetup.TestField("Temp Item Code");
            Item.Get(InvtSetup."Temp Item Code");
            Item.TestField("VAT Prod. Posting Group");
            VATPostingSetup.GET(PaymentInvoice."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");

            if PaymentInvoice."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else
                Currency.GET(PaymentInvoice."Currency Code");

            PaymentInvoice."Invoice Amount Incl. VAT" := RemActAmount;
            PaymentInvoice."Invoice VAT Amount" :=
                RemActAmount - Round(RemActAmount / (1 + (1 - 0 / 100) * VATPostingSetup."VAT %" / 100), Currency."Amount Rounding Precision");
        end;
        PaymentInvoice."Linked Purchase Order Act No." := PurchaseHeader."No.";
        PaymentInvoice.Modify(true);

        COMMIT;
        Page.RUNMODAL(Page::"Purchase Order App", PaymentInvoice);
    end;

    procedure LinkActAndPaymentInvoice(ActNo: code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PaymentInvoice: Record "Purchase Header";
        PurchListApp: Page "Purchase List App";
        LinkedActExists: Boolean;
        RemAmount: Decimal;
        LinkedCount: Integer;
        LocText001: Label 'There are no payment invoices to be linked to the act %1.';
        LocText002: Label '%1 payment invoices were related to Act %2.';
    begin
        PurchaseHeader.get(PurchaseHeader."Document Type"::Order, ActNo);
        CalcActRemaingAmount(PurchaseHeader, PaymentInvoice, LinkedActExists, RemAmount);

        PaymentInvoice.Reset();
        PaymentInvoice.FilterGroup(2);
        PaymentInvoice.SetCurrentKey("Buy-from Vendor No.", "Agreement No.");
        PaymentInvoice.SetRange("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
        PaymentInvoice.SetRange("Agreement No.", PurchaseHeader."Agreement No.");
        PaymentInvoice.SetRange("IW Documents", true);
        PaymentInvoice.SetRange("Linked Purchase Order Act No.", '');
        PaymentInvoice.SetRange("Document Type", PaymentInvoice."Document Type"::Order);
        PaymentInvoice.FilterGroup(0);
        if not PaymentInvoice.IsEmpty then begin
            PurchListApp.SetTableView(PaymentInvoice);
            PurchListApp.LookupMode(true);
            if PurchListApp.RunModal() = Action::LookupOK then begin
                PurchListApp.SetSelectionFilter(PaymentInvoice);
                if PaymentInvoice.FindSet() then
                    repeat
                        if RemAmount >= PaymentInvoice."Invoice Amount Incl. VAT" then begin
                            PaymentInvoice."Linked Purchase Order Act No." := ActNo;
                            PaymentInvoice.Modify();
                            RemAmount -= PaymentInvoice."Invoice Amount Incl. VAT";
                            LinkedCount += 1;
                        end;
                    until PaymentInvoice.next = 0;
                Message(LocText002, LinkedCount, ActNo);
            end;
            exit;
        end;
        Message(LocText001);
    end;

    local procedure CalcActRemaingAmount(PurchaseHeader: Record "Purchase Header"; PaymentInvoice: Record "Purchase Header"; var LinkedActExists: Boolean; var RemActAmount: Decimal)
    var
        LocText001: Label 'The total amount of linked payment orders exceeds the amount of Act %1.';
    begin
        PurchaseHeader.TestField("Invoice Amount Incl. VAT");
        RemActAmount := PurchaseHeader."Invoice Amount Incl. VAT";
        PaymentInvoice.SetCurrentKey("IW Documents", "Linked Purchase Order Act No.");
        PaymentInvoice.SetRange("IW Documents", true);
        PaymentInvoice.SetRange("Linked Purchase Order Act No.", PurchaseHeader."No.");
        PaymentInvoice.SetRange("Document Type", PaymentInvoice."Document Type"::Order);
        LinkedActExists := not PaymentInvoice.IsEmpty;
        if LinkedActExists then begin
            PaymentInvoice.CalcSums("Invoice Amount Incl. VAT");
            if PaymentInvoice."Invoice Amount Incl. VAT" >= PurchaseHeader."Invoice Amount Incl. VAT" then
                error(LocText001, PurchaseHeader."No.");
            RemActAmount -= PaymentInvoice."Invoice Amount Incl. VAT";
        end;
    end;

    procedure ActInterBasedOn(PurchHeader: Record "Purchase Header")
    var
        InvSetup: Record "Inventory Setup";
        PurchLine: Record "Purchase Line";
        VendArgDtld: Record "Vendor Agreement Details";
        VendArgDtld2: Record "Vendor Agreement Details";
        VendArgDtldPage: Page "Vendor Agreement Details";
        Text001: Label 'Nothing selected!';
        LineNo: Integer;
        Amt: Decimal;
    begin
        with PurchHeader do begin
            TESTFIELD("Agreement No.");
            InvSetup.GET;
            InvSetup.TESTFIELD("Temp Item Code");
            VendArgDtld.SETRANGE("Agreement No.", "Agreement No.");
            VendArgDtldPage.SETRECORD(VendArgDtld);
            VendArgDtldPage.SETTABLEVIEW(VendArgDtld);
            VendArgDtldPage.LOOKUPMODE(TRUE);
            IF VendArgDtldPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
                VendArgDtldPage.SetSelectionFilter(VendArgDtld2);
                IF NOT VendArgDtld2.FINDSET THEN
                    ERROR(Text001);
                PurchLine.SETRANGE("Document No.", "No.");
                PurchLine.SETRANGE("Document Type", "Document Type");
                LineNo := 0;
                IF PurchLine.FINDLAST THEN
                    LineNo := PurchLine."Line No.";
                REPEAT
                    Amt := VendArgDtld2.GetRemainAmt;
                    IF Amt > 0 THEN BEGIN
                        LineNo += 10000;
                        PurchLine.INIT;
                        PurchLine."Document Type" := "Document Type";
                        PurchLine."Document No." := "No.";
                        PurchLine."Line No." := LineNo;
                        PurchLine.VALIDATE(Type, PurchLine.Type::Item);
                        PurchLine.VALIDATE("No.", InvSetup."Temp Item Code");
                        PurchLine.INSERT(TRUE);
                        PurchLine.VALIDATE(Quantity, 1);
                        PurchLine.VALIDATE("Currency Code", VendArgDtld2."Currency Code");
                        PurchLine.VALIDATE("Full Description", COPYSTR(VendArgDtld2.Description, 1, MAXSTRLEN(PurchLine."Full Description")));
                        PurchLine.VALIDATE("Unit Cost (LCY)", ROUND(Amt / (100 + PurchLine."VAT %") * 100, 0.000001));
                        PurchLine.VALIDATE("Direct Unit Cost", PurchLine."Unit Cost (LCY)");
                        PurchLine.VALIDATE("Shortcut Dimension 1 Code", VendArgDtld2."Global Dimension 1 Code");
                        PurchLine.VALIDATE("Shortcut Dimension 2 Code", VendArgDtld2."Global Dimension 2 Code");
                        PurchLine.VALIDATE("Cost Type", VendArgDtld2."Cost Type");
                        PurchLine.VALIDATE("VAT Prod. Posting Group");
                        PurchLine.MODIFY(TRUE);

                        // SetPurchLineApprover(PurchLine, true);
                        PurchLine.MODIFY;
                    END;
                UNTIL VendArgDtld2.NEXT = 0;
            END;
        end;

    end;

    // NC AB: не используем, Approver заполяем на лету через функцию 
    // procedure SetPurchLineApprover(var PurchLine: Record "Purchase Line"; CheckSubstitute: Boolean)
    // var
    //     DimSetEntry: Record "Dimension Set Entry";
    //     DimValue: Record "Dimension Value";
    //      UserSetup: Record "User Setup";
    //     PurchasesSetup: Record "Purchases & Payables Setup";
    // begin
    //     with PurchLine do begin
    //         IF ("Dimension Set ID" = 0) or (Approver <> '') then
    //             EXIT;
    //         IF "Dimension Set ID" <> 0 THEN begin
    //             PurchasesSetup.GET;
    //             PurchasesSetup.TestField("Cost Place Dimension");
    //             IF DimSetEntry.GET("Dimension Set ID", PurchasesSetup."Cost Place Dimension") THEN
    //                 IF DimValue.GET(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code") then
    //                     if not CheckSubstitute THEN
    //                         Approver := DimValue."Cost Holder"
    //                     else
    //                         if DimValue."Cost Holder" <> '' THEN BEGIN
    //                             UserSetup.GET(DimValue."Cost Holder");
    //                             IF UserSetup.Absents AND (UserSetup.Substitute <> '') THEN
    //                                 Approver := UserSetup.Substitute
    //                             ELSE
    //                                 Approver := UserSetup."User ID";
    //                         END;
    //         END;
    //     end;
    // end;

    // NC AB: не используем, Approver заполяем на лету через функцию 
    // procedure FillPurchLineApproverFromGlobalDim(GlobalDimNo: Integer; DimValueCode: code[20]; var PurchLine: Record "Purchase Line"; CheckSubstitute: Boolean)
    // var
    //     DimValue: Record "Dimension Value";
    //     UserSetup: Record "User Setup";
    //     PurchasesSetup: Record "Purchases & Payables Setup";
    // begin
    //     if DimValueCode = '' then
    //         exit;
    //     DimValue.SetRange(Code, DimValueCode);
    //     DimValue.SetRange("Global Dimension No.", GlobalDimNo);
    //     if not DimValue.FindFirst() then
    //         exit;
    //      PurchasesSetup.GET;
    //     PurchasesSetup.TestField("Cost Place Dimension");
    //     if PurchasesSetup."Cost Place Dimension" <> DimValue."Dimension Code" then
    //         exit;
    //     if not CheckSubstitute THEN
    //         PurchLine.Approver := DimValue."Cost Holder"
    //     else
    //         if DimValue."Cost Holder" <> '' THEN BEGIN
    //             UserSetup.GET(DimValue."Cost Holder");
    //             IF UserSetup.Absents AND (UserSetup.Substitute <> '') THEN
    //                 PurchLine.Approver := UserSetup.Substitute
    //             ELSE
    //                 PurchLine.Approver := UserSetup."User ID";
    //         END;
    // end;

    procedure PurchOrderActArchiveQst(PurchHeader: Record "Purchase Header"): Boolean;
    var
        UserSetup: record "User Setup";
        LocText50000: Label 'Budget data will be deleted. Add a document to the archive of problem documents?';
        LocText50008: Label 'Do you want to add %1 %2 to the archive of problem documents and send the Order %3 to the archive? Order-related Receipts will be canceled.';
        LocText50009: Label 'Access is denied.';
        LocText50010: label 'Do you want to add a document to the archive of problem documents?';
        LocText50011: Label 'You can send a document to the archive at the stage of Controller, Approve, Signing or Accountant!';
        LocText50012: Label 'You can send a document to the archive only at the Verification stage.';
        Txt: Text;
    begin
        with PurchHeader do begin
            IF "Location Document" THEN BEGIN
                IF "Status App Act" <> "Status App Act"::Checker THEN
                    ERROR(LocText50012);
                UserSetup.GET(USERID);
                IF "Process User" <> USERID THEN
                    ERROR(LocText50009);
                IF PurchHeader.GET("Document Type"::Order, "Invoice No.") THEN
                    Txt := STRSUBSTNO(LocText50008, "Act Type", "No.", PurchHeader."No.")
                ELSE
                    Txt := LocText50010;
                IF NOT CONFIRM(Txt, FALSE) THEN
                    exit(false);
                PurchOrderActArchive(PurchHeader);
                IF PurchHeader.GET("Document Type"::Order, "Invoice No.") THEN
                    PurchHeader.PurchOrderArchive();
            END ELSE BEGIN
                IF "Status App Act" IN
                    ["Status App Act"::"Controller", "Status App Act"::Approve, "Status App Act"::Signing, "Status App Act"::Accountant]
                THEN BEGIN
                    IF "Status App Act" = "Status App Act"::Signing THEN
                        Txt := LocText50000
                    ELSE
                        Txt := LocText50010;
                    IF not CONFIRM(Txt, TRUE) THEN
                        exit(false);
                    PurchOrderActArchive(PurchHeader);
                END ELSE
                    ERROR(LocText50011);
            END;
        end;
        exit(true);
    end;

    local procedure PurchOrderActArchive(PurchHeader: Record "Purchase Header");
    var
        gvduERPC: Codeunit "ERPC Funtions";
        LocText50013: Label 'Document %1 has been sent to the archive.';
        ArchiveMgt: Codeunit ArchiveManagement;
    begin
        DeleteRelatedInvoiceDoc(PurchHeader);
        gvduERPC.DeleteBCPreBooking(PurchHeader); //Удаление бюджета
        PurchHeader."Problem Document" := TRUE;
        PurchHeader."Problem Type" := PurchHeader."Problem Type"::"Act error";
        // NC AB >>
        // не оставляем архивный акт в T36 и T37, оправляем его в T5109 и T5110
        // PurchHeader.MODIFY();
        PurchHeader."Archiving Type" := PurchHeader."Archiving Type"::"Problem Act";
        ArchiveMgt.StorePurchDocument(PurchHeader, false);
        PurchHeader.SetHideValidationDialog(true);
        PurchHeader.Delete(true);
        // NC AB <<
        MESSAGE(LocText50013, PurchHeader."No.");
    end;

    procedure DeleteRelatedInvoiceDoc(var InPurchHeader: Record "Purchase Header")
    var
        PurchHeader: record "Purchase Header";
        PurchCommentLine: record "Purch. Comment Line";
        DocSignMgt: codeunit "Doc. Signature Management";
    begin
        IF InPurchHeader."Invoice No." <> '' THEN BEGIN
            IF PurchHeader.GET(PurchHeader."Document Type"::Invoice, InPurchHeader."Invoice No.") THEN BEGIN
                DocSignMgt.DeleteDocSign(DATABASE::"Purchase Header", PurchHeader."Document Type".AsInteger(), PurchHeader."No.");
                PurchCommentLine.DeleteComments(PurchHeader."Document Type".AsInteger(), PurchHeader."No.");
                InPurchHeader."Invoice No." := '';
                InPurchHeader.MODIFY();
            END;
        END;
    end;

    procedure PurchPaymentInvoiceArchive(PurchHeader: Record "Purchase Header"): Boolean;
    var
        ArchiveMgt: Codeunit ArchiveManagement;
        ConfirmManagement: Codeunit "Confirm Management";
        LocText001: Label 'Document %1 has been archived.';
        LocText007: Label 'Archive %1 no.: %2?';
    begin
        PurchHeader.TestField("Status App", PurchHeader."Status App"::Payment);

        if not ConfirmManagement.GetResponseOrDefault(
             StrSubstNo(LocText007, PurchHeader."Document Type", PurchHeader."No."), true)
        then
            exit(false);
        PurchHeader."Archiving Type" := PurchHeader."Archiving Type"::"Problem Act";
        ArchiveMgt.StorePurchDocument(PurchHeader, false);
        //NC 44684 > KGT
        DisconnectFromAgreement(PurchHeader);
        //NC 44684 < KGT
        PurchHeader.SetHideValidationDialog(true);
        PurchHeader.Delete(true);
        Message(LocText001, PurchHeader."No.");
        exit(true);
    end;

    procedure DisconnectFromAgreement(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        ProjectsBudgetEntry: Record "Projects Budget Entry";
        ForecastListAnalisys: page "Forecast List Analisys";
        ProjectBudgetMgt: Codeunit "Project Budget Management";
    begin
        // debug see later
        message('Вызов DisconnectFromAgreement');
        exit;

        //NC 44684 > KGT
        PurchaseLine.RESET;
        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        IF PurchaseLine.FINDSET THEN BEGIN
            REPEAT
                IF PurchaseLine."Forecast Entry" <> 0 THEN BEGIN
                    ProjectsBudgetEntry.SETCURRENTKEY("Entry No.");
                    ProjectsBudgetEntry.SETRANGE("Entry No.", PurchaseLine."Forecast Entry");
                    IF ProjectsBudgetEntry.FINDFIRST THEN BEGIN
                        PurchaseLine."Forecast Entry" := 0;
                        PurchaseLine.MODIFY;
                        ProjectBudgetMgt.DeleteSTLine(ProjectsBudgetEntry);
                        // ForecastListAnalisys.SETRECORD(ProjectsBudgetEntry);
                        // message('Вызов ForecastListAnalisys.DisconnectFromAgreement');
                        // exit;
                    END;
                END;
            UNTIL PurchaseLine.NEXT = 0;
        END;
        //NC 44684 < KGT
    end;

    local procedure CheckCostDimExists(DimensionSetID: Integer): Boolean
    var
        DimSetEntry: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        if DimensionSetID = 0 then
            exit(false);
        GetPurchSetupWithTestDim();
        DimSetEntry.SetRange("Dimension Set ID", DimensionSetID);
        DimSetEntry.SetFilter("Dimension Code", '%1|%2', PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension");
        if DimSetEntry.Count <> 2 then
            exit(false);

        DimSetEntry.FindSet();
        repeat
            TempDimSetEntry := DimSetEntry;
            TempDimSetEntry."Dimension Set ID" := 0;
            TempDimSetEntry.Insert;
        until DimSetEntry.Next() = 0;
        DimMgt.CheckDimIDComb(DimMgt.GetDimensionSetID(TempDimSetEntry));

        exit(true);
    end;

    local procedure CheckCostDimExistsInLine(var PurchLine: Record "Purchase Line")
    var
        LocText001: Label 'You must specify %1 and %2 for %3 line %4.';
    begin
        if not CheckCostDimExists(PurchLine."Dimension Set ID") then
            Error(LocText001, PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension", PurchLine."Document No.", PurchLine."Line No.");
    end;

    local procedure CheckCostDimExistsInHeader(var PurchHeader: Record "Purchase Header")
    var
        LocText001: Label 'You must specify %1 and %2 for %3.';
    begin
        if not CheckCostDimExists(PurchHeader."Dimension Set ID") then
            Error(LocText001, PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension", PurchHeader."No.");
    end;

    procedure ChangePurchaseOrderActStatus(var PurchHeader: Record "Purchase Header"; Reject: Boolean; RejectEntryNo: Integer)
    var
        DocumentAttachment: Record "Document Attachment";
        Vendor: Record Vendor;
        PurchLine: Record "Purchase Line";
        ERPCFunc: Codeunit "ERPC Funtions";
        PreAppover: Code[50];
        ProblemType: enum "Purchase Problem Type";
        LocText010: Label 'No Approver specified on line %1.';
        LocText020: Label 'No linked approval entry found.';
        Text50016: label 'You must select the real item before document posting.';
        TEXT70001: label 'There is no attachment!';
        TEXT70004: Label 'Vendor does not have to be basic!';
    begin
        CheckUnusedPurchActType(PurchHeader."Act Type");
        if Reject and (RejectEntryNo = 0) then
            Error(LocText020);

        GetPurchSetupWithTestDim;

        PurchHeader.TestField("Status App Act");
        PurchHeader.TestField(Controller);

        if Reject then
            CheckApprovalCommentLineExist(RejectEntryNo);

        ChangeStatusMessage := '';

        // проверки и дозаполнение

        if (PurchHeader."Status App Act".AsInteger() >= PurchHeader."Status App Act"::Controller.AsInteger()) and (not Reject) then begin
            PurchSetup.TestField("Base Vendor No.");
            if PurchHeader."Buy-from Vendor No." = PurchSetup."Base Vendor No." then
                ERROR(TEXT70004);
            Vendor.Get(PurchHeader."Buy-from Vendor No.");
            IF Vendor."Agreement Posting" = Vendor."Agreement Posting"::Mandatory then
                PurchHeader.Testfield("Agreement No.");

            DocumentAttachment.SetRange("Table ID", DATABASE::"Purchase Header");
            DocumentAttachment.SetRange("Document Type", PurchHeader."Document Type");
            DocumentAttachment.SetRange("No.", PurchHeader."No.");
            if DocumentAttachment.IsEmpty then
                ERROR(TEXT70001);

            PurchHeader.Testfield("Purchaser Code");
            PurchHeader.TESTFIELD("Vendor Invoice No.");

            IF PurchHeader."Location Document" THEN begin
                PurchHeader.TESTFIELD("Location Code");

                GetInventorySetup;
                PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
                PurchLine.SETRANGE("Document No.", PurchHeader."No.");
                PurchLine.SETRANGE(Type, PurchLine.Type::Item);
                PurchLine.SETRANGE("No.", InvtSetup."Temp Item Code");
                IF not PurchLine.IsEmpty THEN
                    ERROR(Text50016);
                PurchLine.SETRANGE("No.");
                PurchLine.FindSet();
                repeat
                    PurchLine.TestField("No.");
                    PurchLine.TestField(Quantity);
                    PurchLine.TestField("Location Code");
                    CheckCostDimExistsInLine(PurchLine);
                until PurchLine.Next() = 0;
            end;
        end;

        if (PurchHeader."Status App Act".AsInteger() >= PurchHeader."Status App Act"::Checker.AsInteger()) and (not Reject) then begin
            GetInventorySetup;
            PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
            PurchLine.SETRANGE("Document No.", PurchHeader."No.");
            PurchLine.SETRANGE(Type, PurchLine.Type::Item);
            PurchLine.FindSet();
            repeat
                PurchLine.TestField("No.");
                PurchLine.TestField(Quantity);
                CheckCostDimExistsInLine(PurchLine);
                if GetPurchActApproverFromDim(PurchLine."Dimension Set ID") = '' then
                    Error(LocText010, PurchLine."Line No.");
            until PurchLine.Next() = 0;

            PurchHeader.TestField("Invoice Amount Incl. VAT");
            ERPCFunc.CheckDocSum(PurchHeader);

            if not PurchHeader."Location Document" then begin
                GetInventorySetup;
                InvtSetup.TestField("Default Location Code");
                PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
                PurchLine.SETRANGE("Document No.", PurchHeader."No.");
                PurchLine.SETRANGE(Type, PurchLine.Type::Item);
                PurchLine.SetFilter("Location Code", '%1', '');
                if not PurchLine.IsEmpty then
                    PurchLine.ModifyAll("Location Code", InvtSetup."Default Location Code", true);
            end;
        end;

        // изменение статусов

        case PurchHeader."Status App Act" of
            PurchHeader."Status App Act"::Controller:
                if PurchHeader."Act Type" = PurchHeader."Act Type"::"KC-2" then begin
                    PurchHeader.TestField(Estimator);
                    FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Estimator, PurchHeader.Estimator, ProblemType::" ", Reject);
                end else begin
                    PurchActPostShipment(PurchHeader);
                    FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Checker, GetPurchActChecker(PurchHeader), ProblemType::" ", Reject);
                end;
            PurchHeader."Status App Act"::Estimator:
                if not Reject then begin
                    PurchActPostShipment(PurchHeader);
                    FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Checker, GetPurchActChecker(PurchHeader), ProblemType::" ", Reject);
                end else
                    FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Controller, PurchHeader.Controller, ProblemType::REstimator, Reject);
            PurchHeader."Status App Act"::Checker:
                if not Reject then begin
                    PreAppover := GetPurchActPreApproverFromDim(PurchHeader."Dimension Set ID");
                    if PreAppover <> '' then begin
                        PurchHeader."Sent to pre. Approval" := true;
                        FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Approve, PreAppover, ProblemType::" ", Reject);
                    end else begin
                        PurchHeader."Sent to pre. Approval" := false;
                        FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Approve, GetApproverFromActLines(PurchHeader), ProblemType::" ", Reject);
                    end;
                end else begin
                    if PurchHeader."Act Type" = PurchHeader."Act Type"::"KC-2" then begin
                        PurchHeader.TestField(Estimator);
                        FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Estimator, PurchHeader.Estimator, ProblemType::RChecker, Reject);
                    end else
                        FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Controller, PurchHeader.Controller, ProblemType::RChecker, Reject);
                end;
            PurchHeader."Status App Act"::Approve:
                if PurchHeader."Sent to pre. Approval" then begin
                    PurchHeader."Sent to pre. Approval" := false;
                    if not Reject then
                        FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Approve, GetApproverFromActLines(PurchHeader), ProblemType::" ", Reject)
                    else
                        FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Checker, GetPurchActChecker(PurchHeader), ProblemType::RApprover, Reject);
                end else begin
                    if not Reject then
                        FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Signing, GetPurchActChecker(PurchHeader), ProblemType::" ", Reject)
                    else begin
                        PreAppover := GetPurchActPreApproverFromDim(PurchHeader."Dimension Set ID");
                        if PreAppover <> '' then begin
                            PurchHeader."Sent to pre. Approval" := true;
                            FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Approve, PreAppover, ProblemType::RApprover, Reject);
                        end else
                            FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Checker, GetPurchActChecker(PurchHeader), ProblemType::RApprover, Reject);
                    end;
                end;
            PurchHeader."Status App Act"::Signing:
                if not Reject then begin
                    CreatePurchInvForAct(PurchHeader);
                    FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Accountant, PurchHeader.Controller, ProblemType::" ", Reject);
                end else
                    FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Approve, GetApproverFromActLines(PurchHeader), ProblemType::"Act error", Reject);
        end
    end;

    procedure ChangePurchasePaymentInvoiceStatus(var PurchHeader: Record "Purchase Header"; Reject: Boolean; RejectEntryNo: Integer)
    var
        PurchLine: Record "Purchase Line";
        VendAreement: Record "Vendor Agreement";
        DimSetEntry: Record "Dimension Set Entry";
        DimValue: Record "Dimension Value";
        ERPCFunc: Codeunit "ERPC Funtions";
        AppStatus: Enum "Purchase Approval Status";
        ProblemType: enum "Purchase Problem Type";
        PreAppover: Code[50];
        LocText010: Label 'No Approver specified on line %1.';
        LocText020: Label 'No linked approval entry found.';
    begin
        if Reject and (RejectEntryNo = 0) then
            Error(LocText020);

        GetPurchSetupWithTestDim;

        PurchHeader.TestField("Status App");
        PurchHeader.TestField(Receptionist);

        if Reject then
            CheckApprovalCommentLineExist(RejectEntryNo);

        ChangeStatusMessage := '';

        // проверки и дозаполнение

        if (PurchHeader."Status App" >= PurchHeader."Status App"::Reception) and (not Reject) then begin
            PurchHeader.TestField("Pay-to Vendor No.");
            PurchHeader.TestField("Vendor Bank Account");
            PurchHeader.TestField("Vendor Bank Account No.");
            PurchHeader.TestField(Controller);
        end;

        if (PurchHeader."Status App" >= PurchHeader."Status App"::Controller) and (not Reject) then begin
            PurchHeader.TestField("Buy-from Vendor No.");
            PurchHeader.TestField("Agreement No.");
            PurchHeader.TestField("Purchaser Code");
            PurchHeader.TestField("Vendor Invoice No.");
        end;

        if (PurchHeader."Status App" >= PurchHeader."Status App"::Checker) and (not Reject) then begin
            CheckCostDimExistsInHeader(PurchHeader);
            VendAreement.Get(PurchHeader."Buy-from Vendor No.", PurchHeader."Agreement No.");

            PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
            PurchLine.SETRANGE("Document No.", PurchHeader."No.");
            PurchLine.SETRANGE(Type, PurchLine.Type::Item);
            PurchLine.FindSet();
            repeat
                if PurchLine.Type <> PurchLine.Type::" " then begin
                    PurchLine.TestField("No.");
                    PurchLine.TestField(Quantity);
                end;
                CheckCostDimExistsInLine(PurchLine);
                DimSetEntry.Get(PurchLine."Dimension Set ID", PurchSetup."Cost Place Dimension");
                DimValue.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code");
                if (not PurchSetup."Skip Check CF in Doc. Lines") and DimValue."Check CF Forecast" and (not VendAreement."Don't Check CashFlow") then
                    PurchLine.TestField("Forecast Entry");
                if GetPurchActApproverFromDim(PurchLine."Dimension Set ID") = '' then
                    Error(LocText010, PurchLine."Line No.");
            until PurchLine.Next() = 0;

            PurchHeader.TestField("Invoice Amount Incl. VAT");
            ERPCFunc.CheckDocSum(PurchHeader);
            if PurchHeader."Payment Type" = PurchHeader."Payment Type"::"pre-pay" then
                PurchHeader.Testfield("IW Planned Repayment Date");
        end;

        // изменение статусов

        case PurchHeader."Status App" of
            PurchHeader."Status App"::Reception:
                FillPayInvStatus(PurchHeader, AppStatus::Controller, PurchHeader.Controller, ProblemType::" ", Reject);
            PurchHeader."Status App"::Controller:
                if not Reject then
                    FillPayInvStatus(PurchHeader, AppStatus::Checker, GetPurchActChecker(PurchHeader), ProblemType::" ", Reject)
                else
                    FillPayInvStatus(PurchHeader, AppStatus::Reception, PurchHeader.Receptionist, ProblemType::RController, Reject);
            PurchHeader."Status App"::Checker:
                if not Reject then begin
                    PreAppover := GetPurchActPreApproverFromDim(PurchHeader."Dimension Set ID");
                    if PreAppover <> '' then begin
                        PurchHeader."Sent to pre. Approval" := true;
                        FillPayInvStatus(PurchHeader, AppStatus::Approve, PreAppover, ProblemType::" ", Reject);
                    end else begin
                        PurchHeader."Sent to pre. Approval" := false;
                        FillPayInvStatus(PurchHeader, AppStatus::Approve, GetApproverFromActLines(PurchHeader), ProblemType::" ", Reject);
                    end;
                end else
                    FillPayInvStatus(PurchHeader, AppStatus::Controller, PurchHeader.Controller, ProblemType::RChecker, Reject);
            PurchHeader."Status App"::Approve:
                if PurchHeader."Sent to pre. Approval" then begin
                    PurchHeader."Sent to pre. Approval" := false;
                    if not Reject then
                        FillPayInvStatus(PurchHeader, AppStatus::Approve, GetApproverFromActLines(PurchHeader), ProblemType::" ", Reject)
                    else
                        FillPayInvStatus(PurchHeader, AppStatus::Checker, GetPurchActChecker(PurchHeader), ProblemType::RApprover, Reject);
                end else begin
                    if not Reject then
                        FillPayInvStatus(PurchHeader, AppStatus::Payment, PurchHeader.Receptionist, ProblemType::" ", Reject)
                    else begin
                        PreAppover := GetPurchActPreApproverFromDim(PurchHeader."Dimension Set ID");
                        if PreAppover <> '' then begin
                            PurchHeader."Sent to pre. Approval" := true;
                            FillPayInvStatus(PurchHeader, AppStatus::Approve, PreAppover, ProblemType::RApprover, Reject);
                        end else
                            FillPayInvStatus(PurchHeader, AppStatus::Checker, GetPurchActChecker(PurchHeader), ProblemType::RApprover, Reject);
                    end;
                end;
        end;
    end;

    local procedure CheckEmptyLines(PurchaseHeader: Record "Purchase Header")
    var
        PurchLineLoc: Record "Purchase Line";
    begin
        //SWC380 AKA 290115
        PurchLineLoc.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchLineLoc.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchLineLoc.SETFILTER(Type, '<>%1', PurchLineLoc.Type::" ");
        IF PurchLineLoc.FINDSET THEN
            REPEAT
                PurchLineLoc.TESTFIELD("No.");
                PurchLineLoc.TESTFIELD("Full Description");
                PurchLineLoc.TESTFIELD(Quantity);
            UNTIL PurchLineLoc.NEXT = 0;
    end;

    local procedure GetPurchActChecker(PurchHeader: Record "Purchase Header"): code[50]
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.RESET;
        UserSetup.SETRANGE("Salespers./Purch. Code", PurchHeader."Purchaser Code");
        UserSetup.FINDFIRST;
        exit(UserSetup."User ID");
    end;

    procedure GetPurchActApproverFromDim(DimSetID: Integer): Code[50]
    var
        DimSetEntry: Record "Dimension Set Entry";
        DimValueCC: Record "Dimension Value";
        DimValueCP: Record "Dimension Value";
        UserSetup: Record "User Setup";
    begin
        if DimSetID = 0 then
            exit('');
        GetPurchSetupWithTestDim();
        if not DimSetEntry.Get(DimSetID, PurchSetup."Cost Code Dimension") then
            exit('');
        if not DimValueCC.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code") then
            exit('');
        if not DimSetEntry.Get(DimSetID, PurchSetup."Cost Place Dimension") then
            exit('');
        if not DimValueCP.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code") then
            exit('');
        case DimValueCC."Cost Code Type" of
            DimValueCC."Cost Code Type"::Development:
                exit(UserSetup.GetUserSubstitute(DimValueCP."Development Cost Place Holder", 0));
            DimValueCC."Cost Code Type"::Production:
                exit(UserSetup.GetUserSubstitute(DimValueCP."Production Cost Place Holder", 0));
            DimValueCC."Cost Code Type"::Admin:
                exit(UserSetup.GetUserSubstitute(DimValueCP."Admin Cost Place Holder", 0));
        end;
    end;

    procedure GetPurchActMasterApproverFromDim(DimSetID: Integer): Code[50]
    var
        DimSetEntry: Record "Dimension Set Entry";
        DimValueCC: Record "Dimension Value";

    begin
        if DimSetID = 0 then
            exit('');
        GetPurchSetupWithTestDim();
        if not DimSetEntry.Get(DimSetID, PurchSetup."Cost Code Dimension") then
            exit('');
        if not DimValueCC.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code") then
            exit('');
        case DimValueCC."Cost Code Type" of
            DimValueCC."Cost Code Type"::Development:
                begin
                    PurchSetup.TestField("Master Approver (Development)");
                    exit(PurchSetup."Master Approver (Development)");
                end;
            DimValueCC."Cost Code Type"::Production:
                begin
                    PurchSetup.TestField("Master Approver (Production)");
                    exit(PurchSetup."Master Approver (Production)");
                end;
            DimValueCC."Cost Code Type"::Admin:
                begin
                    PurchSetup.TestField("Master Approver (Department)");
                    exit(PurchSetup."Master Approver (Department)");
                end;
        end;
    end;

    procedure GetPurchActPreApproverFromDim(DimSetID: Integer): Code[50]
    var
        DimSetEntry: Record "Dimension Set Entry";
        DimValueCC: Record "Dimension Value";
        UserSetup: Record "User Setup";
    begin
        if DimSetID = 0 then
            exit('');
        GetPurchSetupWithTestDim();
        if not DimSetEntry.Get(DimSetID, PurchSetup."Cost Code Dimension") then
            exit('');
        if not DimValueCC.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code") then
            exit('');
        exit(UserSetup.GetUserSubstitute(DimValueCC."Cost Holder", 0));
    end;

    procedure GetApproverFromActLines(PurchHeader: Record "Purchase Header"): Code[50]
    var
        PurchLine: Record "Purchase Line";
        UserSetup: Record "User Setup";
        LineApprover: Code[50];
        LineMasterApprover: Code[50];
        CurrentApprover: Code[50];
        CurrentMasterApprover: Code[50];
    begin
        PurchHeader.TestField("Purchaser Code");
        UserSetup.SetRange("Salespers./Purch. Code", PurchHeader."Purchaser Code");
        UserSetup.FindFirst();

        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
        PurchLine.SetFilter("No.", '<>%1', '');
        PurchLine.SetFilter(Quantity, '<>%1', 0);
        IF PurchLine.FindSet() then
            repeat
                LineApprover := GetPurchActApproverFromDim(PurchLine."Dimension Set ID");
                LineMasterApprover := GetPurchActMasterApproverFromDim(PurchLine."Dimension Set ID");
                if CurrentApprover = '' then
                    CurrentApprover := LineApprover
                else
                    if (CurrentApprover <> LineApprover) or (LineApprover = UserSetup."User ID") then begin
                        if CurrentMasterApprover = '' then
                            CurrentMasterApprover := LineMasterApprover
                        else
                            if CurrentMasterApprover <> LineMasterApprover then
                                exit(GetPurchActApproverFromDim(PurchHeader."Dimension Set ID"));
                    end;
            until PurchLine.next = 0
        else
            exit(GetPurchActApproverFromDim(PurchHeader."Dimension Set ID"));

        if CurrentMasterApprover <> '' then
            exit(CurrentMasterApprover)
        else
            if CurrentApprover <> '' then
                exit(CurrentApprover)
            else
                exit(GetPurchActApproverFromDim(PurchHeader."Dimension Set ID"));
    end;

    procedure GetMessageResponsNo(IWDocument: Boolean; GenAppStatus: Integer; SentToPreApproval: Boolean) MessageResponsNo: Integer
    var
        ActAppStatus: Enum "Purchase Act Approval Status";
        AppStatus: enum "Purchase Approval Status";
    begin
        if not IWDocument then begin
            MessageResponsNo := GenAppStatus + 1;
            if ((GenAppStatus = ActAppStatus::Approve.AsInteger()) and (not SentToPreApproval)) or (GenAppStatus >= ActAppStatus::Signing.AsInteger()) then
                MessageResponsNo := GenAppStatus + 2;
        end else begin
            MessageResponsNo := GenAppStatus;
            if (GenAppStatus = AppStatus::Approve.AsInteger()) and (not SentToPreApproval) then
                MessageResponsNo := GenAppStatus + 1;
            if GenAppStatus = AppStatus::Payment.AsInteger() then
                MessageResponsNo := 9;
        end;
    end;

    local procedure FillPurchActStatus(
        var PurchHeader: Record "Purchase Header"; ActAppStatus: Enum "Purchase Act Approval Status"; ProcessUser: code[50]; ProblemType: enum "Purchase Problem Type"; Reject: Boolean)
    var
        UserSetup: Record "User Setup";
        LocText001: Label 'Failed to define user for process %1!';
    begin
        if ProcessUser = '' then
            Error(LocText001, ActAppStatus);

        UserSetup.Get(ProcessUser);
        PurchHeader."Status App Act" := ActAppStatus;
        PurchHeader."Process User" := UserSetup."User ID";
        PurchHeader."Date Status App" := TODAY;
        PurchHeader."Problem Type" := ProblemType;
        PurchHeader."Problem Document" := ProblemType <> ProblemType::" ";
        PurchHeader.Modify;

        error('MessageResponsNo = %1 (%2)', ActAppStatus.AsInteger(), ActAppStatus);

        SetChangeStatusMessage(PurchHeader, GetMessageResponsNo(false, ActAppStatus.AsInteger(), PurchHeader."Sent to pre. Approval"), Reject);
    end;

    local procedure FillPayInvStatus(
        var PurchHeader: Record "Purchase Header"; AppStatus: Enum "Purchase Approval Status"; ProcessUser: code[50]; ProblemType: enum "Purchase Problem Type"; Reject: Boolean)
    var
        UserSetup: Record "User Setup";
        LocText001: Label 'Failed to define user for process %1!';
    begin
        if ProcessUser = '' then
            Error(LocText001, AppStatus);

        UserSetup.Get(ProcessUser);
        PurchHeader."Status App" := AppStatus.AsInteger();
        PurchHeader."Process User" := UserSetup."User ID";
        PurchHeader."Date Status App" := TODAY;
        PurchHeader."Problem Type" := ProblemType;
        PurchHeader."Problem Document" := ProblemType <> ProblemType::" ";
        PurchHeader.Modify;

        SetChangeStatusMessage(PurchHeader, GetMessageResponsNo(false, AppStatus.AsInteger(), PurchHeader."Sent to pre. Approval"), Reject);
    end;

    procedure ChangePayInvStatusWhenDelegate(var PurchHeader: Record "Purchase Header"; ProcessUser: code[50])
    var
        UserSetup: Record "User Setup";
        MessageResponsNo: Integer;
        LocText001: Label 'Failed to define user for delegate!';
        DelegateText: Label 'The approval of document %1 with status %2 was delegated to %3.';
    begin
        if ProcessUser = '' then
            Error(LocText001);

        UserSetup.Get(ProcessUser);
        PurchHeader."Process User" := UserSetup."User ID";
        PurchHeader."Date Status App" := TODAY;
        PurchHeader.Modify;

        ChangeStatusMessage := StrSubstNo(DelegateText, PurchHeader."No.", PurchHeader."Status App", ProcessUser);
    end;

    local procedure SetChangeStatusMessage(var PurchHeader: Record "Purchase Header"; ResponsNo: integer; Reject: Boolean)
    var
        ApproveText: Label 'Document %1 has been sent to the %2 for approval.';
        SigningText: Label 'Document %1 has been sent for signature.';
        RejectText: Label 'Document %1 has been returned to the %2 for revision.';
        FinalText1: Label 'The document passed all approvals and a Purchase Invoice for Accounting was created!';
        FinalText2: Label 'The document passed all approvals!';
        ResponsText: label 'Reception,Controller,Estimator,Checker,Pre. Approver,Approver';
    begin
        case ResponsNo of
            1, 2, 3, 4, 5, 6:
                if not Reject then
                    ChangeStatusMessage := StrSubstNo(ApproveText, PurchHeader."No.", SelectStr(ResponsNo, ResponsText))
                else
                    ChangeStatusMessage := StrSubstNo(RejectText, PurchHeader."No.", SelectStr(ResponsNo, ResponsText));
            7:
                ChangeStatusMessage := StrSubstNo(SigningText, PurchHeader."No.");
            8:
                ChangeStatusMessage := FinalText1;
            9:
                ChangeStatusMessage := FinalText2;
        end;
    end;

    procedure GetChangeStatusMessage(): text
    begin
        exit(ChangeStatusMessage);
    end;

    local procedure PurchActPostShipment(var PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        PurchPost: Codeunit "Purch.-Post";
        Text50013: label 'The document will be posted by quantity and a Posted Purchase Receipt will be created. Proceed?';
    begin
        if not PurchHeader."Location Document" then
            exit;

        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter("No.", '<>%1', '');
        PurchLine.SetFilter("Qty. to Receive", '<>%1', 0);
        if PurchLine.IsEmpty then
            exit;

        IF NOT CONFIRM(Text50013, FALSE) THEN
            ERROR('');

        ReleasePurchDoc.SetSkipCheckReleaseRestrictions();
        ReleasePurchDoc.Run(PurchHeader);

        PurchHeader.Receive := true;
        PurchHeader.Invoice := false;
        PurchHeader."Print Posted Documents" := false;
        PurchPost.SetSuppressCommit(true);
        PurchPost.Run(PurchHeader);
    end;

    local procedure CreatePurchInvForAct(var PurchHeader: Record "Purchase Header")
    var
        PurchHeaderInv: Record "Purchase Header";
        PurchLineInv: Record "Purchase Line";
        PurchLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        GetReceipts: Codeunit "Purch.-Get Receipt";
        FromDocType: enum "Purchase Document Type From";
    begin
        GetPurchSetupWithTestDim();

        PurchHeaderInv.Init();
        PurchHeaderInv."Document Type" := PurchHeaderInv."Document Type"::Invoice;
        PurchHeaderInv."No." := '';
        PurchHeaderInv.Insert(true);

        FromDocType := FromDocType::Order;
        CopyDocMgt.SetProperties(true, false, false, false, true, PurchSetup."Exact Cost Reversing Mandatory", false);
        CopyDocMgt.CopyPurchDoc(FromDocType, PurchHeader."No.", PurchHeaderInv);

        PurchHeader."Invoice No." := PurchHeaderInv."No.";
        PurchHeader.Modify();

        PurchHeaderInv."Linked Purchase Order Act No." := PurchHeader."No.";
        PurchHeaderInv."Pre-booking Document" := true;
        PurchHeaderInv."Act Type" := PurchHeaderInv."Act Type"::" ";
        PurchHeaderInv."Process User" := '';
        PurchHeaderInv."Status App Act" := PurchHeaderInv."Status App Act"::" ";
        PurchHeaderInv."Date Status App" := 0D;
        PurchHeaderInv.Modify();

        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
        if PurchLine.IsEmpty then
            exit;

        PurchRcptLine.SetRange("Order No.", PurchHeader."No.");
        PurchRcptLine.FindSet;
        repeat
            if PurchLineInv.Get(PurchHeaderInv."Document Type", PurchHeaderInv."No.", PurchRcptLine."Order Line No.") then begin
                PurchLineInv.TestField(Type, PurchRcptLine.Type);
                PurchLineInv.TestField("No.", PurchRcptLine."No.");
                if PurchLineInv.Quantity <= PurchRcptLine.Quantity then
                    PurchLineInv.Delete(true)
                else begin
                    PurchLineInv.Validate(Quantity, PurchLineInv.Quantity - PurchRcptLine.Quantity);
                    PurchLineInv.Modify(true);
                end;
            end;
        until PurchRcptLine.Next() = 0;

        GetReceipts.SetPurchHeader(PurchHeaderInv);
        GetReceipts.CreateInvLines(PurchRcptLine);
    end;

    local procedure CheckApprovalCommentLineExist(RejectEntryNo: Integer);
    var
        ApprovalCommentLine: Record "Approval Comment Line";
        LocText021: Label 'You did not specify the reason for sending the document back for revision.';
    begin
        if RejectEntryNo <> 0 then begin
            ApprovalCommentLine.SetCurrentKey("Linked Approval Entry No.");
            ApprovalCommentLine.SetRange("Linked Approval Entry No.", RejectEntryNo);
            if ApprovalCommentLine.IsEmpty then
                Error(LocText021);
        end;
    end;

    procedure RegisterUserAbsence(var AbsentList: Record "User Setup");
    var
        UserSetupToUpdate: record "User Setup";
        ApprovalEntry: Record "Approval Entry";
        ApprovalEntryToUpdate: Record "Approval Entry";
        UserSetup: Record "User Setup";
        PurchHeader: Record "Purchase Header";
        SubstituteUserId: Code[50];
        LocText001: label 'There is no one to register.';
        LocText002: label 'Unable to find a substitute for %1. Check the substitute chain.';
        LocText003: label 'Are you sure you want to register the absence of %1 of users and delegate active approve entries by the Substitutes?';
        LocText004: Label 'The absence is registered.';
        NoPermissionToDelegateErr: Label 'You do not have permission to delegate one or more of the selected approval requests.';
    begin
        AbsentList.SetRange(Absents, false);
        if AbsentList.IsEmpty then begin
            Message(LocText001);
            exit;
        end;
        if not Confirm(LocText003, true, AbsentList.Count) then
            exit;
        AbsentList.FindSet();
        repeat
            AbsentList.TestField(Substitute);
            SubstituteUserId := UserSetup.GetUserSubstitute(AbsentList.Substitute, -1);
            if SubstituteUserId = '' then
                error(LocText002, AbsentList."User ID");
            ApprovalEntry.SetCurrentKey("Approver ID", Status);
            ApprovalEntry.SetRange("Approver ID", AbsentList."User ID");
            ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Created, ApprovalEntry.Status::Open);
            if ApprovalEntry.FindSet() then
                repeat
                    if (ApprovalEntry."Act Type" <> ApprovalEntry."Act Type"::" ") or ApprovalEntry."IW Documents" then begin
                        if not ApprovalEntry.CanCurrentUserEdit then
                            Error(NoPermissionToDelegateErr);
                        ApprovalEntryToUpdate := ApprovalEntry;
                        ApprovalEntryToUpdate."Delegated From Approver ID" := ApprovalEntryToUpdate."Approver ID";
                        ApprovalEntryToUpdate."Approver ID" := SubstituteUserId;
                        ApprovalEntryToUpdate.Modify(true);

                        PurchHeader.Get(ApprovalEntry."Document Type", ApprovalEntry."Document No.");
                        PurchHeader."Process User" := ApprovalEntryToUpdate."Approver ID";
                        PurchHeader.Modify();
                    end;
                until ApprovalEntry.Next() = 0;
            UserSetupToUpdate := AbsentList;
            UserSetupToUpdate.Absents := true;
            UserSetupToUpdate.Modify(true);
        until AbsentList.Next() = 0;
        Message(LocText004);
    end;

    procedure RegisterUserPresence(var PresenceList: Record "User Setup");
    var
        UserSetupToUpdate: record "User Setup";
        ApprovalEntry: Record "Approval Entry";
        ApprovalEntryToUpdate: Record "Approval Entry";
        PurchHeader: Record "Purchase Header";
        LocText001: label 'There is no one to unregister.';
        LocText003: label 'Are you sure you want to unregister the absence of %1 of users and return active approve entries to the original Approvers?';
        LocText004: Label 'Absence registration canceled';
        NoPermissionToDelegateErr: Label 'You do not have permission to return one or more of the selected approval requests.';
    begin
        PresenceList.SetRange(Absents, true);
        if PresenceList.IsEmpty then begin
            Message(LocText001);
            exit;
        end;
        if not Confirm(LocText003, true, PresenceList.Count) then
            exit;
        PresenceList.FindSet();
        repeat
            ApprovalEntry.SetCurrentKey("Delegated From Approver ID", Status);
            ApprovalEntry.SetFilter("Delegated From Approver ID", '<>%1', '');
            ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Created, ApprovalEntry.Status::Open);
            if ApprovalEntry.FindSet() then
                repeat
                    if not ApprovalEntry.CanCurrentUserEdit then
                        Error(NoPermissionToDelegateErr);
                    ApprovalEntryToUpdate := ApprovalEntry;
                    ApprovalEntryToUpdate."Approver ID" := ApprovalEntryToUpdate."Delegated From Approver ID";
                    ApprovalEntryToUpdate."Delegated From Approver ID" := '';
                    ApprovalEntryToUpdate.Modify(true);

                    PurchHeader.Get(ApprovalEntry."Document Type", ApprovalEntry."Document No.");
                    PurchHeader."Process User" := ApprovalEntryToUpdate."Approver ID";
                    PurchHeader.Modify();
                until ApprovalEntry.Next() = 0;
            UserSetupToUpdate := PresenceList;
            UserSetupToUpdate.Absents := false;
            UserSetupToUpdate.Modify(true);
        until PresenceList.Next() = 0;
        Message(LocText004);
    end;

    procedure PaymentRegisterResetProblemDocument(var PurchHeader: Record "Purchase Header");
    var
        PurchHeaderToUpdate: Record "Purchase Header";
        LocText001: Label 'The selected documents are not the problem.';
        LocText002: Label 'Are you sure you want to reset Problem mark from the selected documents?';
    begin
        PurchHeader.SetRange("Problem Document", true);
        if PurchHeader.IsEmpty then
            Error(LocText001);
        if not Confirm(LocText001) then
            exit;
        PurchHeader.FindSet();
        repeat
            PurchHeaderToUpdate := PurchHeader;
            PurchHeaderToUpdate.Validate("Problem Document", false);
            PurchHeaderToUpdate.Modify(true);
        until PurchHeader.next = 0;
    end;

}