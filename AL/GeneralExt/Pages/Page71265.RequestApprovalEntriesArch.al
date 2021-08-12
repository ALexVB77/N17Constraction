page 71265 "Request Approval Entries Arch."
{
    ApplicationArea = Suite;
    Caption = 'Approval Entries Archive';
    Editable = false;
    PageType = List;
    SourceTable = "Request Approval Entry Archive";
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
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the ID of the table where the record that is subject to approval is stored.';
                    Visible = false;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the type of document that an approval entry has been created for. Approval entries can be created for six different types of sales or purchase documents:';
                    Visible = false;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the document number copied from the relevant sales or purchase document, such as a purchase order or a sales quote.';
                    Visible = false;
                }
                field(RecordIDText; RecordIDText)
                {
                    ApplicationArea = Suite;
                    Caption = 'To Approve';
                    ToolTip = 'Specifies the record that you are requested to approve.';
                }
                field("Sequence No."; "Sequence No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the order of approvers when an approval workflow involves more than one approver.';
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
                field(Comment; Comment)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies whether there are comments relating to the approval of the record. If you want to read the comments, choose the field to open the Approval Comment Sheet window.';
                }
                field("Status App Act"; "Status App Act")
                {
                    ApplicationArea = All;
                }
                field("Status App"; "Status App")
                {
                    ApplicationArea = All;
                }
                field("Preliminary Approval"; "Preliminary Approval")
                {
                    ApplicationArea = All;
                }
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
                    // Enabled = ShowRecCommentsEnabled;
                    Enabled = false;
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
                    // Enabled = ShowRecCommentsEnabled;
                    Enabled = false;
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
                        //ApprovalsMgmt.GetApprovalCommentForWorkflowStepInstanceID(RecRef, "Workflow Step Instance ID");
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RecRef: RecordRef;
    begin
        ShowRecCommentsEnabled := RecRef.Get("Record ID to Approve");
    end;

    trigger OnAfterGetRecord()
    begin
        RecordIDText := Format("Record ID to Approve", 0, 1);
    end;

    var
        RecordIDText: Text;
        ShowRecCommentsEnabled: Boolean;

    procedure Setfilters(
        TableId: Integer; DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; DocumentNo: Code[20];
        DocNoOccurrence: Integer; VerionNo: Integer)
    begin
        if TableId <> 0 then begin
            FilterGroup(2);
            SetCurrentKey("Table ID", "Document Type", "Document No.", "Date-Time Sent for Approval");
            SetRange("Table ID", TableId);
            SetRange("Document Type", DocumentType);
            SetRange("Doc. No. Occurrence", DocNoOccurrence);
            SetRange("Version No.", VerionNo);
            if DocumentNo <> '' then
                SetRange("Document No.", DocumentNo);
            FilterGroup(0);
        end;
    end;
}

