page 70000 "Purchase Order App"
{
    Caption = 'Purchase Order App';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Order,Function,Print,Request Approval,Approve,Release,Navigate';
    RefreshOnActivate = true;
    SourceTable = "Purchase Header";
    SourceTableView = WHERE("Document Type" = FILTER(Order));
    InsertAllowed = false;

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
                    Importance = Standard;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Exists Attachment"; Rec."Exists Attachment")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                group(DocAmounts)
                {
                    Caption = 'Amounts';
                    field("Invoice Amount Incl. VAT"; Rec."Invoice Amount Incl. VAT")
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        ShowMandatory = true;
                    }
                    field("Invoice VAT Amount"; Rec."Invoice VAT Amount")
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        ShowMandatory = true;
                    }
                    field("Invoice Amount"; Rec."Invoice Amount Incl. VAT" - Rec."Invoice VAT Amount")
                    {
                        Caption = 'Invoice Amount';
                        ApplicationArea = All;
                        BlankZero = true;
                        Editable = false;
                    }
                    field("Remaining Amount"; Rec."Invoice Amount Incl. VAT" - Rec."Payments Amount")
                    {
                        Caption = 'Remaining Amount';
                        ApplicationArea = All;
                        BlankZero = true;
                        Editable = false;
                    }
                }
                field("Problem Document"; Rec."Problem Document")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Problem Type"; Rec."Problem Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Problem Description"; ProblemDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Problem Description';
                    Editable = RejectButtonEnabled;
                    Enabled = RejectButtonEnabled;

                    trigger OnValidate()
                    begin
                        if "Status App" = "Status App"::Payment then
                            Rec.SetAddTypeCommentText(AddCommentType::Problem, ProblemDescription)
                        else
                            Rec.SetApprovalCommentText(ProblemDescription);
                    end;
                }
                field("Payment to Person"; Rec."Payment to Person")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PurchSetup.Get();
                        if "Payment to Person" and ("Payment Assignment" = '') then
                            "Payment Assignment" := PurchSetup."Default Payment Assignment";
                        PaymentAssignmentEnabled := "Payment to Person";
                        CurrPage.Update(true);
                    end;
                }
                field("Payment Assignment"; Rec."Payment Assignment")
                {
                    ApplicationArea = All;
                    Editable = PaymentAssignmentEnabled;
                    Enabled = PaymentAssignmentEnabled;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = PaymentTypeEditable;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        SaveInvoiceDiscountAmount;
                    end;
                }
                field("IW Planned Repayment Date"; Rec."IW Planned Repayment Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = IWPlanRepayDateMandatory;
                }
                field("Controller"; Rec.Controller)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                    Caption = 'Checker';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CurrPage.PurchaseOrderAppLines.PAGE.UpdateForm(true);
                    end;
                }
                field("Pre-Approver"; PaymentOrderMgt.GetPurchActPreApproverFromDim("Dimension Set ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Pre-Approver';
                    Editable = false;
                }
                field("Approver"; PaymentOrderMgt.GetPurchActApproverFromDim("Dimension Set ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Approver';
                    Editable = false;
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        VendAgreement: Record "Vendor Agreement";
                    begin
                        if "Agreement No." <> '' then
                            if VendAgreement.Get(Rec."Buy-from Vendor No.", Rec."Agreement No.") then
                                Rec."Purchaser Code" := VendAgreement."Purchaser Code";
                    end;
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
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
                        Editable = false;
                    }
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        Clear(ChangeExchangeRate);
                        if "Posting Date" <> 0D then
                            ChangeExchangeRate.SetParameter("Currency Code", "Currency Factor", "Posting Date")
                        else
                            ChangeExchangeRate.SetParameter("Currency Code", "Currency Factor", WorkDate);
                        if ChangeExchangeRate.RunModal = ACTION::OK then begin
                            Validate("Currency Factor", ChangeExchangeRate.GetParameter);
                            SaveInvoiceDiscountAmount;
                        end;
                        Clear(ChangeExchangeRate);
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        PurchCalcDiscByType.ApplyDefaultInvoiceDiscount(0, Rec);
                    end;
                }
                field("Status App"; Rec."Status App")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Approval Status';
                    OptionCaption = ' ,Reception,Сontroller,Checker,Approve,Payment';
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
            }

            part(PurchaseOrderAppLines; "Purchase Order Subform App")
            {
                ApplicationArea = All;
                Editable = "Buy-from Vendor No." <> '';
                Enabled = "Buy-from Vendor No." <> '';
                SubPageLink = "Document No." = FIELD("No.");
                UpdatePropagation = Both;
            }

            group("Payment Request")
            {
                Caption = 'Payment Request';
                field("Vendor Bank Account"; Rec."Vendor Bank Account")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Vendor Bank Account Name"; GetVendorBankAccountName)
                {
                    ApplicationArea = All;
                    Editable = false;
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
            group(Order)
            {
                Caption = 'O&rder';
                Image = "Order";
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
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
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
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

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
                        WorkflowsEntriesBuffer: Record "Workflows Entries Buffer";
                    begin
                        WorkflowsEntriesBuffer.RunWorkflowEntriesPage(
                            RecordId, DATABASE::"Purchase Header", "Document Type".AsInteger(), "No.");
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(CopyDocument)
                {
                    ApplicationArea = Suite;
                    Caption = 'Copy Document';
                    Ellipsis = true;
                    Enabled = CopyDocumentEnabled;
                    Image = CopyDocument;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        CopyDocument();
                        if Get("Document Type", "No.") then;
                    end;
                }

                action("Archive Document")
                {
                    ApplicationArea = Suite;
                    Caption = 'Archi&ve Document';
                    Enabled = "No." <> '';
                    Image = Archive;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        if PaymentOrderMgt.PurchPaymentInvoiceArchive(Rec) then
                            CurrPage.Close();
                    end;
                }
            }
            group(Print)
            {
                Caption = 'Print';
                action("&Print")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Print';
                    Ellipsis = true;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Message('Нажата кнопка Печать');
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = Suite;
                    Caption = 'Approve';
                    Enabled = ApproveButtonEnabled;
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category8;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        MessageIfPurchLinesNotExist;
                        if "Status App" in ["Status App"::" ", "Status App"::Payment] then
                            FieldError("Status App");
                        if "Status App" = "Status App"::Reception then begin
                            IF ApprovalsMgmt.CheckPurchaseApprovalPossible(Rec) THEN
                                ApprovalsMgmt.OnSendPurchaseDocForApproval(Rec);
                        end else
                            ApprovalsMgmt.ApproveRecordApprovalRequest(RECORDID);
                        CurrPage.Update(false);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = Suite;
                    Caption = 'Reject';
                    Enabled = RejectButtonEnabled;
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category8;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        if "Status App" in ["Status App"::" ", "Status App"::Reception, "Status App"::Payment] then
                            FieldError("Status App");
                        ApprovalsMgmtExt.RejectPurchActAndPayInvApprovalRequest(RECORDID);
                        CurrPage.Update(false);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = Suite;
                    Caption = 'Delegate';
                    Enabled = false;
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category8;
                    Visible = false;

                    trigger OnAction()
                    begin
                        //ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
                        Message('Pressed Delegate');
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = Suite;
                    Caption = 'Comments';
                    Enabled = ApproveButtonEnabled or RejectButtonEnabled;
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category8;

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Responsibility Center" := UserMgt.GetPurchasesFilter;
    end;

    trigger OnAfterGetCurrRecord()
    begin

        if "Status App" = "Status App"::Payment then
            ProblemDescription := Rec.GetAddTypeCommentText(AddCommentType::Problem)
        else
            ProblemDescription := Rec.GetApprovalCommentText();

        PaymentAssignmentEnabled := "Payment to Person";
        CopyDocumentEnabled := ("No." <> '') and ("Status App" = "Status App"::Reception);

        ApproveButtonEnabled := FALSE;
        RejectButtonEnabled := FALSE;

        // StatusStyleTxt := GetStatusStyleText();

        if (UserId = Rec.Receptionist) and (Rec."Status App" = Rec."Status App"::Reception) then
            ApproveButtonEnabled := true;
        if ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId) then begin
            ApproveButtonEnabled := true;
            RejectButtonEnabled := true;
        end;

        UserSetup.GET(USERID);

        CurrPage.EDITABLE("Status App" < "Status App"::Approve);
        IF "Status App" = "Status App"::Request THEN
            CurrPage.EDITABLE(TRUE);

        IWPlanRepayDateMandatory := Rec."Payment Type" = Rec."Payment Type"::"pre-pay";

        PaymentTypeEditable := "Status App" < "Status App"::Checker;
        AppButtonEnabled :=
            NOT ((UPPERCASE("Process User") <> UPPERCASE(USERID)) AND (UserSetup."Status App Act" <> Rec."Status App Act"));

        IF "Status App Act" = "Status App Act"::Approve THEN BEGIN
            ApprovalEntry.SETRANGE("Table ID", Database::"Purchase Header");
            ApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type"::Order);
            ApprovalEntry.SETRANGE("Document No.", "No.");
            ApprovalEntry.SETRANGE("Approver ID", USERID);
            IF ApprovalEntry.FINDSET THEN
                AppButtonEnabled := NOT ApprovalEntry.IsEmpty;
        END;
        IF "Status App" = "Status App"::Request THEN
            AppButtonEnabled := TRUE;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord;
        UserSetup.GET(UserId);
        IF not ((UserSetup."Status App" in [UserSetup."Status App"::Reception, UserSetup."Status App"::Controller]) OR UserSetup."Administrator IW") THEN
            ERROR(TextDelError, Rec."No.");
        IF NOT gcERPC.DeleteInvoice(Rec) then
            ERROR('');
        exit(ConfirmDeletion);
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        UserSetup: Record "User Setup";
        ApprovalEntry: Record "Approval Entry";
        ChangeExchangeRate: Page "Change Exchange Rate";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        ArchiveManagement: Codeunit ArchiveManagement;
        gcERPC: Codeunit "ERPC Funtions";
        UserMgt: Codeunit "User Setup Management";
        PaymentOrderMgt: Codeunit "Payment Order Management";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ApprovalsMgmtExt: Codeunit "Approvals Mgmt. (Ext)";
        PaymentTypeEditable, AppButtonEnabled, ApproveButtonEnabled, RejectButtonEnabled, PaymentAssignmentEnabled, CopyDocumentEnabled : Boolean;
        IWPlanRepayDateMandatory: Boolean;
        ProblemDescription: text[80];
        AddCommentType: enum "Purchase Comment Add. Type";
        TextDelError: Label 'You cannot delete Purchase Order Act %1';

    local procedure SaveInvoiceDiscountAmount()
    var
        DocumentTotals: Codeunit "Document Totals";
    begin
        CurrPage.SaveRecord;
        DocumentTotals.PurchaseRedistributeInvoiceDiscountAmountsOnDocument(Rec);
        CurrPage.Update(false);
    end;

    local procedure GetVendorBankAccountName(): text
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if Rec."Vendor Bank Account No." <> '' then
            if VendorBankAccount.get("Pay-to Vendor No.", "Vendor Bank Account No.") then
                exit(VendorBankAccount.Name + VendorBankAccount."Name 2");
    end;
}
