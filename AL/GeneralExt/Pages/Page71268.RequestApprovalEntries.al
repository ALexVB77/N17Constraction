page 71268 "Request Approval Entries"
{
    ApplicationArea = Suite;
    Caption = 'Request Approval Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Approval Entry";
    SourceTableView = SORTING("Table ID", "Document Type", "Document No.", "Date-Time Sent for Approval")
                      ORDER(Ascending);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Sequence No."; "Sequence No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the order of approvers when an approval workflow involves more than one approver.';
                }
                field("Status App"; "Status App")
                {
                    ApplicationArea = All;
                }
                field("Status App Act"; "Status App Act")
                {
                    ApplicationArea = All;
                }
                field("Approver ID"; "Approver ID")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the ID of the user who must approve the document.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation("Approver ID");
                    end;
                }
                field(Status; Status)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the approval status for the entry:';
                }
                field("Sender ID"; "Sender ID")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the ID of the user who sent the approval request for the document to be approved.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation("Sender ID");
                    end;
                }
                field("Delegated From Approver ID"; "Delegated From Approver ID")
                {
                    ApplicationArea = All;
                    Caption = 'Delegated From Approver ID';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation("Delegated From Approver ID");
                    end;
                }
                field("Preliminary Approval"; "Preliminary Approval")
                {
                    ApplicationArea = All;
                }
                field("Date-Time Sent for Approval"; "Date-Time Sent for Approval")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date and the time that the document was sent for approval.';
                }
                field("Last Date-Time Modified"; "Last Date-Time Modified")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date when the approval entry was last modified. If, for example, the document approval is canceled, this field will be updated accordingly.';
                }
                field("Last Modified By User ID"; "Last Modified By User ID")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the ID of the user who last modified the approval entry. If, for example, the document approval is canceled, this field will be updated accordingly.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation("Last Modified By User ID");
                    end;
                }
                field(RecordIDText; RecordIDText)
                {
                    ApplicationArea = Suite;
                    Caption = 'To Approve';
                    ToolTip = 'Specifies the record that you are requested to approve.';
                }
                field(Details; RecordDetails2)
                {
                    ApplicationArea = Suite;
                    Caption = 'Details';
                    ToolTip = 'Specifies the record that the approval is related to.';
                }
                field("Salespers./Purch. Code"; "Salespers./Purch. Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the salesperson or purchaser that was in the document to be approved. It is not a mandatory field, but is useful if a salesperson or a purchaser responsible for the customer/vendor needs to approve the document before it is processed.';
                }
                field(Overdue; Overdue)
                {
                    ApplicationArea = Suite;
                    Caption = 'Overdue';
                    Editable = false;
                    ToolTip = 'Specifies that the approval is overdue.';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies when the record must be approved, by one or more approvers.';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies whether there are comments relating to the approval of the record. If you want to read the comments, choose the field to open the Approval Comment Sheet window.';
                }
            }
        }
        area(factboxes)
        {
            part(Change; "Workflow Change List FactBox")
            {
                ApplicationArea = Suite;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                UpdatePropagation = SubPart;
                Visible = ShowChangeFactBox;
            }
            systempart(Control5; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control4; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Show")
            {
                Caption = '&Show';
                Image = View;
                action("Record")
                {
                    ApplicationArea = Suite;
                    Caption = 'Record';
                    Enabled = ShowRecCommentsEnabled;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Open the document, journal line, or card that the approval request is for.';

                    trigger OnAction()
                    begin
                        ShowRecord;
                    end;
                }
                action(Comments)
                {
                    ApplicationArea = Suite;
                    Caption = 'Comments';
                    Enabled = ShowRecCommentsEnabled;
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'View or add comments for the record.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        RecRef: RecordRef;
                    begin
                        RecRef.Get("Record ID to Approve");
                        Clear(ApprovalsMgmt);
                        ApprovalsMgmt.GetApprovalCommentForWorkflowStepInstanceID(RecRef, "Workflow Step Instance ID");
                    end;
                }
                action("O&verdue Entries")
                {
                    ApplicationArea = Suite;
                    Caption = 'O&verdue Entries';
                    Image = OverdueEntries;
                    ToolTip = 'View approval requests that are overdue.';

                    trigger OnAction()
                    begin
                        SetFilter(Status, '%1|%2', Status::Created, Status::Open);
                        SetFilter("Due Date", '<%1', Today);
                    end;
                }
                action("All Entries")
                {
                    ApplicationArea = Suite;
                    Caption = 'All Entries';
                    Image = Entries;
                    ToolTip = 'View all approval entries.';

                    trigger OnAction()
                    begin
                        SetRange(Status);
                        SetRange("Due Date");
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Delegate")
            {
                ApplicationArea = Suite;
                Caption = '&Delegate';
                // Enabled = DelegateEnable;
                Enabled = false;
                Image = Delegate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Delegate the approval request to another approver that has been set up as your substitute approver.';

                trigger OnAction()
                var
                    ApprovalEntry: Record "Approval Entry";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    CurrPage.SetSelectionFilter(ApprovalEntry);
                    ApprovalsMgmt.DelegateApprovalRequests(ApprovalEntry);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RecRef: RecordRef;
    begin
        ShowChangeFactBox := CurrPage.Change.PAGE.SetFilterFromApprovalEntry(Rec);
        DelegateEnable := CanCurrentUserEdit;
        ShowRecCommentsEnabled := RecRef.Get("Record ID to Approve");
    end;

    trigger OnAfterGetRecord()
    begin
        Overdue := Overdue::" ";
        if FormatField(Rec) then
            Overdue := Overdue::Yes;

        RecordIDText := Format("Record ID to Approve", 0, 1);
    end;

    trigger OnOpenPage()
    begin
        // MarkAllWhereUserisApproverOrSender;
    end;

    var
        Overdue: Option Yes," ";
        RecordIDText: Text;
        ShowChangeFactBox: Boolean;
        DelegateEnable: Boolean;
        ShowRecCommentsEnabled: Boolean;
        RecNotExistTxt: Label 'The record does not exist.';

    procedure Setfilters(TableId: Integer; DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; DocumentNo: Code[20])
    begin
        if TableId <> 0 then begin
            FilterGroup(2);
            SetCurrentKey("Table ID", "Document Type", "Document No.", "Date-Time Sent for Approval");
            SetRange("Table ID", TableId);
            SetRange("Document Type", DocumentType);
            if DocumentNo <> '' then
                SetRange("Document No.", DocumentNo);
            FilterGroup(0);
        end;
    end;

    local procedure FormatField(ApprovalEntry: Record "Approval Entry"): Boolean
    begin
        if Status in [Status::Created, Status::Open] then begin
            if ApprovalEntry."Due Date" < Today then
                exit(true);

            exit(false);
        end;
    end;

    procedure CalledFrom()
    begin
        Overdue := Overdue::" ";
    end;

    procedure RecordDetails2() Details: Text
    var
        PurchHeader: Record "Purchase Header";
        RecRef: RecordRef;
    begin
        if not RecRef.Get("Record ID to Approve") then
            exit(RecNotExistTxt);
        RecRef.SetTable(PurchHeader);
        Details := PurchHeader."Buy-from Vendor Name";
    end;
}

