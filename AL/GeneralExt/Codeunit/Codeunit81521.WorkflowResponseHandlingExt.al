codeunit 81521 "Workflow Response Handling Ext"
{
    Permissions = TableData "Sales Header" = rm,
                  TableData "Purchase Header" = rm,
                  TableData "Notification Entry" = imd;

    trigger OnRun()
    begin
    end;

    // [EventSubscriber(ObjectType::Table, 1523, 'OnAfterInsertEvent', '', false, false)]
    // local procedure OnWorkflowStepAfterInsert(Rec: Record "Workflow Step Argument"; RunTrigger: boolean)
    // begin
    // end;

    [EventSubscriber(ObjectType::Codeunit, 1521, 'OnExecuteWorkflowResponse', '', false, false)]
    local procedure OnExecuteWorkflowResponse(var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
        if not WorkflowResponse.GET(ResponseWorkflowStepInstance."Function Name") THEN
            exit;
        case WorkflowResponse."Function Name" of
            CreateApprovalRequestsActCode:
                CreateApprovalRequestsAct(Variant, ResponseWorkflowStepInstance);
            MoveToNextActStatusCode:
                MoveToNextActStatus(Variant, ResponseWorkflowStepInstance);
            MoveToPrevActStatusCode:
                MoveToPrevActStatus(Variant, ResponseWorkflowStepInstance);
            DelegateApprovalRequestsActCode:
                DelegateApprovalRequestsAct(Variant, ResponseWorkflowStepInstance);
            else
                exit;
        end;
        ResponseExecuted := true;
    end;

    local procedure CreateApprovalRequestsAct(Variant: Variant; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ApprovalsMgmtExt: Codeunit "Approvals Mgmt. (Ext)";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);
        ApprovalsMgmtExt.CreateApprovalRequestsPurchActAndPayInv(RecRef, WorkflowStepInstance);
    end;

    local procedure MoveToNextActStatus(Variant: Variant; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ApprovalsMgmtExt: Codeunit "Approvals Mgmt. (Ext)";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);
        ApprovalsMgmtExt.MoveToNextPurchActAndPayInvStatus(RecRef, WorkflowStepInstance, false);
    end;

    local procedure MoveToPrevActStatus(Variant: Variant; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ApprovalsMgmtExt: Codeunit "Approvals Mgmt. (Ext)";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);
        ApprovalsMgmtExt.MoveToNextPurchActAndPayInvStatus(RecRef, WorkflowStepInstance, true);
    end;

    local procedure DelegateApprovalRequestsAct(Variant: Variant; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ApprovalsMgmtExt: Codeunit "Approvals Mgmt. (Ext)";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);
        ApprovalsMgmtExt.DelegateApprovalRequestsPurchActAndPayInv(RecRef, WorkflowStepInstance);
    end;

    procedure CreateApprovalRequestsActCode(): Code[128]
    begin
        exit(UpperCase('CreateApprovalRequestsAct'));
    end;

    procedure MoveToNextActStatusCode(): Code[128]
    begin
        exit(UpperCase('MoveToNextActStatus'));
    end;

    procedure MoveToPrevActStatusCode(): Code[128]
    begin
        exit(UpperCase('MoveToPrevActStatus'));
    end;

    procedure DelegateApprovalRequestsActCode(): Code[128]
    begin
        exit(UpperCase('DelegateApprovalRequestsAct'));
    end;

}