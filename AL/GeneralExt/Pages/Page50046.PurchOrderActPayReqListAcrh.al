page 50046 "P. Order Act PayReqListArch"
{
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Purchase Header Archive";
    DataCaptionFields = "Document Type";
    PageType = List;
    Caption = 'Payment Invoices for Act Archive';
    RefreshOnActivate = true;
    CardPageId = "Purchase Order App Archive";

    layout
    {
        area(content)
        {
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
                    begin
                        page.Runmodal(Page::"Purchase Order App", Rec);
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
                field("Buy-from Post Code"; Rec."Buy-from Post Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Buy-from Country/Region Code"; Rec."Buy-from Country/Region Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Buy-from Contact"; Rec."Buy-from Contact")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Pay-to Name"; Rec."Pay-to Name")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Pay-to Post Code"; Rec."Pay-to Post Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Pay-to Country/Region Code"; Rec."Pay-to Country/Region Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Pay-to Contact"; Rec."Pay-to Contact")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Visible = false;
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
                Image = Edit;

                trigger OnAction()
                begin
                    page.Runmodal(Page::"Purchase Order App Archive", Rec);
                    CurrPage.Update(false);
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
}
