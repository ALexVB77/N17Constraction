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

    procedure FuncNewRec(ActTypeOption: enum "Purchase Act Type")
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
        if not (ActTypeOption = ActTypeOption::Advance) then
            PurchSetup.TestField("Base Vendor No.")
        else
            PurchSetup.TestField("Base Resp. Employee No.");

        if ActTypeOption <> ActTypeOption::Advance then begin
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
        end;

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
            "Empl. Purchase" := ActTypeOption = ActTypeOption::Advance;

            INSERT(TRUE);
            if "Act Type" <> "Act Type"::Advance then
                VALIDATE("Buy-from Vendor No.", PurchSetup."Base Vendor No.")
            else
                Validate("Buy-from Vendor No.", PurchSetup."Base Resp. Employee No.");

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
            if PurchSetup."Prices Incl. VAT in Req. Doc." then
                Validate("Prices Including VAT", true);
            if "Act Type" = "Act Type"::Advance then
                "Vendor Invoice No." := "No.";
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

    procedure NewOrderApp(CreateLine: Boolean; OpenDocument: Boolean; var grPurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        grUS: Record "User Setup";
    begin

        GetPurchSetupWithTestDim;
        GetInventorySetup();
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

        grPurchHeader."Payment Type" := grPurchHeader."Payment Type"::"post-payment";

        grPurchHeader.Receptionist := UserId;
        if PurchSetup."Prices Incl. VAT in Req. Doc." then
            grPurchHeader.Validate("Prices Including VAT", true);
        grPurchHeader.MODIFY(TRUE);

        if CreateLine then begin
            PurchLine.Init;
            PurchLine."Document Type" := grPurchHeader."Document Type";
            PurchLine."Document No." := grPurchHeader."No.";
            PurchLine."Line No." := 10000;
            PurchLine.Validate(Type, PurchLine.Type::Item);
            PurchLine.Validate("No.", InvtSetup."Temp Item Code");
            PurchLine.Insert(true);
        end;

        if OpenDocument then begin
            COMMIT;
            Page.RUNMODAL(Page::"Purchase Order App", grPurchHeader);
        end;
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

        NewOrderApp(false, false, PaymentInvoice);

        GetPurchSetupWithTestDim;
        CopyDocMgt.SetProperties(true, false, false, false, false, PurchSetup."Exact Cost Reversing Mandatory", false);
        CopyDocMgt.CopyPurchDoc(FromDocType::Order, PurchaseHeader."No.", PaymentInvoice);

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

    procedure UnLinkActAndPaymentInvoice(PaymentInvoice: Record "Purchase Header");
    begin
        PaymentInvoice.ModifyAll("Linked Purchase Order Act No.", '');
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

    procedure PurchOrderActArchiveQstNew(PurchHeader: Record "Purchase Header"): Boolean;
    var
        PaymentInvoice: Record "Purchase Header";
        ArchProblemDoc: Page "Archiving Document";
        ArchReason: Text;
        LocText50013: Label 'Document %1 has been sent to the archive.';
        LocText3: Label 'You are not the owner or process user in the linked payment invoice %1.';
        LocText4: Label 'You must be the owner or process user in the document %1.';
    begin
        PurchHeader.TestField("Problem Document");

        if not (UserId in [PurchHeader.Controller, PurchHeader."Process User"]) then
            Error(LocText4, PurchHeader."No.");

        PaymentInvoice.SetCurrentKey("Linked Purchase Order Act No.");
        PaymentInvoice.SetRange("Linked Purchase Order Act No.", PurchHeader."No.");
        if PaymentInvoice.FindSet() then
            repeat
                PaymentInvoice.TestField("Status App", PaymentInvoice."Status App"::Payment);
                if not (UserId in [PaymentInvoice.Receptionist, PaymentInvoice."Process User"]) then
                    Error(LocText3, PaymentInvoice."No.");
            until PaymentInvoice.next = 0;

        ArchProblemDoc.SetParam(PurchHeader);
        ArchProblemDoc.RunModal;
        if not ArchProblemDoc.GetResult(ArchReason) then
            exit;

        PurchOrderActArchive(PurchHeader, ArchReason);

        MESSAGE(LocText50013, PurchHeader."No.");
        exit(true);
    end;

    local procedure PurchOrderActArchive(PurchHeader: Record "Purchase Header"; ArchReason: Text);
    var
        PurchInvoice: Record "Purchase Header";
        PurchRcptHdr: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PaymentInvoice: Record "Purchase Header";
        WorkflowWebhookEntry: Record "Workflow Webhook Entry";
        PurchHeaderArch: Record "Purchase Header Archive";
        gvduERPC: Codeunit "ERPC Funtions";
        UndoPurchRcptLine: Codeunit "Undo Purchase Receipt Line";
        ArchiveMgt: Codeunit ArchiveManagement;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        CommentAddType: enum "Purchase Comment Add. Type";
    begin
        // Закрываем аппрувы и процессы    
        if not (PurchHeader."Status App Act" in [PurchHeader."Status App Act"::Controller, PurchHeader."Status App Act"::Accountant]) then begin
            ApprovalsMgmt.OnCancelPurchaseApprovalRequest(PurchHeader);
            WorkflowWebhookMgt.FindAndCancel(PurchHeader.RecordId);
        end;

        // Закрывающий счет на все приходные накладные 
        IF (PurchHeader."Act Invoice No." <> '') and (not PurchHeader."Act Invoice Posted") THEN
            IF PurchInvoice.GET(PurchInvoice."Document Type"::Invoice, PurchHeader."Act Invoice No.") THEN
                PurchInvoice.Delete(true);
        PurchHeader.Get(PurchHeader."Document Type", PurchHeader."No.");

        // Прих. накладные
        if not PurchHeader."Act Invoice Posted" then begin
            PurchRcptHdr.SetCurrentKey("Order No.");
            PurchRcptHdr.SetRange("Order No.", PurchHeader."No.");
            if not PurchRcptHdr.IsEmpty then begin
                PurchRcptHdr.FindSet();
                repeat
                    PurchRcptLine.SetRange("Document No.", PurchRcptHdr."No.");
                    PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
                    PurchRcptLine.SetFilter(Quantity, '<>0');
                    if not PurchRcptLine.IsEmpty then begin
                        Clear(UndoPurchRcptLine);
                        UndoPurchRcptLine.SetHideDialog(true);
                        UndoPurchRcptLine.Run(PurchRcptLine);
                    end;
                until PurchRcptHdr.next = 0;
            end;
        end;

        gvduERPC.DeleteBCPreBooking(PurchHeader); //Удаление бюджета

        // Счета на оплату
        PaymentInvoice.SetCurrentKey("Linked Purchase Order Act No.");
        PaymentInvoice.SetRange("Linked Purchase Order Act No.", PurchHeader."No.");
        if not PaymentInvoice.IsEmpty then begin
            PaymentInvoice.FindSet();
            repeat
                PurchPaymentInvoiceArchive(PaymentInvoice, ArchReason);
            until PaymentInvoice.Next() = 0;
        end;

        PurchHeader."Problem Document" := TRUE;
        PurchHeader."Problem Type" := PurchHeader."Problem Type"::"Act error";
        // NC AB : не оставляем архивный акт в T36 и T37, оправляем его в T5109 и T5110
        // PurchHeader.MODIFY();
        PurchHeader."Archiving Type" := PurchHeader."Archiving Type"::"Problem Act";
        ArchiveMgt.StorePurchDocument(PurchHeader, false);

        // Причина
        PurchHeaderArch.SetRange("Document Type", PurchHeader."Document Type");
        PurchHeaderArch.SetRange("No.", PurchHeader."No.");
        PurchHeaderArch.FindLast();
        PurchHeaderArch.SetAddTypeCommentArchText(CommentAddType::Archive, ArchReason);

        PurchHeader.SetHideValidationDialog(true);
        PurchHeader.Delete(true);
    end;

    procedure PurchPaymentInvoiceArchiveQst(PurchHeader: Record "Purchase Header"): Boolean;
    var
        ArchProblemDoc: Page "Archiving Document";
        ArchReason: Text;
        LocText001: Label 'Document %1 has been archived.';
        LocText4: Label 'You must be the owner or process user in the document %1.';
    begin
        if not (UserId in [PurchHeader.Receptionist, PurchHeader."Process User"]) then
            Error(LocText4, PurchHeader."No.");

        ArchProblemDoc.SetParam(PurchHeader);
        ArchProblemDoc.RunModal;
        if not ArchProblemDoc.GetResult(ArchReason) then
            exit;

        PurchPaymentInvoiceArchive(PurchHeader, ArchReason);

        Message(LocText001, PurchHeader."No.");
        exit(true);
    end;

    local procedure PurchPaymentInvoiceArchive(PurchHeader: Record "Purchase Header"; ArchReason: Text);
    var
        PurchHeaderArch: Record "Purchase Header Archive";
        ArchiveMgt: Codeunit ArchiveManagement;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        CommentAddType: enum "Purchase Comment Add. Type";
    begin
        PurchHeader.TestField("Status App", PurchHeader."Status App"::Payment);

        // Закрываем аппрувы и процессы    
        if not (PurchHeader."Status App" in [PurchHeader."Status App"::Reception, PurchHeader."Status App"::Payment]) then begin
            ApprovalsMgmt.OnCancelPurchaseApprovalRequest(PurchHeader);
            WorkflowWebhookMgt.FindAndCancel(PurchHeader.RecordId);
        end;

        PurchHeader."Archiving Type" := PurchHeader."Archiving Type"::"Payment Invoice";
        ArchiveMgt.StorePurchDocument(PurchHeader, false);
        DisconnectFromAgreement(PurchHeader);

        // Причина
        PurchHeaderArch.SetRange("Document Type", PurchHeader."Document Type");
        PurchHeaderArch.SetRange("No.", PurchHeader."No.");
        PurchHeaderArch.FindLast();
        PurchHeaderArch.SetAddTypeCommentArchText(CommentAddType::Archive, ArchReason);

        PurchHeader.SetHideValidationDialog(true);
        PurchHeader.Delete(true);
    end;

    local procedure DisconnectFromAgreement(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        ProjectsBudgetEntry: Record "Projects Budget Entry";
        ProjectBudgetMgt: Codeunit "Project Budget Management";
    begin
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
                    END;
                END;
            UNTIL PurchaseLine.NEXT = 0;
        END;
    end;

    local procedure CheckDimExists(DimensionSetID: Integer; DimType: option "CostDim","AddrDim"): Boolean
    var
        DimSetEntry: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimValue: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
    begin
        if DimensionSetID = 0 then
            exit(false);
        GetPurchSetupWithTestDim();

        DimSetEntry.SetRange("Dimension Set ID", DimensionSetID);
        case DimType of
            DimType::CostDim:
                begin
                    DimSetEntry.SetFilter("Dimension Code", '%1|%2', PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension");
                    if DimSetEntry.Count <> 2 then
                        exit(false);
                end;
            DimType::AddrDim:
                begin
                    if not DimSetEntry.Get(DimensionSetID, PurchSetup."Cost Place Dimension") then
                        exit(true);
                    DimValue.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code");
                    if not DimValue."Check Address Dimension" then
                        exit(true);
                    PurchSetup.TestField("Address Dimension");
                    if not DimSetEntry.Get(DimensionSetID, PurchSetup."Address Dimension") then
                        exit(false);
                end;
        end;

        DimSetEntry.FindSet();
        repeat
            TempDimSetEntry := DimSetEntry;
            TempDimSetEntry."Dimension Set ID" := 0;
            TempDimSetEntry.Insert;
        until DimSetEntry.Next() = 0;
        DimMgt.CheckDimIDComb(DimMgt.GetDimensionSetID(TempDimSetEntry));

        exit(true);
    end;

    local procedure CheckDimExistsInLine(var PurchLine: Record "Purchase Line"; DimType: option "CostDim","AddrDim","All")
    var
        LocText001: Label 'You must specify %1 and %2 for %3 line %4.';
        LocText002: label 'You must specify %1 for %2 line %3.';
    begin
        if DimType in [DimType::CostDim, DimType::All] then
            if not CheckDimExists(PurchLine."Dimension Set ID", DimType::CostDim) then
                Error(LocText001, PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension", PurchLine."Document No.", PurchLine."Line No.");
        if DimType in [DimType::AddrDim, DimType::All] then
            if not CheckDimExists(PurchLine."Dimension Set ID", DimType::AddrDim) then
                Error(LocText002, PurchSetup."Address Dimension", PurchLine."Document No.", PurchLine."Line No.");
    end;

    local procedure CheckDimExistsInHeader(var PurchHeader: Record "Purchase Header"; DimType: option "CostDim","AddrDim","All")
    var
        LocText001: Label 'You must specify %1 and %2 for %3.';
        LocText002: Label 'You must specify %1 for %2.';
    begin
        if DimType in [DimType::CostDim, DimType::All] then
            if not CheckDimExists(PurchHeader."Dimension Set ID", DimType::CostDim) then
                Error(LocText001, PurchSetup."Cost Place Dimension", PurchSetup."Cost Code Dimension", PurchHeader."No.");
        if DimType in [DimType::AddrDim, DimType::All] then
            if not CheckDimExists(PurchHeader."Dimension Set ID", DimType::AddrDim) then
                Error(LocText002, PurchSetup."Address Dimension", PurchHeader."No.");
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
                    CheckDimExistsInLine(PurchLine, 0);
                until PurchLine.Next() = 0;
            end;
        end;

        if (PurchHeader."Status App Act".AsInteger() >= PurchHeader."Status App Act"::Checker.AsInteger()) and (not Reject) then begin
            GetInventorySetup;
            CheckDimExistsInHeader(PurchHeader, 1);
            PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
            PurchLine.SETRANGE("Document No.", PurchHeader."No.");
            PurchLine.SETRANGE(Type, PurchLine.Type::Item);
            PurchLine.FindSet();
            repeat
                PurchLine.TestField("No.");
                PurchLine.TestField(Quantity);
                CheckDimExistsInLine(PurchLine, 2);
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
                    PreAppover := GetPurchActPreApprover(PurchHeader);
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
                    if not Reject then begin
                        FillPurchActStatus(PurchHeader, PurchHeader."Status App Act"::Signing, GetPurchActChecker(PurchHeader), ProblemType::" ", Reject);
                        // AN надо создавать операции по бюджетам
                        ERPCFunc.CreateBCPreBookingAct(PurchHeader);
                    end
                    else begin
                        PreAppover := GetPurchActPreApprover(PurchHeader);
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
            CheckDimExistsInHeader(PurchHeader, 2);
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
                CheckDimExistsInLine(PurchLine, 2);
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
                    PreAppover := GetPurchActPreApprover(PurchHeader);
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
                        PreAppover := GetPurchActPreApprover(PurchHeader);
                        if PreAppover <> '' then begin
                            PurchHeader."Sent to pre. Approval" := true;
                            FillPayInvStatus(PurchHeader, AppStatus::Approve, PreAppover, ProblemType::RApprover, Reject);
                        end else
                            FillPayInvStatus(PurchHeader, AppStatus::Checker, GetPurchActChecker(PurchHeader), ProblemType::RApprover, Reject);
                    end;
                end;
        end;
    end;

    // NC AB: не используется, к удалению!
    /*
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
    */

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

    local procedure GetPurchActPreApprover(var PurchHeader: Record "Purchase Header"): Code[50]
    begin
        if PurchHeader."Act Type" = PurchHeader."Act Type"::Advance then
            exit(PurchHeader."Pre-Approver")
        else
            exit(GetPurchActPreApproverFromDim(PurchHeader."Dimension Set ID"));
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

    procedure GetApproverFromActLines(var PurchHeader: Record "Purchase Header"): Code[50]
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
    // 'Reception,Controller,Estimator,Checker,Pre. Approver,Approver,Signer';
    begin
        if not IWDocument then
            case true of
                GenAppStatus in [ActAppStatus::Controller.AsInteger(), ActAppStatus::Estimator.AsInteger(), ActAppStatus::Checker.AsInteger()]:
                    MessageResponsNo := GenAppStatus + 1;
                (GenAppStatus = ActAppStatus::Approve.AsInteger()) and SentToPreApproval:
                    MessageResponsNo := GenAppStatus + 1;
                (GenAppStatus = ActAppStatus::Approve.AsInteger()) and (not SentToPreApproval):
                    MessageResponsNo := GenAppStatus + 2;
                GenAppStatus in [ActAppStatus::Signing.AsInteger(), ActAppStatus::Accountant.AsInteger()]:
                    MessageResponsNo := 8;
            end
        else
            case true of
                GenAppStatus = AppStatus::Reception.AsInteger():
                    MessageResponsNo := GenAppStatus;
                GenAppStatus in [AppStatus::Controller.AsInteger(), AppStatus::Checker.AsInteger()]:
                    MessageResponsNo := GenAppStatus + 1;
                (GenAppStatus = AppStatus::Approve.AsInteger()) and SentToPreApproval:
                    MessageResponsNo := GenAppStatus + 1;
                (GenAppStatus = AppStatus::Approve.AsInteger()) and (not SentToPreApproval):
                    MessageResponsNo := GenAppStatus + 2;
                GenAppStatus = AppStatus::Payment.AsInteger():
                    MessageResponsNo := 9;
            end;
    end;

    local procedure FillPurchActStatus(
        var PurchHeader: Record "Purchase Header"; ActAppStatus: Enum "Purchase Act Approval Status"; ProcessUser: code[50];
                                                                     ProblemType: enum "Purchase Problem Type";
                                                                     Reject: Boolean)
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

        SetChangeStatusMessage(PurchHeader, GetMessageResponsNo(false, ActAppStatus.AsInteger(), PurchHeader."Sent to pre. Approval"), Reject);
    end;

    local procedure FillPayInvStatus(
        var PurchHeader: Record "Purchase Header"; AppStatus: Enum "Purchase Approval Status"; ProcessUser: code[50];
                                                                  ProblemType: enum "Purchase Problem Type";
                                                                  Reject: Boolean)
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
        RejectText: Label 'Document %1 has been returned to the %2 for revision.';
        FinalText1: Label 'The document passed all approvals and a Purchase Invoice for Accounting was created!';
        FinalText2: Label 'The document passed all approvals!';
        ResponsText: label 'Reception,Controller,Estimator,Checker,Pre. Approver,Approver,Signer';
    begin
        case ResponsNo of
            1, 2, 3, 4, 5, 6, 7:
                if not Reject then
                    ChangeStatusMessage := StrSubstNo(ApproveText, PurchHeader."No.", SelectStr(ResponsNo, ResponsText))
                else
                    ChangeStatusMessage := StrSubstNo(RejectText, PurchHeader."No.", SelectStr(ResponsNo, ResponsText));
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

        PurchHeader."Act Invoice No." := PurchHeaderInv."No.";
        PurchHeader."Act Invoice Posted" := false;
        PurchHeader.Modify();

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
        if not Confirm(LocText002) then
            exit;
        PurchHeader.FindSet();
        repeat
            PurchHeaderToUpdate := PurchHeader;
            PurchHeaderToUpdate.Validate("Problem Document", false);
            PurchHeaderToUpdate.Modify(true);
        until PurchHeader.next = 0;
    end;

    procedure CreatePurchInvoiceFromVendorExcel(var VendExcelHdr: Record "Vendor Excel Header")
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchHead: record "Purchase Header";
        PurchLine: record "Purchase Line";
        SourceLine: record "Vendor Excel Line";
        StorekeeperLocation: record "Warehouse Employee";
        VendorAgreement: record "Vendor Agreement";
        DimSetEntry: Record "Dimension Set Entry";
        DimMgtExt: Codeunit "Dimension Management (Ext)";
        LineNo: integer;
        grUS: record "User Setup";
        Text002: Label 'The act has already been created!';
    begin
        IF VendExcelHdr."Act No." <> '' THEN BEGIN
            MESSAGE(Text002);
            EXIT;
        END;

        VendExcelHdr.TESTFIELD("Vendor No.");
        VendExcelHdr.TESTFIELD("Posting Date");
        VendExcelHdr.TESTFIELD("Agreement No.");
        VendExcelHdr.TESTFIELD("Act Type");

        grUS.Get(UserId);
        PurchSetup.Get();

        PurchHead.INIT;
        PurchHead."Document Type" := PurchHead."Document Type"::Order;
        PurchHead."No." := '';
        PurchHead."Pre-booking Document" := TRUE;
        PurchHead."Act Type" := VendExcelHdr."Act Type";
        PurchHead.INSERT(TRUE);

        PurchHead.VALIDATE("Buy-from Vendor No.", VendExcelHdr."Vendor No.");
        PurchHead.VALIDATE("Document Date", VendExcelHdr."Posting Date");

        PurchHead.Storekeeper := UserId;
        PurchHead."Location Document" := true;
        PurchHead.VALIDATE("Location Code", StorekeeperLocation.GetDefaultLocation('', false));

        PurchHead."Status App Act" := PurchHead."Status App Act"::Controller;
        PurchHead."Process User" := USERID;
        PurchHead."Payment Doc Type" := PurchHead."Payment Doc Type"::"Payment Request";
        PurchHead."Date Status App" := TODAY;
        PurchHead.Controller := grUS."User ID";
        IF PurchHead."Act Type" = PurchHead."Act Type"::"KC-2" THEN
            if PurchSetup."Default Estimator" <> '' then
                PurchHead.Estimator := PurchSetup."Default Estimator";
        IF VendExcelHdr."Agreement No." <> '' THEN
            PurchHead.VALIDATE("Agreement No.", VendExcelHdr."Agreement No.");
        IF VendorAgreement.GET(PurchHead."Buy-from Vendor No.", PurchHead."Agreement No.") THEN
            PurchHead."Purchaser Code" := VendorAgreement."Purchaser Code";
        PurchHead."Vendor Invoice No." := VendExcelHdr."No.";
        PurchHead.MODIFY(TRUE);

        LineNo := 10000;
        SourceLine.SETRANGE("Document No.", VendExcelHdr."No.");
        SourceLine.SETFILTER("Item No.", '<>%1', '');
        SourceLine.SETRANGE("Vendor No.", VendExcelHdr."Vendor No.");
        IF SourceLine.FINDSET THEN
            REPEAT
                PurchLine.INIT;
                PurchLine."Document Type" := PurchHead."Document Type";
                PurchLine."Document No." := PurchHead."No.";
                PurchLine."Line No." := LineNo;
                LineNo := LineNo + 10000;
                PurchLine.INSERT(TRUE);
                PurchLine.Type := PurchLine.Type::Item;
                PurchLine.VALIDATE("No.", SourceLine."Item No.");
                PurchLine.VALIDATE(Quantity, SourceLine.Quantity);
                PurchLine.VALIDATE("Unit of Measure Code", SourceLine."Unit of Measure");
                PurchLine.VALIDATE("Direct Unit Cost", SourceLine."Unit Price");
                // NC AB >>              
                // PurchLine.VALIDATE("Shortcut Dimension 1 Code", SourceLine."Shortcut Dimension 1 Code");
                // PurchLine.VALIDATE("Shortcut Dimension 2 Code", SourceLine."Shortcut Dimension 2 Code");
                DimSetEntry.SetRange("Dimension Set ID", SourceLine."Dimension Set ID");
                if DimSetEntry.FindSet() then
                    repeat
                        DimMgtExt.valDimValueWithUpdGlobalDim(
                            DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code", PurchLine."Dimension Set ID",
                            PurchLine."Shortcut Dimension 1 Code", PurchLine."Shortcut Dimension 2 Code");
                    until DimSetEntry.Next() = 0;
                // NC AB <<
                PurchLine.MODIFY(TRUE);
            UNTIL SourceLine.NEXT = 0;

        VendExcelHdr."Act No." := PurchHead."No.";
        VendExcelHdr.MODIFY;
        COMMIT;
        PAGE.RUNMODAL(PAGE::"Purchase Order Act", PurchHead);
    end;

    procedure CreateJournalLineFromPaymentInvoice(JnlTempName: code[20]; JnlBatchName: code[20]; var PurchHeader: Record "Purchase Header") LinesCount: Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTempl: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        PurchSetup: Record "Purchases & Payables Setup";
        DimSetEntry: Record "Dimension Set Entry";
        PurchaseLine: Record "Purchase Line";
        DimMgtExt: Codeunit "Dimension Management (Ext)";
        gcduERPC: Codeunit "ERPC Funtions";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LastLineNo: Integer;
        CostPlaceDimValue, CostCodeDimValue : Code[20];
        AddText: text;
    begin
        if PurchHeader.IsEmpty then
            exit(0);

        GenJournalLine.SETRANGE("Journal Template Name", JnlTempName);
        GenJournalLine.SETRANGE("Journal Batch Name", JnlBatchName);
        IF GenJournalLine.FINDLAST THEN
            LastLineNo := GenJournalLine."Line No." + 10000
        ELSE
            LastLineNo := 10000;

        PurchSetup.Get();
        PurchSetup.TestField("Cost Place Dimension");
        PurchSetup.TestField("Cost Code Dimension");

        PurchHeader.FindSet();
        REPEAT
            PurchHeader.CalcFields("Payments Amount", "Journal Payments Amount");
            IF PurchHeader."Amount Including VAT" - PurchHeader."Payments Amount" - PurchHeader."Journal Payments Amount" > 0 THEN BEGIN

                if PurchHeader.Status <> PurchHeader.Status::Released then
                    Codeunit.Run(Codeunit::"Release Purchase Document", PurchHeader);

                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := JnlTempName;
                GenJournalLine."Journal Batch Name" := JnlBatchName;
                GenJournalLine."Line No." := LastLineNo;
                GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Vendor);
                GenJournalLine.VALIDATE("Account No.", PurchHeader."Buy-from Vendor No.");
                GenJournalLine.VALIDATE("Posting Date", TODAY);
                GenJournalLine.VALIDATE("Agreement No.", PurchHeader."Agreement No.");
                GenJournalLine.VALIDATE("Document Type", GenJournalLine."Document Type"::Payment);

                GenJournalLine.VALIDATE("Currency Code", PurchHeader."Currency Code");
                GenJournalLine."IW Document No." := PurchHeader."No.";

                // NC AB: пока не понял для чего это поле в операции поставщика 
                // GenJournalLine."IW Planned Repayment Date" := PurchHeader."IW Planned Repayment Date";

                IF PurchHeader."Payment Details" <> '' THEN
                    GenJournalLine.Description := COPYSTR(PurchHeader."Payment Details", 1, MaxStrLen(GenJournalLine.Description));
                if not GenJournalTempl.Get(JnlTempName) then
                    GenJournalTempl.Init;
                if GenJournalBatch.Get(JnlTempName, JnlBatchName) then begin
                    GenJournalLine.VALIDATE("Bal. Account Type", GenJournalBatch."Bal. Account Type");
                    GenJournalLine.VALIDATE("Bal. Account No.", GenJournalBatch."Bal. Account No.");
                    // NC AB: и остальное полезное из GenJournalLine.SetUpNewLine >>
                    if GenJournalBatch."No. Series" <> '' then begin
                        Clear(NoSeriesMgt);
                        GenJournalLine."Document No." := NoSeriesMgt.TryGetNextNo(GenJournalBatch."No. Series", GenJournalLine."Posting Date");
                    end;
                    GenJournalLine."Source Code" := GenJournalTempl."Source Code";
                    GenJournalLine."Reason Code" := GenJournalBatch."Reason Code";
                    GenJournalLine."Posting No. Series" := GenJournalBatch."Posting No. Series";
                    GenJournalLine.UpdateJournalBatchID();
                    // NC AB <<
                end;
                IF PurchHeader."Payment Type" = PurchHeader."Payment Type"::"pre-pay" THEN BEGIN
                    GenJournalLine.Prepayment := TRUE;
                    // NC AB: пока не понял для чего это поле в операции поставщика 
                    // GenJournalLine."Payment Invoice Type" := GenJournalLine."Payment Invoice Type"::"pre-pay";
                END ELSE BEGIN
                    // GenJournalLine."Payment Invoice Type" := GenJournalLine."Payment Invoice Type"::"post-payment";
                END;
                GenJournalLine.VALIDATE(Amount, PurchHeader."Invoice Amount Incl. VAT");
                GenJournalLine."VAT Amount" := PurchHeader."Invoice VAT Amount";
                GenJournalLine."Payment Type" := '01';
                GenJournalLine."Payment Subsequence" := '5';
                GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Computer Check";
                GenJournalLine."Payment Method" := GenJournalLine."Payment Method"::Electronic;
                GenJournalLine."Payment Assignment" := PurchHeader."Payment Assignment";
                GenJournalLine.INSERT(TRUE);

                if PurchHeader."Dimension Set ID" <> 0 then
                    if DimSetEntry.Get(PurchHeader."Dimension Set ID", PurchSetup."Cost Place Dimension") then
                        DimMgtExt.valDimValueWithUpdGlobalDim(
                            PurchSetup."Cost Place Dimension", DimSetEntry."Dimension Value Code", GenJournalLine."Dimension Set ID",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");

                CostCodeDimValue := '';
                PurchaseLine.RESET;
                PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SETRANGE("Document No.", PurchHeader."No.");
                IF PurchaseLine.COUNT = 1 THEN begin
                    PurchaseLine.FINDFIRST;
                    if PurchaseLine."Dimension Set ID" <> 0 then
                        if DimSetEntry.Get(PurchaseLine."Dimension Set ID", PurchSetup."Cost Code Dimension") then
                            CostCodeDimValue := DimSetEntry."Dimension Value Code";
                end;
                if CostCodeDimValue = '' then
                    if PurchHeader."Dimension Set ID" <> 0 then
                        if DimSetEntry.Get(PurchHeader."Dimension Set ID", PurchSetup."Cost Code Dimension") then
                            CostCodeDimValue := DimSetEntry."Dimension Value Code";
                if CostCodeDimValue <> '' then
                    DimMgtExt.valDimValueWithUpdGlobalDim(
                        PurchSetup."Cost Code Dimension", CostCodeDimValue, GenJournalLine."Dimension Set ID",
                        GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");

                GenJournalLine."Payment Purpose" := gcduERPC.GetPaymentDetails(PurchHeader."No.", true);
                AddText := gcduERPC.GetPaymentDetails(PurchHeader."No.", false);
                GenJournalLine.Description := COPYSTR(GenJournalLine.Description + '/' + AddText, 1, MAXSTRLEN(GenJournalLine.Description));

                IF (GenJournalLine."Shortcut Dimension 1 Code" = '') OR (GenJournalLine."Shortcut Dimension 2 Code" = '') THEN BEGIN
                    PurchaseLine.SetCurrentKey("Amount Including VAT");
                    PurchaseLine.Ascending(false);
                    PurchaseLine.FindFirst();
                    CostPlaceDimValue := '';
                    CostCodeDimValue := '';
                    if PurchaseLine."Dimension Set ID" <> 0 then begin
                        if DimSetEntry.Get(PurchaseLine."Dimension Set ID", PurchSetup."Cost Place Dimension") then
                            CostPlaceDimValue := DimSetEntry."Dimension Value Code";
                        if DimSetEntry.Get(PurchaseLine."Dimension Set ID", PurchSetup."Cost Code Dimension") then
                            CostCodeDimValue := DimSetEntry."Dimension Value Code";
                    end;
                    if CostPlaceDimValue <> '' then
                        DimMgtExt.valDimValueWithUpdGlobalDim(
                            PurchSetup."Cost Place Dimension", CostPlaceDimValue, GenJournalLine."Dimension Set ID",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
                    if CostCodeDimValue <> '' then
                        DimMgtExt.valDimValueWithUpdGlobalDim(
                            PurchSetup."Cost Code Dimension", CostCodeDimValue, GenJournalLine."Dimension Set ID",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
                END;

                GenJournalLine.MODIFY;
                LastLineNo := LastLineNo + 10000;

                // NC AB: заполнять в PurchHeader поля "Journal Template Name", "Journal Batch Name" и "Line No." - некорректно
                // т.к. строк журнала из одного документа может быть несколько

                // где используется это поле - непонятно
                // PurchHeader."Payment Doc No." := GenJournalLine."Document No.";

                PurchHeader.MODIFY;
                LinesCount += 1;
            END;
        UNTIL PurchHeader.NEXT = 0;
    end;
}