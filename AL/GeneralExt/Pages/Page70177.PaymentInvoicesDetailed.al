page 70177 "Payment Invoices Detailed"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Invoices Detailed';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    RefreshOnActivate = true;
    SourceTable = "Purchase Line";
    SourceTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = FILTER(<> ' '));
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            group(Filters)
            {
                ShowCaption = false;
                field(cFilter1; Filter4)
                {
                    ApplicationArea = All;
                    Caption = 'Scope';
                    OptionCaption = 'My documents (Approver),My documents  (Checker),All documents';
                    trigger OnValidate()
                    var
                        LocText001: Label 'You cannot use "All documents" value if %1 %2 = %3 and %4 = %5.';
                    begin
                        grUserSetup.GET(USERID);
                        if Filter4 = Filter4::All then
                            if not ((grUserSetup."Status App" = grUserSetup."Status App"::Controller) or grUserSetup."Administrator IW") then
                                Error(LocText001,
                                    grUserSetup.TableCaption, grUserSetup.FieldCaption("Status App"), grUserSetup."Status App",
                                    grUserSetup.FieldCaption("Administrator IW"), grUserSetup."Administrator IW");
                        SetRecFilters;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
                field(Selection; Filter3)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Selection';
                    OptionCaption = 'Ready to pay,Paid,Payment,Overdue,All';
                    trigger OnValidate()
                    begin
                        SetRecFilters;
                        CurrPage.UPDATE(FALSE);
                    end;
                }

            }
            repeater(Repeater12370003)
            {
                Editable = false;
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Vendor Invoice No."; "Vendor Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
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
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Agreement No."; "Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("External Agreement No."; "External Agreement No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Status App"; "Status App")
                {
                    ApplicationArea = All;
                }
                field("Process User"; "Process User")
                {
                    ApplicationArea = All;
                }
                field(Comments; Comments)
                {
                    ApplicationArea = All;
                    Caption = 'Contains a comment';
                }
                field(Attachments; Attachments)
                {
                    ApplicationArea = All;
                    Caption = 'Contains a attachment';
                }
                field(Paid; PurchHeader.GetPaymentInvPaidStatus())
                {
                    ApplicationArea = All;
                }
                field("Paid Date Fact"; "Paid Date Fact")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; "Due Date")
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
                Image = Edit;
                RunObject = Page "Purchase Order App";
                RunPageLink = "No." = field("Document No.");
            }
        }
    }

    trigger OnOpenPage()
    begin
        Filter3 := Filter3::All;
        grUserSetup.GET(USERID);
        SetRecFilters;
    end;

    trigger OnAfterGetRecord()
    begin
        if Not PurchHeader.Get("Document Type", "Document No.") then
            PurchHeader.Init();
    end;

    var
        grUserSetup: Record "User Setup";
        PurchHeader: Record "Purchase Header";
        Filter3: Option Ready,Paid,Payment,Overdue,All;
        Filter4: Option MyDocA,MyDocC,All;
        Comments: Boolean;
        Attachments: Boolean;

    local procedure SetRecFilters()
    var
        LineHeader: Record "Purchase Header";
        SaveRec: Record "Purchase Line";
    begin
        SaveRec := Rec;

        begin
            FILTERGROUP(2);

            SETRANGE("Status App");
            // SETRANGE(Paid);
            MarkedOnly(false);
            ClearMarks();
            SETRANGE("Due Date");
            SETRANGE("Process User");
            SETRANGE("Purchaser Code");

            CASE Filter3 OF
                Filter3::Ready:
                    BEGIN
                        SETRANGE("Status App", "Status App"::Payment);
                        // SETRANGE(Paid, FALSE);
                        if not IsEmpty then begin
                            FindSet();
                            repeat
                                LineHeader.Get("Document Type", "Document No.");
                                if not LineHeader.GetPaymentInvPaidStatus() then
                                    Mark(true);
                            until Next() = 0;
                            MarkedOnly(true);
                        end;
                    END;
                Filter3::Paid:
                    BEGIN
                        SETRANGE("Status App", "Status App"::Payment);
                        // SETRANGE(Paid, TRUE);
                        if not IsEmpty then begin
                            FindSet();
                            repeat
                                LineHeader.Get("Document Type", "Document No.");
                                if LineHeader.GetPaymentInvPaidStatus() then
                                    Mark(true);
                            until Next() = 0;
                            MarkedOnly(true);
                        end;
                    END;
                Filter3::Payment:
                    SETRANGE("Status App", "Status App"::Payment);
                Filter3::Overdue:
                    BEGIN
                        SETFILTER("Due Date", '<%1', TODAY);
                        // SETRANGE(Paid, FALSE);
                        if not IsEmpty then begin
                            FindSet();
                            repeat
                                LineHeader.Get("Document Type", "Document No.");
                                if not LineHeader.GetPaymentInvPaidStatus() then
                                    Mark(true);
                            until Next() = 0;
                            MarkedOnly(true);
                        end;
                    END;
            END;
        END;

        grUserSetup.TESTFIELD("Salespers./Purch. Code");
        CASE Filter4 OF
            Filter4::MyDocC:
                SETRANGE("Purchaser Code", grUserSetup."Salespers./Purch. Code");
            Filter4::MyDocA:
                SETRANGE("Process User", USERID);
        END;

        FILTERGROUP(0);

        Rec := SaveRec;
        if find('=<>') then;
    end;
}