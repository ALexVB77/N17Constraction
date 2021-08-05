tableextension 80038 "Purchase Header (Ext)" extends "Purchase Header"
{
    fields
    {
        field(50001; "Payment Assignment"; Text[15])
        {
            Description = 'NC 51378 AB';
            Caption = 'Payment Assignment';
        }
        field(50002; "Inv.-Fact. is Received"; Boolean)
        {
            Caption = 'Inv.-Fact. is Received';
            Description = 'NC 50280 OA';
        }
        field(50003; "Act is Received"; Boolean)
        {
            Caption = 'Act is Received';
            Description = 'NC 50280 OA';
        }
        field(50010; "Linked Purchase Order Act No."; Code[20])
        {
            Description = 'NC 51378 AB';
            Caption = 'Linked Purchase Order Act No.';
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(50011; "Archiving Type"; Option)
        {
            Description = 'NC 51378 AB';
            Caption = 'Archiving Type';
            OptionCaption = ' ,Problem Act,Payment Invoice';
            OptionMembers = " ","Problem Act","Payment Invoice";
        }
        field(50012; "Sent to pre. Approval"; Boolean)
        {
            Description = 'NC 51374 AB';
            Caption = 'Sent to pre. approval';
        }
        field(50013; "Receptionist"; code[50])
        {
            Caption = 'Receptionist';
            Description = 'NC 51380 AB';
        }
        field(50014; "My Approved"; boolean)
        {
            CalcFormula = exist("Approval Entry" where("Table ID" = const(38),
                                                        "Document Type" = field("Document Type"),
                                                        "Document No." = field("No."),
                                                        Status = const(Approved),
                                                        "Approver ID" = field("Approver ID Filter")));
            Caption = 'My Approved';
            Description = 'NC 51374 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50015; "Approver ID Filter"; code[50])
        {
            Caption = 'Approver ID Filter';
            Description = 'NC 51374 AB';
            FieldClass = FlowFilter;
        }
        field(50022; "Spec. Bank Account No."; Code[20])
        {
            TableRelation = "Bank Account";
            Caption = 'Spec. Bank Account No.';
            Description = 'NC 51379 AB';
        }
        field(60088; "Original Company"; Code[2])
        {
            Description = 'NC 51432 AP';
            Caption = 'Original Company';
        }
        field(70002; "Process User"; Code[50])
        {
            TableRelation = "User Setup";
            Description = 'NC 51373 AB';
            Caption = 'Process User';
            Editable = false;

            // trigger OnValidate()
            // begin
            //     UpdatePurchLinesByFieldNo(FIELDNO("Process User"), CurrFieldNo <> 0);
            // end;
        }
        field(70003; "Date Status App"; Date)
        {
            Description = 'NC 51373 AB';
            Caption = 'Date Status Approval';
            Editable = false;
        }
        field(70005; "Exists Attachment"; Boolean)
        {
            CalcFormula = Exist("Document Attachment" WHERE("Table ID" = CONST(38), "Document Type" = FIELD("Document Type"), "No." = FIELD("No.")));
            Caption = 'Exists Attachment';
            Description = 'NC 51373 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70007; "Payments Amount"; Decimal)
        {
            // Переделано из Normal на FlowField
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount
                            where("Vendor No." = field("Buy-from Vendor No."),
                                    "Initial Document Type" = const(Payment),
                                    "IW Document No." = field("No."),
                                    "Entry Type" = const("Initial Entry")));
            Caption = 'Payments Amount';
            Description = 'NC 51373 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70008; "Invoice VAT Amount"; Decimal)
        {
            Description = 'NC 51373 AB';
            Caption = 'VAT Amount';
            trigger OnValidate()
            begin
                // NC 51373 AB >> #CHECKLATER
                // отключил, мне не надо                
                // "Invoice Amount":="Invoice Amount Incl. VAT"-"Invoice VAT Amount";
                // // NCS-026 AP 110314 >>
                // ExchangeFCYtoLCY();
                // // NCS-026 AP 110314 <<
                // NC 51373 AB >>
            end;
        }
        field(70009; "Invoice Amount Incl. VAT"; Decimal)
        {
            Description = 'NC 51373 AB';
            Caption = 'Invoice Amount Incl. VAT';
            trigger OnValidate()
            begin
                // NC 51373 AB >> #CHECKLATER
                // отключил, мне не надо
                // "Invoice Amount":="Invoice Amount Incl. VAT"-"Invoice VAT Amount";
                // // NCS-026 AP 110314 >>
                // ExchangeFCYtoLCY();
                // // NCS-026 AP 110314 <<
                // NC 51373 AB >>
            end;
        }
        field(70010; "Payment Type"; Option)
        {
            Description = 'NC 51378 AB';
            Caption = 'Payment Type';
            OptionCaption = 'Prepay,Postpay';
            OptionMembers = "pre-pay","post-payment";
        }
        field(70011; "Payment Doc Type"; Option)
        {
            Description = 'NC 51373 AB';
            Caption = 'Payment Doc Type';
            OptionCaption = 'Invoice,Payment Request';
            OptionMembers = Invoice,"Payment Request";
        }
        field(70012; "Payment Details"; Text[230])
        {
            Description = 'NC 51373 AB';
            Caption = 'Payment Details';
            trigger OnValidate()
            var
                CreditMemoReason: record "Credit-Memo Reason";
            begin
                IF ("Payment Details" <> '') AND ("Document Type" = "Document Type"::"Credit Memo") THEN
                    CreditMemoReason.GET("Payment Details");
            end;

            trigger OnLookup()
            var
                CreditMemoReason: record "Credit-Memo Reason";
            begin
                IF "Document Type" = "Document Type"::"Credit Memo" THEN BEGIN
                    IF CreditMemoReason.GET("Payment Details") THEN;
                    IF PAGE.RUNMODAL(0, CreditMemoReason) = ACTION::LookupOK THEN
                        VALIDATE("Payment Details", CreditMemoReason.Reason);
                END;
            end;
        }
        field(70013; "Vendor Bank Account"; Code[20])
        {
            Description = 'NC 51373 AB';
            Caption = 'Vendor Bank Account';
            TableRelation = "Bank Directory".BIC;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                VendorBankAccount: Record "Vendor Bank Account";
            begin
                if "Vendor Bank Account" = '' then
                    exit;
                if "Vendor Bank Account No." = '' then begin
                    if Rec."Pay-to Vendor No." <> '' then begin
                        VendorBankAccount.SetRange("Vendor No.", "Pay-to Vendor No.");
                        VendorBankAccount.SetRange(BIC, "Vendor Bank Account");
                        if VendorBankAccount.FindFirst() then
                            "Vendor Bank Account No." := VendorBankAccount.Code;
                    end;
                end else begin
                    VendorBankAccount.Get(Rec."Pay-to Vendor No.", Rec."Vendor Bank Account No.");
                    VendorBankAccount.TestField(BIC, "Vendor Bank Account");
                end;
            end;
        }
        field(70014; "Vendor Bank Account No."; Text[30])
        {
            Description = 'NC 51373 AB';
            Caption = 'Vendor Bank Account #';
            TableRelation = "Vendor Bank Account".Code WHERE("Vendor No." = field("Pay-to Vendor No."));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                VendorBankAccount: Record "Vendor Bank Account";
            begin
                if "Vendor Bank Account No." = '' then
                    exit;
                VendorBankAccount.Get(Rec."Pay-to Vendor No.", Rec."Vendor Bank Account No.");
                Rec."Vendor Bank Account" := VendorBankAccount.BIC;
            end;
        }
        field(70015; Controller; Code[50])
        {
            Caption = 'Controller';
            Description = 'NC 51373 AB';
            TableRelation =
            if ("IW Documents" = const(true)) "User Setup"."User ID" WHERE("Status App" = CONST(2))
            else
            if ("IW Documents" = const(false)) "User Setup"."User ID" WHERE("Status App Act" = CONST(1));
            ValidateTableRelation = false;
        }

        // NC AB: 
        // field(70016; Paid; Boolean) - убрано, вместо него функции SetPaymentInvPaidStatus и GetPaymentInvPaidStatus

        field(70017; "External Agreement No. (Calc)"; Text[30])
        {
            CalcFormula = Lookup("Vendor Agreement"."External Agreement No." WHERE("Vendor No." = FIELD("Buy-from Vendor No."), "No." = FIELD("Agreement No.")));
            Caption = 'External Agreement No.';
            Description = 'NC 51378 AB';
            FieldClass = FlowField;
        }
        field(70018; "Paid Date Fact"; Date)
        {
            // Переделано из Normal на FlowField
            CalcFormula = max("Detailed Vendor Ledg. Entry"."Posting Date"
                            where("Vendor No." = field("Buy-from Vendor No."),
                                    "Initial Document Type" = const(Payment),
                                    "IW Document No." = field("No."),
                                    "Entry Type" = const("Initial Entry")));
            Caption = 'Paid Date Fact';
            Description = 'NC 51373 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70019; "Problem Document"; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Problem Document';
            trigger OnValidate()
            var
                PurchSetup: Record "Purchases & Payables Setup";
            begin
                //NC 27251 HR beg
                IF NOT "Problem Document" THEN
                    VALIDATE("Due Date", WORKDATE)
                ELSE BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Payment Delay Period");
                    TESTFIELD("Due Date");
                    VALIDATE("Due Date", CALCDATE(PurchSetup."Payment Delay Period", "Due Date"));
                END;
                UpdateCF;
                //NC 27251 HR end
            end;
        }
        field(70020; "Problem Type"; enum "Purchase Problem Type")
        {
            Caption = 'Problem Type';
            Description = 'NC 51373 AB';
        }
        field(70021; "OKATO Code"; Text[30])
        {
            TableRelation = OKATO;
            Description = 'NC 51373 AB';
            Caption = 'OKATO Code';
        }

        field(70022; "KBK Code"; Text[30])
        {
            TableRelation = KBK;
            Description = 'NC 51373 AB';
            Caption = 'KBK Code';
        }
        field(70024; "Pre-Approver"; Code[50])
        {
            Description = 'NC 51373 AB';
            Caption = 'Pre-Approver';
            TableRelation = "User Setup";

            trigger OnValidate()
            begin
                if "Pre-Approver" <> '' then
                    TestField("Act Type", "Act Type"::Advance);
            end;
        }

        // NC AB:
        // поля Approver и Pre-Approver реализуем через функции
        // field(70023; Approver; Code[50])
        // {
        //     Description = 'NC 51373 AB';
        //     Caption = 'Approver';
        //     TableRelation = "User Setup";
        //     Editable = false;
        // }
        // Next Approver - не нужен
        // field(70025; "Next Approver"; Code[50])
        // {
        //     Description = 'NC 51373 AB';
        //     Caption = 'Next Approver';
        //     TableRelation = "User Setup";
        // }
        // поле Approver реализуем через функцию
        // field(70026; PreApprover; Boolean)
        // {
        //    Description = 'NC 51373 AB';
        //    Caption = 'Exist Pre-Approver';
        // }

        field(70027; "IW Planned Repayment Date"; Date)
        {
            Description = 'NC 51378 AB';
            Caption = 'IW Planned Repayment Date';
        }

        // NC AB: поля 70030 "Journal Template Name", 70031 "Journal Batch Name" и 70032 "Line No." - не использовать!
        field(70032; "Journal Payments Amount"; Decimal)
        {
            // Переделано из Normal на FlowField
            CalcFormula = sum("Gen. Journal Line".Amount
                            where("Document Type" = const(Payment),
                                   "Account Type" = const(Vendor),
                                    "Account No." = field("Buy-from Vendor No."),
                                    "IW Document No." = field("No.")));
            Caption = 'Journal Payments Amount';
            Description = 'NC 51373 AB';
            Editable = false;
            FieldClass = FlowField;
        }

        field(70034; "IW Documents"; Boolean)
        {
            Caption = 'IW Documents';
            Description = 'NC 50085 PA';
        }

        // NC AB: Используем комментарии утверждения вместо этого поля
        // field(70035; "Problem Type Txt"; Text[180])
        // {
        //     Description = 'NC 51373 AB';
        //     Caption = 'Problem Type';
        // }

        field(70038; "Pre-booking Document"; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Pre-booking Document';
        }
        field(70039; "Pre-booking Accept"; Boolean)
        {
            Caption = 'Pre-booking Accept';
            Description = 'NC 51373 AB';
        }
        field(70045; "Act Type"; enum "Purchase Act Type")
        {
            Caption = 'Act Type';
            Description = 'NC 51373 AB';
        }
        field(70047; "Payment to Person"; Boolean)
        {
            Caption = 'Payment to Person';
            Description = 'NC 51378 AB';
        }
        field(90003; "Status App Act"; Enum "Purchase Act Approval Status")
        {
            Description = 'NC 51373 AB';
            Caption = 'Approval Status';
        }

        field(90004; Estimator; Code[50])
        {
            Caption = 'Estimator';
            Description = 'NC 51373 AB';
            TableRelation = "User Setup"."User ID" WHERE("Status App Act" = CONST(Estimator));
            ValidateTableRelation = false;
        }

        // NC AB: не будем использовать
        // field(90005; Check; Option)
        // {
        //     Caption = 'Check Status';
        //     Description = 'NC 51373 AB';
        //     OptionCaption = ' ,Controler app,Estimator app,Estimator rej,Checker app,Checker rej,Approver app,Approver rej';
        //     OptionMembers = " ","Controler app","Estimator app","Estimator rej","Checker app","Checker rej","Approver app","Approver rej";
        // }

        field(90006; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            Description = 'NC 51373 AB';
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice));
        }

        // NC AB: не будем использовать
        // field(90008; "Check Approver"; Boolean)
        // {
        //     Caption = 'Checked by Approver';
        //     Description = 'NC 51374 AB';
        // }

        field(90009; "Receive Account"; Boolean)
        {
            Caption = 'Receive Account';
            Description = 'NC 51373 AB';
            trigger OnValidate()
            var
                VLE: record "Vendor Ledger Entry";
            begin
                // NC 51373 AB >>
                // надо сделать FF поле в Т25 
                // //NC-47007 DP >>
                // IF "Invoice No."<>'' THEN
                // BEGIN
                //   VLE.SETRANGE("Document No.","Invoice No.");
                //   VLE.MODIFYALL("Receive Account","Receive Account");
                // END;
                //NC-47007 DP <<
            end;
        }
        field(90019; "Location Document"; Boolean)
        {
            Description = 'NC 51373 AB';
            Editable = false;
            Caption = 'Location Document';

        }
        field(90020; Storekeeper; Code[50])
        {
            TableRelation = "User Setup";
            Description = 'NC 51373 AB';
            Editable = false;
            Caption = 'Storekeeper';
        }
    }

    keys
    {
        key(Key50000; "IW Documents", "Linked Purchase Order Act No.")
        {
            SumIndexFields = "Invoice Amount Incl. VAT";
        }
    }

    local procedure UpdateCF()
    var
        PL: record "Purchase Line";
        PBE: record "Projects Budget Entry";
    begin
        //NC 27251 HR beg
        IF "Due Date" = 0D THEN
            EXIT;
        PL.SETRANGE("Document Type", "Document Type");
        PL.SETRANGE("Document No.", "No.");
        IF PL.FINDSET THEN BEGIN
            REPEAT
                IF PL."Forecast Entry" <> 0 THEN BEGIN
                    PBE.SETRANGE("Entry No.", PL."Forecast Entry");
                    IF PBE.FINDFIRST THEN BEGIN
                        PBE.VALIDATE(Date, "Due Date");
                        PBE.VALIDATE("Problem Pmt. Document", "Problem Document");
                        PBE.MODIFY(TRUE);
                    END;
                END;
            UNTIL PL.NEXT = 0;
        END;
        //NC 27251 HR end
    end;

    procedure GetStatusAppAct(DocType: Enum "Purchase Act Approval Status"; No: Code[20]): Integer
    begin
        IF GET(DocType, No) THEN
            EXIT("Status App Act".AsInteger());
    end;

    procedure PurchOrderArchive()
    var
        PurchRcptLine: record "Purch. Rcpt. Line";
        UndoPurchRcptLine: codeunit "Undo Purchase Receipt Line";
        ArchiveMgt: Codeunit ArchiveManagement;
        LocText50013: Label 'Document %1 has been sent to the archive.';
    begin
        PurchRcptLine.SETRANGE("Order No.", "No.");
        PurchRcptLine.SETRANGE(Correction, FALSE);
        IF NOT PurchRcptLine.ISEMPTY THEN BEGIN
            UndoPurchRcptLine.SetHideDialog(TRUE);
            UndoPurchRcptLine.RUN(PurchRcptLine);
        END;

        // NC AB >>
        // не оставляем архивный акт в T36 и T37, оправляем его в T5109 и T5110
        // Archival := TRUE;
        // MODIFY;
        ArchiveMgt.StorePurchDocument(Rec, false);
        Rec.SetHideValidationDialog(true);
        Rec.Delete(true);
        // NC AB <<

        MESSAGE(LocText50013, "No.");
    end;

    procedure HasBoundedCashFlows(): Boolean
    var
        PurchLine3: record "Purchase Line";
    begin
        //NC 29594 HR beg
        PurchLine3.SETRANGE("Document Type", "Document Type");
        PurchLine3.SETRANGE("Document No.", "No.");
        PurchLine3.SETFILTER("Forecast Entry", '<>0');
        EXIT(NOT PurchLine3.ISEMPTY);
        //NC 29594 HR end
    end;

    procedure MessageIfPurchLinesNotExist()
    var
        MessageText: Label 'Document %1 contains no lines.';
    begin
        if not PurchLinesExist then
            Error(MessageText, Rec."No.");
    end;

    procedure GetInvoiceAmountsLCY(AmountType: enum "Amount Type") Result: Decimal
    var
        Currency: Record Currency;
        CurrExRate: record "Currency Exchange Rate";
    begin
        case AmountType of
            AmountType::"Include VAT":
                Result := "Invoice Amount Incl. VAT";
            AmountType::"Exclude VAT":
                Result := "Invoice Amount Incl. VAT" - "Invoice VAT Amount";
            AmountType::VAT:
                Result := "Invoice VAT Amount";
        end;
        if Rec."Currency Code" <> '' then begin
            Currency.InvoiceRoundingDirection();
            Result := CurrExRate.ExchangeAmtFCYToLCY("Posting Date", "Currency Code", Result, "Currency Factor");
            Result := Round(Result, Currency."Amount Rounding Precision");
        end;
    end;

    procedure GetAddTypeCommentText(AddType: enum "Purchase Comment Add. Type"): text
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type", "Document Type");
        PurchCommentLine.SetRange("No.", "No.");
        PurchCommentLine.SetRange("Line No.", 0);
        PurchCommentLine.SetRange("Add. Line Type", AddType);
        if PurchCommentLine.FindLast() then
            exit(PurchCommentLine.Comment + PurchCommentLine."Comment 2");
    end;

    procedure SetAddTypeCommentText(AddType: enum "Purchase Comment Add. Type"; NewComment: text)
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type", "Document Type");
        PurchCommentLine.SetRange("No.", "No.");
        PurchCommentLine.SetRange("Line No.", 0);
        PurchCommentLine.SetRange("Add. Line Type", AddType);
        if not PurchCommentLine.FindLast() then begin
            PurchCommentLine.Init();
            PurchCommentLine."Document Type" := "Document Type";
            PurchCommentLine."No." := "No.";
            PurchCommentLine."Line No." := 0;
            PurchCommentLine."Document Line No." := 0;
            PurchCommentLine.Date := Today;
            PurchCommentLine."Add. Line Type" := AddType;
            PurchCommentLine.Insert(true);
        end;
        PurchCommentLine.Comment := CopyStr(NewComment, 1, MaxStrLen(PurchCommentLine.Comment));
        PurchCommentLine."Comment 2" :=
          CopyStr(NewComment, MaxStrLen(PurchCommentLine.Comment) + 1, MaxStrLen(PurchCommentLine."Comment 2"));
        PurchCommentLine.Modify(true);
    end;

    procedure GetApprovalCommentText(): text
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalCommentLine: Record "Approval Comment Line";
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        NoReqToApproveErr: Label 'There is no approval request to approve.';
        StepInstanceID: Guid;
    begin
        if ApprovalMgt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, RecordID) then begin
            ApprovalCommentLine.SetCurrentKey("Linked Approval Entry No.");
            ApprovalCommentLine.SetRange("Linked Approval Entry No.", ApprovalEntry."Entry No.");
            if ApprovalCommentLine.FindLast() then
                exit(ApprovalCommentLine.Comment);
            StepInstanceID := ApprovalEntry."Workflow Step Instance ID";
        end;

        ApprovalEntry.Reset;
        if not IsNullGuid(StepInstanceID) then begin
            ApprovalEntry.SetCurrentKey("Record ID to Approve", "Workflow Step Instance ID", "Sequence No.");
            ApprovalEntry.SetRange("Workflow Step Instance ID", StepInstanceID);
        end else
            ApprovalEntry.SetCurrentKey("Table ID", "Document Type", "Document No.", "Sequence No.", "Record ID to Approve");
        ApprovalEntry.SetRange("Record ID to Approve", RecordID);
        ApprovalEntry.SetRange("Table ID", Database::"Purchase Header");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Rejected);
        if ApprovalEntry.FindLast() then begin
            ApprovalCommentLine.SetRange("Linked Approval Entry No.", ApprovalEntry."Entry No.");
            if ApprovalCommentLine.FindLast() then
                exit(ApprovalCommentLine.Comment);
        end;
    end;

    procedure SetApprovalCommentText(NewComment: text)
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalCommentLine: Record "Approval Comment Line";
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        NoReqToApproveErr: Label 'There is no approval request to approve.';
    begin
        if not ApprovalMgt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, RecordID) then
            Error(NoReqToApproveErr);

        ApprovalCommentLine.SetCurrentKey("Linked Approval Entry No.");
        ApprovalCommentLine.SetRange("Linked Approval Entry No.", ApprovalEntry."Entry No.");
        if not ApprovalCommentLine.FindLast() then begin
            ApprovalCommentLine.Reset;
            ApprovalCommentLine.SetRange("Table ID", ApprovalEntry."Table ID");
            ApprovalCommentLine.SetRange("Record ID to Approve", ApprovalEntry."Record ID to Approve");
            ApprovalCommentLine.Init;
            ApprovalCommentLine."Workflow Step Instance ID" := ApprovalEntry."Workflow Step Instance ID";
            ApprovalCommentLine.Insert(true);
        end;
        ApprovalCommentLine.Comment := CopyStr(NewComment, 1, MaxStrLen(ApprovalCommentLine.Comment));
        ApprovalCommentLine.Modify(true);
    end;

    procedure GetPaymentInvPaidStatus(): Boolean
    begin
        CalcFields("Payments Amount");
        exit("Payments Amount" >= "Invoice Amount Incl. VAT");
    end;

    procedure SetPaymentInvPaidStatus(NewPaid: Boolean)
    var
        gvduERPC: codeunit "ERPC Funtions";
    begin
        IF NewPaid THEN BEGIN
            CalcFields("Paid Date Fact");
            TESTFIELD("Paid Date Fact");
            gvduERPC.PostForecastEntry(Rec);
        END ELSE BEGIN
            gvduERPC.UnpostForecastEntry(Rec);
        END;
    end;

    procedure PrintRecordsExt(ShowRequestForm: Boolean; ReportSelUsage: enum "Report Selection Usage")
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DocumentPrintBuffer: Record "Document Print Buffer";
        DocumentPrint: Codeunit "Document-Print";
    begin
        //CheckMixedDropShipment;
        DocumentPrintBuffer.DeleteAll();
        DocumentPrint.InsertDocPrintBuffer(DocumentPrintBuffer, DATABASE::"Purchase Header", "Document Type".AsInteger(), "No.");
        Commit();

        DocumentSendingProfile.TrySendToPrinterVendor(
          ReportSelUsage.AsInteger(), Rec, FieldNo("Buy-from Vendor No."), ShowRequestForm);
    end;

}