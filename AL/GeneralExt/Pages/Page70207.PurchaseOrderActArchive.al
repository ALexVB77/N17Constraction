page 70207 "Purchase Order Act Archive"
{
    Caption = 'Purchase Order Act';
    DeleteAllowed = false;
    Editable = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Act,Function,Request Approval,Approve,Release,Navigate,Print';
    SourceTable = "Purchase Header Archive";
    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(VendorNo; "Buy-from Vendor No.")
                {
                    ApplicationArea = Suite;
                    Enabled = not IsEmplPurchase;
                    HideValue = IsEmplPurchase;
                    Importance = Promoted;
                }
                field(EmployeeNo; "Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Employee No.';
                    Enabled = IsEmplPurchase;
                    HideValue = not IsEmplPurchase;
                    Importance = Promoted;
                    LookupPageID = "Responsible Employees";
                }

                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor/Employee Name';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                }
                field("Exists Attachment"; Rec."Exists Attachment")
                {
                    ApplicationArea = All;
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;
                }
                group(DocAmounts)
                {
                    Caption = 'Amounts';
                    field("Invoice Amount Incl. VAT"; Rec."Invoice Amount Incl. VAT")
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                    }
                    field("Invoice VAT Amount"; Rec."Invoice VAT Amount")
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                    }
                    field("Invoice Amount"; Rec."Invoice Amount Incl. VAT" - Rec."Invoice VAT Amount")
                    {
                        Caption = 'Invoice Amount';
                        ApplicationArea = All;
                        BlankZero = true;
                    }
                    field("Remaining Amount"; Rec."Invoice Amount Incl. VAT" - Rec."Payments Amount")
                    {
                        Caption = 'Remaining Amount';
                        ApplicationArea = All;
                        BlankZero = true;
                    }
                }
                field("Problem Document"; Rec."Problem Document")
                {
                    ApplicationArea = All;
                }
                field("Act Type"; Rec."Act Type")
                {
                    ApplicationArea = All;
                }
                field("Problem Type"; Rec."Problem Type")
                {
                    ApplicationArea = All;
                }
                field("Problem Description"; ProblemDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Problem Description';
                }
                field("Act Invoice No."; Rec."Act Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                group("Warehouse Document")
                {
                    Caption = 'Warehouse Document';
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = All;
                    }
                    field(Storekeeper; Rec.Storekeeper)
                    {
                        ApplicationArea = All;
                    }
                    field("Location Document"; Rec."Location Document")
                    {
                        ApplicationArea = All;
                    }
                }

                field("Estimator"; Rec."Estimator")
                {
                    ApplicationArea = All;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                    Caption = 'Checker';
                }
                field("Pre-Approver"; PreApproverNo)
                {
                    ApplicationArea = All;
                    Caption = 'Pre-Approver';
                }
                field("Approver"; PaymentOrderMgt.GetPurchActApproverFromDim("Dimension Set ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Approver';
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                }
                group("Payment Date")
                {
                    Caption = 'Payment Date';
                    field("Paid Date Plan"; Rec."Due Date")
                    {
                        ApplicationArea = All;
                        Caption = 'Plan';
                    }
                    field("Paid Date Fact"; Rec."Paid Date Fact")
                    {
                        ApplicationArea = All;
                        Caption = 'Fact';
                    }
                }
                field(Status; Status)
                {
                    ApplicationArea = Suite;
                }
                field("Status App Act"; Rec."Status App Act")
                {
                    ApplicationArea = All;
                }
                field("Date Status App"; Rec."Date Status App")
                {
                    ApplicationArea = All;
                }
                field("Process User"; Rec."Process User")
                {
                    ApplicationArea = All;
                }
                field("Receive Account"; Rec."Receive Account")
                {
                    ApplicationArea = All;
                }
            }
            part(PurchaseOrderActLines; "Purchase Order Act Arch. Sub.")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = FIELD("No."), "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"), "Version No." = FIELD("Version No.");
            }
            group("Payment Request")
            {
                Caption = 'Payment Request';
                field("Vendor Bank Account"; Rec."Vendor Bank Account")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        VendorBankAccount: Record "Vendor Bank Account";
                    begin
                        VendorBankAccount.SETRANGE("Vendor No.", Rec."Pay-to Vendor No.");
                        Page.RUNMODAL(0, VendorBankAccount);
                    end;
                }
                field("Vendor Bank Account Name"; GetVendorBankAccountName)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Bank Account Name';
                }
                field("Vendor Bank Account No."; rec."Vendor Bank Account No.")
                {
                    ApplicationArea = All;
                }
                field("Payment Details"; rec."Payment Details")
                {
                    ApplicationArea = All;
                }
                field("OKATO Code"; rec."OKATO Code")
                {
                    ApplicationArea = All;
                }
                field("KBK Code"; rec."KBK Code")
                {
                    ApplicationArea = All;
                }
            }
            group("Details")
            {
                Caption = 'Details';
                field("Buy-from Contact No."; "Buy-from Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor Name Dtld"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Address"; "Buy-from Address")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Post Code"; "Buy-from Post Code")
                {
                    ApplicationArea = All;
                }
                field("Buy-from City"; "Buy-from City")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Contact"; "Buy-from Contact")
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
            group(OrderAct)
            {
                Caption = 'O&rder Act';
                Image = "Order";
                action(ViewAttachDoc)
                {
                    ApplicationArea = All;
                    Caption = 'Documents View';
                    Enabled = ShowDocEnabled;
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        DocumentAttachment: Record "Document Attachment Archive";
                        RecRef: RecordRef;
                    begin
                        CalcFields("Exists Attachment");
                        TestField("Exists Attachment");
                        DocumentAttachment.SetRange("Table ID", DATABASE::"Purchase Header Archive");
                        DocumentAttachment.SetRange("Document Type", Rec."Document Type");
                        DocumentAttachment.SetRange("No.", Rec."No.");
                        DocumentAttachment.SetRange("Doc. No. Occurrence", "Doc. No. Occurrence");
                        DocumentAttachment.SetRange("Version No.", "Version No.");
                        DocumentAttachment.FindFirst();
                        DocumentAttachment.Export(true);
                    end;
                }
                // NC AB: look later
                /*
                action(Statistics)
                {
                    ApplicationArea = All;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        CalcInvDiscForHeader;
                        Commit();
                        PAGE.RunModal(PAGE::"Purchase Statistics", Rec);
                        PurchCalcDiscByType.ResetRecalculateInvoiceDisc(Rec);
                    end;
                }
                */
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Enabled = "No." <> '';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+D';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                        CurrPage.SaveRecord;
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Purch. Archive Comment Sheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "No." = FIELD("No."),
                                  "Document Line No." = CONST(0),
                                  "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"),
                                  "Version No." = FIELD("Version No.");
                }
                action(DocAttach)
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attach. Details Arch.";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal;
                    end;
                }
                action(Approvals)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ReqApprEntriesArch: Page "Request Approval Entries Arch.";
                    begin
                        ReqApprEntriesArch.Setfilters(
                            Database::"Purchase Header Archive", "Document Type".AsInteger(), "No.", "Doc. No. Occurrence", "Version No.");
                        ReqApprEntriesArch.Run;
                    end;
                }
                action(ApprovalComments)
                {
                    ApplicationArea = Suite;
                    Caption = 'Approval Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    var
                        ApprCommentLineArch: Record "Request Appr. Com. Line Arch.";
                        ApprovalCommentsArch: page "Request Appr. Comments Arch.";
                    begin
                        ApprCommentLineArch.FilterGroup(2);
                        ApprCommentLineArch.SetRange("Table ID", Database::"Purchase Header Archive");
                        ApprCommentLineArch.SetRange("Record ID to Approve", RecordId);
                        ApprCommentLineArch.FilterGroup(0);
                        ApprovalCommentsArch.SetTableView(ApprCommentLineArch);
                        ApprovalCommentsArch.Run;
                    end;
                }
            }
            // NC AB: look later
            /*
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action(PaymentInvoices)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Invoices';
                    Image = Payment;
                    Promoted = true;
                    PromotedCategory = Category9;
                    RunObject = Page "Purch. Order Act PayReq. List";
                    RunPageLink = "Document Type" = CONST(Order),
                                  "IW Documents" = CONST(true),
                                  "Linked Purchase Order Act No." = field("No.");
                }
            }
            */
        }
        area(processing)
        {
            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action("&Print")
                {
                    ApplicationArea = Suite;
                    Caption = '&Print';
                    Ellipsis = true;
                    Enabled = GenPrintEnabled;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Category10;
                    // NC AB: see later
                    Visible = false;

                    trigger OnAction()
                    var
                        PurchaseHeaderArch: Record "Purchase Header Archive";
                        ReportSelUsage: enum "Report Selection Usage";
                    begin
                        PurchaseHeaderArch := Rec;
                        CurrPage.SetSelectionFilter(PurchaseHeaderArch);
                        //PurchaseHeaderArch.PrintRecordsExt(true, ReportSelUsage::PurchOrderAct);
                    end;
                }

                action("Cover Sheet")
                {
                    ApplicationArea = Suite;
                    Caption = 'Cover Sheet';
                    Image = PrintCover;
                    Promoted = true;
                    PromotedCategory = Category10;
                    // NC AB: see later
                    Visible = false;

                    trigger OnAction()
                    var
                        PurchaseHeaderArch: Record "Purchase Header Archive";
                        CoverSheet: report "Cover Sheet";
                        Text50005: Label 'The cover sheet can only be printed from the Signing status.';
                    begin
                        if "Status App Act".AsInteger() < "Status App Act"::Signing.AsInteger() then begin
                            Message(Text50005);
                            exit;
                        end;
                        PurchaseHeaderArch := Rec;
                        CurrPage.SetSelectionFilter(PurchaseHeaderArch);
                        CoverSheet.SetTableView(PurchaseHeaderArch);
                        CoverSheet.Run();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if UserMgt.GetPurchasesFilter <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserMgt.GetPurchasesFilter);
            FilterGroup(0);
        end;
    end;

    trigger OnAfterGetCurrRecord()
    var
        AddCommentType: enum "Purchase Comment Add. Type";
    begin

        CalcFields("Payments Amount");

        IsEmplPurchase := "Empl. Purchase";

        if "Act Type" = "Act Type"::Advance then
            PreApproverNo := Rec."Pre-Approver"
        else
            PreApproverNo := PaymentOrderMgt.GetPurchActPreApproverFromDim("Dimension Set ID");

        ProblemDescription := Rec.GetAddTypeCommentArchText(AddCommentType::Archive);

        CalcFields("Exists Attachment");
        ShowDocEnabled := "Exists Attachment";
    end;

    var
        UserMgt: Codeunit "User Setup Management";
        PaymentOrderMgt: Codeunit "Payment Order Management";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ShowDocEnabled, GenPrintEnabled : Boolean;
        PreApproverNo: Code[50];
        IsEmplPurchase: Boolean;
        ProblemDescription: text;

    local procedure GetVendorBankAccountName(): text
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if Rec."Vendor Bank Account No." <> '' then
            if VendorBankAccount.get("Vendor Bank Account No.") then
                exit(VendorBankAccount.Name + VendorBankAccount."Name 2");
    end;
}