page 70262 "Purchase List Act"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Orders List';
    InsertAllowed = false;
    DeleteAllowed = false;
    DataCaptionFields = "Document Type";
    PageType = Worksheet;
    RefreshOnActivate = true;
    SourceTable = "Purchase Header";
    SourceTableView = SORTING("Document Type", "No.") WHERE("Act Type" = FILTER(<> ' '), "Status App" = FILTER(<> Payment)/*, "Problem Type" = FILTER(<> "Act error")*/);
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            group(Filters)
            {
                ShowCaption = false;
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
                field(cFilter1; Filter1)
                {
                    ApplicationArea = All;
                    Caption = 'Scope';
                    Enabled = Filter1Enabled;
                    OptionCaption = 'My documents,All documents,My Approved';
                    trigger OnValidate()
                    begin
                        SetRecFilters;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
                field(FilterActType; FilterActType)
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                    OptionCaption = 'All,Act,KC-2,Advance';
                    trigger OnValidate()
                    begin
                        SetRecFilters;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
            }

            repeater(Repeater1237120003)
            {
                Editable = false;
                field("Problem Document"; Rec."Problem Document")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        PurchHeader: Record "Purchase Header";
                    begin
                        PurchHeader.SetRange("No.", Rec."No.");
                        page.Run(Page::"Purchase Order Act", Rec);
                        CurrPage.Update(false);
                    end;
                }
                field("Act Type"; "Act Type")
                {
                    ApplicationArea = All;
                }
                field("Approver"; PaymentOrderMgt.GetPurchActApproverFromDim("Dimension Set ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Approver';
                    Editable = false;
                }
                field("Act Invoice No."; "Act Invoice No.")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        PurchaseHeader: record "Purchase Header";
                        PurchInvHeader: record "Purch. Inv. Header";
                    begin
                        if "Act Invoice No." = '' then
                            exit;
                        if not "Act Invoice Posted" then begin
                            PurchaseHeader.Get("Document Type"::Invoice, "Act Invoice No.");
                            PurchaseHeader.SetRange("Document Type", "Document Type"::Invoice);
                            PurchaseHeader.SetRange("No.", "Act Invoice No.");
                            Page.Run(Page::"Purchase Invoice", PurchaseHeader);
                        end else begin
                            PurchInvHeader.Get("Act Invoice No.");
                            PurchInvHeader.SetRange("No.", "Act Invoice No.");
                            Page.Run(Page::"Posted Purchase Invoice", PurchInvHeader);
                        end;
                    end;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Invoice No."; "Vendor Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; "Document Date")
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
                field("Invoice Amount Incl. VAT"; "Invoice Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Статус утверждения"; "Status App Act")
                {
                    ApplicationArea = All;
                }
                field("Date Status App"; "Date Status App")
                {
                    ApplicationArea = All;
                }
                field("Process User"; "Process User")
                {
                    ApplicationArea = All;
                }
                field("Agreement No."; "Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Exists Comment"; Comment)
                {
                    Caption = 'Exists Comment';
                    ApplicationArea = All;
                }
                field("Exists Attachment"; "Exists Attachment")
                {
                    ApplicationArea = All;
                }
                field("Receive Account"; "Receive Account")
                {
                    ApplicationArea = All;
                }
                field("Location Document"; "Location Document")
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
            group(New)
            {
                Caption = 'New';
                Image = NewDocument;
                action(NewAct)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Act';
                    Enabled = NewActEnabled;
                    trigger OnAction()
                    begin
                        PaymentOrderMgt.FuncNewRec(NewActTypeOption::Act);
                    end;
                }
                action(NewKC2)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'KC-2';
                    Enabled = NewKC2Enabled;
                    trigger OnAction()
                    begin
                        PaymentOrderMgt.FuncNewRec(NewActTypeOption::"KC-2");
                    end;
                }
                action(NewAdvance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Advance';
                    Enabled = NewAdvanceEnabled;
                    trigger OnAction()
                    begin
                        PaymentOrderMgt.FuncNewRec(NewActTypeOption::Advance);
                    end;
                }
            }
            action(DocCard)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                Enabled = EditEnabled;
                RunObject = Page "Purchase Order Act";
                RunPageLink = "No." = field("No.");
            }
            action(ViewAttachDoc)
            {
                ApplicationArea = All;
                Caption = 'Documents View';
                Enabled = ShowDocEnabled;
                Image = Export;

                trigger OnAction()
                begin
                    ViewAttachDocument();
                end;
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
                    if "Status App Act" in ["Status App Act"::" ", "Status App Act"::Accountant] then
                        FieldError("Status App Act");
                    if "Status App Act" = "Status App Act"::Controller then begin
                        IF ApprovalsMgmt.CheckPurchaseApprovalPossible(Rec) THEN
                            ApprovalsMgmt.OnSendPurchaseDocForApproval(Rec);
                    end else
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
                    if "Status App Act" in ["Status App Act"::" ", "Status App Act"::Controller, "Status App Act"::Accountant] then
                        FieldError("Status App Act");
                    ApprovalsMgmtExt.RejectPurchActAndPayInvApprovalRequest(RECORDID);
                    CurrPage.Update(false);
                end;
            }
            action(ArchiveProblemDoc)
            {
                ApplicationArea = Suite;
                Caption = 'Archive Problem Document';
                Enabled = "No." <> '';
                Image = Archive;

                trigger OnAction()
                begin
                    if PaymentOrderMgt.PurchOrderActArchiveQstNew(Rec) then
                        CurrPage.Close();
                end;
            }
        }
        area(Navigation)
        {
            action("Co&mments")
            {
                ApplicationArea = All;
                Caption = 'Co&mments';
                Image = ViewComments;
                RunObject = Page "Purch. Comment Sheet";
                RunPageLink = "Document Type" = FIELD("Document Type"),
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
            action(PaymentInvoices)
            {
                ApplicationArea = All;
                Caption = 'Payment Invoices';
                Image = Payment;
                RunObject = Page "Purch. Order Act PayReq. List";
                RunPageLink = "Document Type" = CONST(Order),
                                "IW Documents" = CONST(true),
                                "Linked Purchase Order Act No." = field("No.");
            }
        }
    }

    trigger OnOpenPage()
    begin
        UserSetup.GET(USERID);

        IF UserSetup."Show All Acts KC-2" AND (Filter1 = Filter1::mydoc) THEN
            Filter1 := Filter1::all;

        SetSortType;
        SetRecFilters;

        Filter1Enabled := true;
        IF UserSetup."Status App Act" = UserSetup."Status App Act"::Checker THEN
            Filter1Enabled := FALSE;
        IF UserSetup."Administrator IW" THEN
            Filter1Enabled := TRUE;
    end;

    trigger OnAfterGetRecord()
    begin
        ApproveButtonEnabled := FALSE;
        RejectButtonEnabled := FALSE;

        EditEnabled := Rec."No." <> '';

        if (UserId = Rec.Controller) and (Rec."Status App Act" = Rec."Status App Act"::Controller) then
            ApproveButtonEnabled := true;
        if ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId) then begin
            ApproveButtonEnabled := true;
            RejectButtonEnabled := true;
        end;

        CalcFields("Exists Attachment");
        ShowDocEnabled := "Exists Attachment";
    end;

    var
        UserSetup: record "User Setup";
        PaymentOrderMgt: Codeunit "Payment Order Management";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ApprovalsMgmtExt: Codeunit "Approvals Mgmt. (Ext)";
        Filter1: option mydoc,all,approved;
        Filter1Enabled: Boolean;
        Filter2: option all,inproc,ready,pay,problem;
        SortType: option docno,postdate,vendor,statusapp,userproc;
        FilterActType: option all,act,"kc-2",advance;
        NewActTypeOption: Enum "Purchase Act Type";
        ApproveButtonEnabled, RejectButtonEnabled : boolean;
        MyApproved: boolean;
        NewActEnabled, NewKC2Enabled, NewAdvanceEnabled : Boolean;
        EditEnabled, ShowDocEnabled : Boolean;

    local procedure SetSortType()
    begin
        CASE SortType OF
            SortType::DocNo:
                SETCURRENTKEY("Document Type", "No.");
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

    local procedure SetRecFilters()
    var
        SaveRec: Record "Purchase Header";
    begin
        SaveRec := Rec;

        FILTERGROUP(2);

        SETRANGE("Process User");
        SETRANGE("Status App");
        SETRANGE("Problem Document");
        // SETRANGE(Paid);
        SetRange("My Approved");
        SETRANGE("Act Type");

        MarkedOnly(false);
        ClearMarks();

        CASE Filter2 OF
            Filter2::InProc:
                SETFILTER("Status App", '<>%1', "Status App"::Payment);
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
            Filter1::Approved:
                BEGIN
                    SetRange("Approver ID Filter", UserId);
                    SetRange("My Approved", true);
                END;
        END;

        CASE FilterActType OF
            FilterActType::Act:
                SETRANGE("Act Type", "Act Type"::Act);
            FilterActType::"KC-2":
                SETRANGE("Act Type", "Act Type"::"KC-2");
            FilterActType::All:
                SETFILTER("Act Type", '%1|%2|%3', "Act Type"::Act, "Act Type"::"KC-2", "Act Type"::Advance);
            FilterActType::Advance:
                SETRANGE("Act Type", "Act Type"::Advance);
        END;

        FILTERGROUP(0);

        NewActEnabled := FilterActType in [FilterActType::All, FilterActType::act];
        NewKC2Enabled := FilterActType in [FilterActType::All, FilterActType::"kc-2"];
        NewAdvanceEnabled := FilterActType in [FilterActType::All, FilterActType::advance];

        Rec := SaveRec;
        if find('=<>') then;
    end;

}