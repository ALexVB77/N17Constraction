page 71002 "Purchase List App Archive"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Invoices (Archive)';
    DataCaptionFields = "Document Type";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    RefreshOnActivate = true;
    SourceTable = "Purchase Header Archive";
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            group(Filters)
            {
                ShowCaption = false;
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
                field(Selection; Filter2)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Selection';
                    OptionCaption = 'All documents,Documents in processing,Ready-to-pay documents,Paid documents';

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
                        PurchHeaderArch: Record "Purchase Header Archive";
                    begin
                        PurchHeaderArch.SetRange("No.", Rec."No.");
                        PurchHeaderArch.SetRange("Version No.", Rec."Version No.");
                        PurchHeaderArch.SetRange("Doc. No. Occurrence", Rec."Doc. No. Occurrence");
                        page.Run(Page::"Purchase Order App Archive", Rec);
                        CurrPage.Update(false);
                    end;
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Paid Date Fact"; Rec."Paid Date Fact")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field("Invoice Amount Incl. VAT"; Rec."Invoice Amount Incl. VAT")
                {
                    ApplicationArea = All;
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
                field("Exists Attachment"; Rec."Exists Attachment")
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
            action(DocCard)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Enabled = EditEnabled;
                Image = Edit;
                RunObject = Page "Purchase Order App Archive";
                RunPageLink = "No." = field("No."), "Version No." = field("Version No."), "Doc. No. Occurrence" = field("Doc. No. Occurrence");
            }
        }
        area(Navigation)
        {
            action("Co&mments")
            {
                ApplicationArea = All;
                Caption = 'Co&mments';
                Image = ViewComments;
                RunObject = Page "Purch. Archive Comment Sheet";
                RunPageLink = "Document Type" = FIELD("Document Type"),
                            "No." = FIELD("No."),
                            "Document Line No." = CONST(0),
                            "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"),
                            "Version No." = FIELD("Version No.");
                ;
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
        grUserSetup.GET(USERID);

        IF grUserSetup."Show All Pay Inv" AND (Filter1 = Filter1::mydoc) THEN
            Filter1 := Filter1::all;

        FILTERGROUP(2);
        SETRANGE("IW Documents", TRUE);
        SETFILTER("Act Type", '%1', "Act Type"::" ");
        FILTERGROUP(0);

        SetSortType;
        SetRecFilters;

        Filter1Enabled := true;
        IF grUserSetup."Status App" = grUserSetup."Status App"::Checker THEN
            Filter1Enabled := FALSE;
        IF grUserSetup."Administrator IW" THEN
            Filter1Enabled := TRUE;
    end;

    trigger OnAfterGetRecord()
    begin
        EditEnabled := Rec."No." <> '';
    end;

    var
        grUserSetup: Record "User Setup";
        Filter1: option mydoc,all,approved;
        Filter1Enabled: Boolean;
        Filter2: option all,inproc,ready,pay;
        SortType: option docno,postdate,vendor,statusapp,userproc;
        EditEnabled: Boolean;

    local procedure SetRecFilters()
    var
        SaveRec: Record "Purchase Header Archive";
    begin
        SaveRec := Rec;

        FILTERGROUP(2);

        SETRANGE("Process User");
        SETRANGE("Status App");
        SETRANGE("Problem Document");
        // SETRANGE(Paid);
        MarkedOnly(false);
        ClearMarks();

        SetRange("My Approved");
        SetRange("Approver ID Filter");

        SETFILTER("Status App", '<>%1&<>%2', "Status App"::Payment, "Status App"::Request);

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

        FILTERGROUP(0);

        Rec := SaveRec;
        if find('=<>') then;
    end;

    procedure SetSortType()
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

}
