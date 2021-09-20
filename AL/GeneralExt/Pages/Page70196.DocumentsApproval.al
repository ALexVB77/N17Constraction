page 70196 "Documents Approval"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Invoices (Approval)';
    DataCaptionFields = "Document Type";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    RefreshOnActivate = true;
    SourceTable = "Purchase Header";
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            group(Filters)
            {
                ShowCaption = false;
                field(ShowCancel; ShowCancel)
                {
                    ApplicationArea = All;
                    Caption = 'Show Rejected';

                    trigger OnValidate()
                    begin
                        // NC AB >>
                        // FILTERGROUP(2);
                        // IF ShowCancel THEN
                        //     SETRANGE("Status App")
                        // ELSE
                        //     SETFILTER("Status App", '<>%1', "Status App"::Cancelled);
                        // FILTERGROUP(0);
                        // NC AB <<
                        SetRecFilters;
                        CurrPage.UPDATE;
                    end;
                }
                field(cFilter1; Filter1)
                {
                    ApplicationArea = All;
                    Caption = 'Scope';
                    OptionCaption = 'My documents,Pre-Approver,All documents';

                    trigger OnValidate()
                    var
                        LocText001: Label 'You cannot use "All documents" value if %1 %2 = %3.';
                    begin
                        grUserSetup.GET(USERID);
                        if (grUserSetup."Status App" = grUserSetup."Status App"::Checker) and (Filter1 = Filter1::All) then
                            Error(LocText001, grUserSetup.TableCaption, grUserSetup.FieldCaption("Status App"), grUserSetup."Status App");
                        SetRecFilters;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
                field(Selection; Filter2)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Selection';
                    OptionCaption = 'All documents,Documents in processing,Ready-to-pay documents,Paid documents,Problem documents';

                    trigger OnValidate()
                    begin
                        SetRecFilters;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
                field("Sorting"; SortType)
                {
                    ApplicationArea = All;
                    Caption = 'Sorting';
                    OptionCaption = 'Document No.,Postng Date,Buy-from Vendor Name,Status App,Process User';

                    trigger OnValidate()
                    begin
                        SetSortType;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
            }

            repeater(Repeater12370003)
            {
                Editable = false;
                field("Problem Document"; Rec."Problem Document")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        PurchHeader: Record "Purchase Header";
                    begin
                        PurchHeader.SetRange("No.", Rec."No.");
                        page.Runmodal(Page::"Payment Request Card", PurchHeader);
                        CurrPage.Update(false);
                    end;
                }
                field("Vendor Invoice No."; "Vendor Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Pay-to Name"; Rec."Pay-to Name")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = All;
                }
                field("Paid Date Fact"; "Paid Date Fact")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; Rec.GetInvoiceAmountsLCY(AmountType::"Include VAT"))
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Amount Inv. VAT (LCY)';
                }
                field("Status App"; Rec."Status App")
                {
                    ApplicationArea = All;
                    Caption = 'Approval Status';
                    OptionCaption = ' ,Reception,Сontroller,Checker,Approve,Payment';
                }
                field("Date Status App"; Rec."Date Status App")
                {
                    ApplicationArea = All;
                }
                field("Process User"; Rec."Process User")
                {
                    ApplicationArea = All;
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Exists Comment"; Rec."Comment")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewDoc)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'View';
                Image = View;
                RunObject = Page "Payment Request Card";
                RunPageLink = "No." = field("No.");
            }
            action(DocCard)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                RunObject = Page "Purchase Order App";
                RunPageLink = "No." = FIELD("No.");
            }
            action(ApproveButton)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approve';
                Enabled = ApproveButtonEnabled;
                Image = Approve;

                trigger OnAction()
                begin
                    MessageIfPurchLinesNotExist;
                    if not ("Status App" in ["Status App"::Checker, "Status App"::Approve]) then
                        FieldError("Status App");
                    ApprovalsMgmt.ApproveRecordApprovalRequest(RECORDID);
                    CurrPage.Update(false);
                end;
            }
            action(RejectButton)
            {
                ApplicationArea = All;
                Caption = 'Reject';
                Enabled = RejectButtonEnabled;
                Image = Reject;

                trigger OnAction()
                begin
                    if not ("Status App" in ["Status App"::Approve]) then
                        FieldError("Status App");
                    ApprovalsMgmtExt.RejectPurchActAndPayInvApprovalRequest(RECORDID);
                    CurrPage.Update(false);
                end;
            }
            action(Delegate)
            {
                ApplicationArea = Suite;
                Caption = 'Delegate';
                Enabled = DelegateButtonEnabled;
                Image = Delegate;

                trigger OnAction()
                begin
                    if not ("Status App" in ["Status App"::Approve]) then
                        FieldError("Status App");
                    ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(Vendor)
            {
                ApplicationArea = Suite;
                Caption = 'Vendor';
                Enabled = "Buy-from Vendor No." <> '';
                Image = Vendor;
                RunObject = Page "Vendor Card";
                RunPageLink = "No." = FIELD("Buy-from Vendor No."),
                                  "Date Filter" = FIELD("Date Filter");
                ShortCutKey = 'Shift+F7';
            }
            action(Dimensions)
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Dimensions';
                Image = Dimensions;
                ShortCutKey = 'Alt+D';

                trigger OnAction()
                begin
                    ShowDocDim;
                    CurrPage.SaveRecord;
                end;
            }
            action("Co&mments")
            {
                ApplicationArea = All;
                Caption = 'Co&mments';
                Image = ViewComments;
                RunObject = Page "Purch. Comment Sheet";
                RunPageLink = "Document Type" = const(Order),
                                "No." = FIELD("No."),
                                "Document Line No." = CONST(0);
            }
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        PurchSetup.Get();
        // NC AB >>
        // PurchSetup.TestField("Payment Calendar Tmpl");
        // PurchSetup.TestField("Payment Calendar Batch");
        // NC AB <<

        FILTERGROUP(2);
        // NC AB >>
        // SETRANGE("Journal Template Name", PurchSetup."Payment Calendar Tmpl");
        // SETRANGE("Journal Batch Name", PurchSetup."Payment Calendar Batch");
        // SETFILTER("Status App", '<>%1', "Status App"::Cancelled);
        ShowCancel := false;
        // NC AB <<
        FILTERGROUP(0);

        Filter2 := Filter2::InProc;

        SetSortType;
        SetRecFilters;

        grUserSetup.GET(USERID);
    end;

    trigger OnAfterGetRecord()
    begin
        ApproveButtonEnabled := false;
        RejectButtonEnabled := false;
        DelegateButtonEnabled := false;

        if ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId) then begin
            ApproveButtonEnabled := "Status App" in ["Status App"::Checker, "Status App"::Approve];
            RejectButtonEnabled := "Status App" in ["Status App"::Approve];
            DelegateButtonEnabled := RejectButtonEnabled;
        end;
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        grUserSetup: Record "User Setup";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ApprovalsMgmtExt: Codeunit "Approvals Mgmt. (Ext)";
        Filter1: option MyDoc,Pre,All;
        Filter2: option All,InProc,Ready,Pay,Problem;
        SortType: option DocNo,PostDate,Vendor,StatusApp,UserProc;
        ShowCancel: Boolean;
        AmountType: Enum "Amount Type";
        ApproveButtonEnabled, RejectButtonEnabled, DelegateButtonEnabled : Boolean;

    local procedure SetRecFilters()
    var
        PaymentOrderMgt: Codeunit "Payment Order Management";
        SaveRec: Record "Purchase Header";
    begin
        SaveRec := Rec;

        FILTERGROUP(2);

        // NC AB >>
        // SETRANGE("Pre-Approver");
        MarkedOnly(false);
        ClearMarks();
        // NC AB <<
        SETRANGE("Process User");
        SETRANGE("Status App");
        // NC AB >>
        // IF NOT ShowCancel THEN
        //     SETFILTER("Status App", '<>%1', "Status App"::Cancelled);
        if not ShowCancel then
            SetFilter("Status App", '>=%1', "Status App"::Approve);
        // NC AB <<    
        SETRANGE("Problem Document");
        // SETRANGE(Paid);

        CASE Filter2 OF
            Filter2::InProc:
                // NC AB >>
                // IF NOT ShowCancel THEN
                //     SETFILTER("Status App", '<>%1&<>%2', "Status App"::Payment, "Status App"::Cancelled)
                // ELSE
                //     SETFILTER("Status App", '<>%1', "Status App"::Payment);
                if not ShowCancel then
                    SetFilter("Status App", '>=%1', "Status App"::Approve)
                else begin
                    SetFilter("Status App", '>=%1', "Status App"::Checker);
                    if FindSet() then begin
                        repeat
                            if "Status App" = "Status App"::Checker then
                                Mark("Problem Document")
                            else
                                Mark(true);
                        until Next() = 0;
                        MarkedOnly(true);
                    end;
                end;
            // NC AB <<
            Filter2::Ready:
                BEGIN
                    SETRANGE("Status App", "Status App"::Payment);
                    // SETRANGE(Paid, FALSE);
                    if not IsEmpty then begin
                        FindSet();
                        repeat
                            CalcFields("Payments Amount");
                            if "Payments Amount" < "Invoice Amount Incl. VAT" then
                                Mark(true);
                        until Next() = 0;
                        MarkedOnly(true);
                    end;
                END;
            Filter2::Pay:
                // SETRANGE(Paid, TRUE);
                if not IsEmpty then begin
                    FindSet();
                    repeat
                        CalcFields("Payments Amount");
                        if "Payments Amount" >= "Invoice Amount Incl. VAT" then
                            Mark(true);
                    until Next() = 0;
                    MarkedOnly(true);
                end;
            Filter2::Problem:
                SETRANGE("Problem Document", TRUE);
        END;

        CASE Filter1 OF
            Filter1::MyDoc:
                SETRANGE("Process User", USERID);
            Filter1::Pre:
                // NC AB >>
                // SETRANGE("Pre-Approver", USERID);
                if FindSet() then begin
                    repeat
                        Mark(PaymentOrderMgt.GetPurchActPreApproverFromDim("Dimension Set ID") = UserId);
                    until Next() = 0;
                    MarkedOnly(true);
                end;
        // NC AB <<
        END;

        FILTERGROUP(0);

        Rec := SaveRec;
        if find('=<>') then;
    end;

    procedure SetSortType()
    begin
        CASE SortType OF
            SortType::DocNo:
                SETCURRENTKEY("No.");
            SortType::PostDate:
                SETCURRENTKEY("Posting Date");
            SortType::Vendor:
                SETCURRENTKEY("Buy-from Vendor Name");
            SortType::StatusApp:
                SETCURRENTKEY("Status App");
            SortType::UserProc:
                SETCURRENTKEY("Process User");
        END;
    end;
}
