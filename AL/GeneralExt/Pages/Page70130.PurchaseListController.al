page 70130 "Purchase List Controller"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Register';
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
                field("Sorting"; SortType1)
                {
                    ApplicationArea = All;
                    Caption = 'Sorting';
                    OptionCaption = 'Payment date,Payment date (Fact),Document No.,Vendor Name';
                    trigger OnValidate()
                    begin
                        SetSortType;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
            }

            repeater(Repeater12370003)
            {
                field("Paid Date Fact"; Rec."Paid Date Fact")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Paid; GetPaymentInvPaidStatus())
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Paid';
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Problem Document"; Rec."Problem Document")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Problem Type"; "Problem Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(ProblemDescription; ProblemDescription)
                {
                    Caption = 'Problem Description';
                    Editable = false;
                    ApplicationArea = All;
                }

                field("Invoice Amount Incl. VAT (LCY)"; Rec.GetInvoiceAmountsLCY(AmountType::"Include VAT"))
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Invoice Amount Incl. VAT (LCY)';
                    Editable = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Status App"; Rec."Status App")
                {
                    ApplicationArea = All;
                    Caption = 'Approval Status';
                    OptionCaption = ' ,Reception,Сontroller,Checker,Approve,Payment';
                    Editable = false;
                }
                field("Date Status App"; Rec."Date Status App")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Process User"; Rec."Process User")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        OpenPaymentRequestCard();
                    end;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Controller; Controller)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Invoice Amount"; Rec."Invoice Amount Incl. VAT" - Rec."Invoice VAT Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Invoice Amount';
                }
                field("Invoice Amount Incl. VAT"; "Invoice Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                }
                field("Invoice Amount (LCY)"; GetInvoiceAmountsLCY(AmountType::"Exclude VAT"))
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Invoice Amount (LCY)';
                }
                field("Exists Comments"; Rec."Comment")
                {
                    ApplicationArea = All;
                    Caption = 'Exists Comments';
                    Editable = false;
                }
                field("Exists Attachment"; Rec."Exists Attachment")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; LinkedGenJnlLine."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Caption = 'Journal Batch Name';
                    Editable = false;
                }
                field("Journal Line No."; LinkedGenJnlLine."Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'Journal Line No.';
                    Editable = false;
                    BlankZero = true;
                }
                field("Additional Info"; CommentAddInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Comment';

                    trigger OnValidate()
                    begin
                        Rec.SetAddTypeCommentText(CommentAddType::"Additional Info", CommentAddInfo);
                    end;
                }
                field(Reason; CommentAddReason)
                {
                    ApplicationArea = All;
                    Caption = 'Reason';

                    trigger OnValidate()
                    begin
                        Rec.SetAddTypeCommentText(CommentAddType::Reason, CommentAddReason);
                    end;
                }
                field("Spec. Bank Account No."; "Spec. Bank Account No.")
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
            action(ViewRequest)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Request (Journal)';
                Image = View;

                trigger OnAction()
                begin
                    OpenPaymentRequestCard();
                end;
            }
            action(ViewOrder)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Order';
                Image = Order;
                RunObject = Page "Purchase Order App";
                RunPageLink = "No." = field("No.");
            }
            action(ViewProblemDoc)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Problem Document';
                Image = ViewDocumentLine;
                RunObject = Page "Problem Document Set";
                RunPageLink = "No." = field("No.");
            }
            action(ResetProblemDoc)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reset Problem from Doc.';
                Image = ResetStatus;

                trigger OnAction()
                var
                    PurchHeader: Record "Purchase Header";
                begin
                    CurrPage.SetSelectionFilter(PurchHeader);
                    PayOrderMgt.PaymentRegisterResetProblemDocument(PurchHeader);
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
        }
    }

    trigger OnOpenPage()
    begin
        grUserSetup.GET(USERID);

        SETFILTER("Status App", '%1', "Status App"::Payment);
        SETRANGE("IW Documents", TRUE);

        SetSortType;
        SetRecFilters;
    end;

    trigger OnAfterGetRecord()
    var
        AddCommentType: enum "Purchase Comment Add. Type";
    begin
        LinkedGenJnlLine.Reset;
        LinkedGenJnlLine.SetCurrentKey("IW Document No.");
        LinkedGenJnlLine.SetRange("IW Document No.", "No.");
        if not LinkedGenJnlLine.FindFirst() then begin
            LinkedGenJnlLine.Init();
            LinkedGenJnlLine."Journal Template Name" := '';
            LinkedGenJnlLine."Journal Batch Name" := '';
            LinkedGenJnlLine."Line No." := 0;
        end;

        CommentAddInfo := Rec.GetAddTypeCommentText(CommentAddType::"Additional Info");
        CommentAddReason := Rec.GetAddTypeCommentText(CommentAddType::Reason);

        ProblemDescription := '';
        if "Problem Document" then begin
            if "Status App" = "Status App"::Payment then
                ProblemDescription := Rec.GetAddTypeCommentText(AddCommentType::Problem)
            else
                ProblemDescription := Rec.GetApprovalCommentText();
        end;
    end;

    var
        grUserSetup: Record "User Setup";
        LinkedGenJnlLine: Record "Gen. Journal Line";
        PayOrderMgt: Codeunit "Payment Order Management";
        Filter3: option Ready,Paid,Payment,Overdue,All;
        SortType1: option PayDate,PayDateFact,DocNo,Vendor;
        AmountType: Enum "Amount Type";
        CommentAddType: Enum "Purchase Comment Add. Type";
        CommentAddInfo, CommentAddReason : Text;
        ProblemDescription: Text[80];

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
        MarkedOnly(false);
        ClearMarks();
        SETRANGE("Status App");
        SETRANGE("Due Date");

        CASE Filter3 OF
            Filter3::Ready:
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
            Filter3::Paid:
                BEGIN
                    SETRANGE("Status App", "Status App"::Payment);
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
            Filter3::Payment:
                SETRANGE("Status App", "Status App"::Payment);
            Filter3::Overdue:
                BEGIN
                    SETFILTER("Due Date", '<%1', TODAY);
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
        END;

        // SETRANGE(Archival, FALSE);

        FILTERGROUP(0);

        Rec := SaveRec;
        if find('=<>') then;
    end;

    procedure SetSortType()
    begin
        CASE SortType1 OF
            SortType1::PayDate:
                SETCURRENTKEY("Due Date");
            SortType1::PayDateFact:
                SETCURRENTKEY("Paid Date Fact");
            SortType1::DocNo:
                SETCURRENTKEY("No.");
            SortType1::Vendor:
                SETCURRENTKEY("Buy-from Vendor Name");
        END;
    end;

    local procedure OpenPaymentRequestCard()
    var
        GenJnlLine: Record "Gen. Journal Line";
        PaymentRequestCard: Page "Payment Request Card";
        PaymentJournal: page "Payment Journal";
        MultiLine: Boolean;
        LocText001: Label 'No payment journal lines were created from document %1.';
    begin
        if LinkedGenJnlLine."Line No." = 0 then begin
            Message(LocText001, "No.");
            exit;
        end;

        GenJnlLine.SetCurrentKey("IW Document No.");
        GenJnlLine.SetRange("IW Document No.", "No.");
        MultiLine := GenJnlLine.Count > 1;

        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", LinkedGenJnlLine."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", LinkedGenJnlLine."Journal Batch Name");
        GenJnlLine.SetRange("Line No.", LinkedGenJnlLine."Line No.");

        if not MultiLine then begin
            PaymentRequestCard.SetTableView(GenJnlLine);
            PaymentRequestCard.SetRecord(GenJnlLine);
            PaymentRequestCard.Run();
        end else begin
            PaymentJournal.SetTableView(GenJnlLine);
            PaymentJournal.SetRecord(GenJnlLine);
            PaymentJournal.Run();
        end;
    end;

}
