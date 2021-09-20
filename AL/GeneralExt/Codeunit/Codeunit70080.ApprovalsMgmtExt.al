codeunit 70080 "Approvals Mgmt. (Ext)"
{
    Permissions = TableData "Approval Entry" = imd,
                  TableData "Approval Comment Line" = imd,
                  TableData "Posted Approval Entry" = imd,
                  TableData "Posted Approval Comment Line" = imd,
                  TableData "Overdue Approval Entry" = imd,
                  TableData "Notification Entry" = imd;

    trigger OnRun()
    begin
    end;

    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowResponceHandling: Codeunit "Workflow Response Handling Ext";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        NothingToApproveErr: Label 'There is nothing to approve.';
        UserIdNotInSetupErr: Label 'User ID %1 does not exist in the Approval User Setup window.', Comment = 'User ID NAVUser does not exist in the Approval User Setup window.';

    [EventSubscriber(ObjectType::Table, 455, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnApprCommentLineAfterInsert(var Rec: Record "Approval Comment Line"; RunTrigger: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        if rec.IsTemporary or (Rec."Table ID" <> Database::"Purchase Header") then
            exit;
        ApprovalEntry.SetCurrentKey("Table ID", "Record ID to Approve", Status, "Workflow Step Instance ID", "Sequence No.");
        ApprovalEntry.SetRange("Table ID", Rec."Table ID");
        ApprovalEntry.SetRange("Record ID to Approve", Rec."Record ID to Approve");
        ApprovalEntry.SetRange("Workflow Step Instance ID", Rec."Workflow Step Instance ID");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then
            if ApprovalEntry."Document Type" = ApprovalEntry."Document Type"::Order then
                if (ApprovalEntry."Act Type" <> ApprovalEntry."Act Type"::" ") or ApprovalEntry."IW Documents" then begin
                    Rec."Linked Approval Entry No." := ApprovalEntry."Entry No.";
                    Rec.Modify(false);
                end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnBeforeApprovalEntryInsert', '', false, false)]
    local procedure OnBeforeApprovalEntryInsert(var ApprovalEntry: Record "Approval Entry"; ApprovalEntryArgument: Record "Approval Entry")
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        ApprovalEntry."Status App Act" := ApprovalEntryArgument."Status App Act";
        ApprovalEntry."Act Type" := ApprovalEntryArgument."Act Type";
        ApprovalEntry."Status App" := ApprovalEntryArgument."Status App";
        ApprovalEntry."IW Documents" := ApprovalEntryArgument."IW Documents";
        if (ApprovalEntry."Act Type" <> ApprovalEntry."Act Type"::" ") and
           (ApprovalEntry."Status App Act".AsInteger() > ApprovalEntry."Status App Act"::Controller.AsInteger()) and
           (ApprovalEntry."Approver ID" = UserId) and ApprovalEntryArgument.Reject
        then
            ApprovalEntry.Status := ApprovalEntry.Status::Created;
        if (ApprovalEntry."IW Documents") and
           (ApprovalEntry."Status App".AsInteger() > ApprovalEntry."Status App"::Reception.AsInteger()) and
           (ApprovalEntry."Approver ID" = UserId) and ApprovalEntryArgument.Reject
        then
            ApprovalEntry.Status := ApprovalEntry.Status::Created;
        ApprovalEntry."Preliminary Approval" := ApprovalEntryArgument."Preliminary Approval";
        if (ApprovalEntry."Act Type" <> ApprovalEntry."Act Type"::" ") or ApprovalEntry."IW Documents" then begin
            ApprovalEntry."Sender ID" := ApprovalEntryArgument."Sender ID";
            PurchSetup.Get();
            if Format(PurchSetup."Approvement Delay Period") <> '' then
                ApprovalEntry."Due Date" := CalcDate(PurchSetup."Approvement Delay Period", Today);
        end;
    end;

    procedure CreateApprovalRequestsPurchActAndPayInv(RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        ApprovalEntryArgument: Record "Approval Entry";
        PurchHeader: Record "Purchase Header";
        PayOrderMgt: Codeunit "Payment Order Management";
    begin
        RecRef.SetTable(PurchHeader);
        if not PurchHeader."IW Documents" then
            PayOrderMgt.ChangePurchaseOrderActStatus(PurchHeader, false, 0)
        else
            PayOrderMgt.ChangePurchasePaymentInvoiceStatus(PurchHeader, false, 0);

        PopulateApprovalEntryArgumentPurchAct(RecRef, WorkflowStepInstance, ApprovalEntryArgument);
        if not PurchHeader."IW Documents" then begin
            ApprovalEntryArgument."Act Type" := PurchHeader."Act Type";
            ApprovalEntryArgument."Status App Act" := ApprovalEntryArgument."Status App Act"::Controller;
            CreateApprovalRequestForSpecificUser(WorkflowStepArgument, ApprovalEntryArgument, PurchHeader.Controller);
            ApprovalEntryArgument."Status App Act" := PurchHeader."Status App Act";
            ApprovalEntryArgument."Sender ID" := PurchHeader.Controller;
        end else begin
            ApprovalEntryArgument."IW Documents" := PurchHeader."IW Documents";
            ApprovalEntryArgument."Status App" := ApprovalEntryArgument."Status App"::Reception;
            CreateApprovalRequestForSpecificUser(WorkflowStepArgument, ApprovalEntryArgument, PurchHeader.Receptionist);
            ApprovalEntryArgument."Status App" := Enum::"Purchase Approval Status".FromInteger(PurchHeader."Status App");
            ApprovalEntryArgument."Sender ID" := PurchHeader.Receptionist;
        end;

        PurchHeader.TestField("Process User");
        CreateApprovalRequestForSpecificUser(WorkflowStepArgument, ApprovalEntryArgument, PurchHeader."Process User");

        if UserID = PurchHeader."Process User" then
            MoveToNextPurchActAndPayInvStatus(RecRef, WorkflowStepInstance, false)
        else
            Message(PayOrderMgt.GetChangeStatusMessage);
    end;

    procedure MoveToNextPurchActAndPayInvStatus(RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance"; Reject: Boolean)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        ApprovalEntryArgument: Record "Approval Entry";
        ApprovalEntry: Record "Approval Entry";
        PurchHeader: Record "Purchase Header";
        NotificationEntry: Record "Notification Entry";
        PayOrderMgt: Codeunit "Payment Order Management";
        RecRef2: RecordRef;
        RejectEntryNo: Integer;
        EndOfWorkflow: Boolean;
        SkipSenderNotification: Boolean;
    begin
        if RecRef.Number = DATABASE::"Approval Entry" then begin
            RecRef.SetTable(ApprovalEntry);
            PurchHeader.Get(ApprovalEntry."Document Type", ApprovalEntry."Document No.");
            if Reject then
                RejectEntryNo := ApprovalEntry."Entry No.";
        end else begin
            RecRef.SetTable(PurchHeader);
            PurchHeader.Get(PurchHeader."Document Type", PurchHeader."No.");
            SkipSenderNotification := true;
        end;

        PurchHeader.TestField("Process User", USERID);
        RecRef2.GetTable(PurchHeader);

        if not PurchHeader."IW Documents" then begin
            if not SkipSenderNotification then
                NotificationEntry.CreateNotificationEntry(
                    NotificationEntry.Type::Approval, PurchHeader.Controller, ApprovalEntry, Page::"Purchase Order Act", '', UserID);
            PayOrderMgt.ChangePurchaseOrderActStatus(PurchHeader, Reject, RejectEntryNo);
            EndOfWorkflow :=
                ((not Reject) and (PurchHeader."Status App Act" = PurchHeader."Status App Act"::Accountant)) or
                (Reject and (PurchHeader."Status App Act" = PurchHeader."Status App Act"::Controller));
        end else begin
            if not SkipSenderNotification then
                NotificationEntry.CreateNotificationEntry(
                    NotificationEntry.Type::Approval, PurchHeader.Receptionist, ApprovalEntry, Page::"Purchase Order App", '', UserID);
            PayOrderMgt.ChangePurchasePaymentInvoiceStatus(PurchHeader, Reject, RejectEntryNo);
            EndOfWorkflow :=
                ((not Reject) and (PurchHeader."Status App" = PurchHeader."Status App"::Payment)) or
                (Reject and (PurchHeader."Status App" = PurchHeader."Status App"::Reception));
        end;
        if EndOfWorkflow then
            Message(PayOrderMgt.GetChangeStatusMessage)
        else begin
            PurchHeader.TestField("Process User");
            PopulateApprovalEntryArgumentPurchAct(RecRef2, WorkflowStepInstance, ApprovalEntryArgument);
            if not PurchHeader."IW Documents" then begin
                ApprovalEntryArgument."Act Type" := PurchHeader."Act Type";
                ApprovalEntryArgument."Status App Act" := PurchHeader."Status App Act";
                ApprovalEntryArgument."Sender ID" := PurchHeader.Controller;
            end else begin
                ApprovalEntryArgument."IW Documents" := PurchHeader."IW Documents";
                ApprovalEntryArgument."Status App" := Enum::"Purchase Approval Status".FromInteger(PurchHeader."Status App");
                ApprovalEntryArgument."Sender ID" := PurchHeader.Receptionist;
            end;
            ApprovalEntryArgument.Reject := Reject;
            ApprovalEntryArgument."Preliminary Approval" := PurchHeader."Sent to pre. Approval";
            CreateApprovalRequestForSpecificUser(WorkflowStepArgument, ApprovalEntryArgument, PurchHeader."Process User");
            if (UserID = PurchHeader."Process User") and (not Reject) then
                MoveToNextPurchActAndPayInvStatus(RecRef, WorkflowStepInstance, Reject)
            else
                Message(PayOrderMgt.GetChangeStatusMessage);
        end;
    end;

    procedure DelegateApprovalRequestsPurchActAndPayInv(RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ApprovalEntry: Record "Approval Entry";
        PurchHeader: Record "Purchase Header";
        UserSetup: Record "User Setup";
        PayOrderMgt: Codeunit "Payment Order Management";
    begin
        RecRef.SetTable(ApprovalEntry);
        UserSetup.Get(ApprovalEntry."Approver ID");
        UserSetup.TestField(Absents, false);

        PurchHeader.Get(ApprovalEntry."Document Type", ApprovalEntry."Document No.");
        PurchHeader.TestField("IW Documents");
        PayOrderMgt.ChangePayInvStatusWhenDelegate(PurchHeader, ApprovalEntry."Approver ID");
        Message(PayOrderMgt.GetChangeStatusMessage);
    end;

    local procedure PopulateApprovalEntryArgumentPurchAct(RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance"; var ApprovalEntryArgument: Record "Approval Entry")
    var
        PurchaseHeader: Record "Purchase Header";

        EnumAssignmentMgt: Codeunit "Enum Assignment Management";
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
    begin
        ApprovalEntryArgument.Init();
        ApprovalEntryArgument."Table ID" := RecRef.Number;
        ApprovalEntryArgument."Record ID to Approve" := RecRef.RecordId;
        ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
        ApprovalEntryArgument."Approval Code" := WorkflowStepInstance."Workflow Code";
        ApprovalEntryArgument."Workflow Step Instance ID" := WorkflowStepInstance.ID;

        RecRef.SetTable(PurchaseHeader);
        ApprovalsMgmt.CalcPurchaseDocAmount(PurchaseHeader, ApprovalAmount, ApprovalAmountLCY);
        ApprovalEntryArgument."Document Type" := EnumAssignmentMgt.GetPurchApprovalDocumentType(PurchaseHeader."Document Type");
        ApprovalEntryArgument."Document No." := PurchaseHeader."No.";
        ApprovalEntryArgument."Salespers./Purch. Code" := PurchaseHeader."Purchaser Code";
        ApprovalEntryArgument.Amount := ApprovalAmount;
        ApprovalEntryArgument."Amount (LCY)" := ApprovalAmountLCY;
        ApprovalEntryArgument."Currency Code" := PurchaseHeader."Currency Code";
    end;

    local procedure CreateApprovalRequestForSpecificUser(WorkflowStepArgument: Record "Workflow Step Argument"; ApprovalEntryArgument: Record "Approval Entry"; ApprovalUserID: code[50])
    var
        UserSetup: Record "User Setup";
        SequenceNo: Integer;
    begin
        SequenceNo := ApprovalsMgmt.GetLastSequenceNo(ApprovalEntryArgument);

        if not UserSetup.Get(ApprovalUserID) then
            Error(UserIdNotInSetupErr, ApprovalUserID);

        SequenceNo += 1;
        ApprovalsMgmt.MakeApprovalEntry(ApprovalEntryArgument, SequenceNo, ApprovalUserID, WorkflowStepArgument);
    end;

    procedure RejectPurchActAndPayInvApprovalRequest(RecordID: RecordID)
    var
        ApprovalEntry: Record "Approval Entry";
        NoReqToRejectErr: Label 'There is no approval request to reject.';
    begin
        if not ApprovalsMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, RecordID) then
            Error(NoReqToRejectErr);

        ApprovalEntry.SetRecFilter;
        RejectApprovalRequests(ApprovalEntry);
    end;

    local procedure RejectApprovalRequests(var ApprovalEntry: Record "Approval Entry")
    var
        ApprovalCommentLine: Record "Approval Comment Line";
        ApprovalEntryToUpdate: Record "Approval Entry";
        PurchHeader: Record "Purchase Header";
        RejectApproval: page "Reject Approval";
        RejectReason: Text;
    begin
        if ApprovalEntry.FindSet() then
            repeat
                ApprovalCommentLine.SetCurrentKey("Linked Approval Entry No.");
                ApprovalCommentLine.SetRange("Linked Approval Entry No.", ApprovalEntry."Entry No.");
                if ApprovalCommentLine.IsEmpty then begin
                    RejectApproval.RunModal;
                    if not RejectApproval.GetResult(RejectReason) then
                        error('');
                    PurchHeader.SetApprovalCommentTextForEntry(RejectReason, ApprovalEntry);
                end;
            until ApprovalEntry.Next = 0;

        if ApprovalEntry.FindSet() then
            repeat
                ApprovalEntryToUpdate := ApprovalEntry;
                RejectSelectedApprovalRequest(ApprovalEntryToUpdate);
            until ApprovalEntry.Next = 0;
    end;

    local procedure RejectSelectedApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        UserSetup: Record "User Setup";
        RejectOnlyOpenRequestsErr: Label 'You can only reject open approval entries.';
    begin
        if ApprovalEntry.Status <> ApprovalEntry.Status::Open then
            Error(RejectOnlyOpenRequestsErr);

        if ApprovalEntry."Approver ID" <> UserId then begin
            UserSetup.Get(UserId);
            UserSetup.TestField("Approval Administrator");
        end;

        ApprovalEntry.Get(ApprovalEntry."Entry No.");
        ApprovalEntry.Validate(Status, ApprovalEntry.Status::Rejected);
        ApprovalEntry.Modify(true);

        ApprovalsMgmt.OnRejectApprovalRequest(ApprovalEntry);
    end;

    procedure CancelOpenApprovalRequestsForRecord(RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalEntryToUpdate: Record "Approval Entry";
        OldStatus: Enum "Approval Status";
    begin
        ApprovalEntry.SetCurrentKey("Table ID", "Document Type", "Document No.", "Sequence No.");
        ApprovalEntry.SetRange("Table ID", RecRef.Number);
        ApprovalEntry.SetRange("Record ID to Approve", RecRef.RecordId);
        ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Created, ApprovalEntry.Status::Open);
        ApprovalEntry.SetRange("Workflow Step Instance ID", WorkflowStepInstance.ID);
        if ApprovalEntry.FindSet() then
            repeat
                OldStatus := ApprovalEntry.Status;
                ApprovalEntryToUpdate := ApprovalEntry;
                ApprovalEntryToUpdate.Validate(Status, ApprovalEntryToUpdate.Status::Canceled);
                ApprovalEntryToUpdate.Modify(true);
                if OldStatus = ApprovalEntry.Status::Open then
                    ApprovalsMgmt.CreateApprovalEntryNotification(ApprovalEntryToUpdate, WorkflowStepInstance);
            until ApprovalEntry.Next = 0;
    end;

}