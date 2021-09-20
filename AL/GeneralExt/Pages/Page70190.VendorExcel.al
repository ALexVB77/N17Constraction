page 70190 "Vendor Excel"
{
    Caption = 'Vendor Excel';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Invoice,Function';
    RefreshOnActivate = true;
    SourceTable = "Vendor Excel Header";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Date; Date)
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vend VAT Reg No."; "Vend VAT Reg No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Agreement No."; "Agreement No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Act Type"; "Act Type")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Act No."; "Act No.")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchHead: Record "Purchase Header";
                    begin
                        IF "Act No." <> '' THEN BEGIN
                            PurchHead.GET(PurchHead."Document Type"::Order, "Act No.");
                            Page.Run(Page::"Purchase Order Act", PurchHead);
                        END;
                    end;
                }
            }
            part(VendorExcelLines; "Vendor Excel Subform")
            {
                ApplicationArea = All;
                Editable = "Vendor No." <> '';
                Enabled = "Vendor No." <> '';
                SubPageLink = "Document No." = FIELD("No."), "Vendor No." = FIELD("Vendor No.");
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(CreateItemCard)
                {
                    ApplicationArea = Suite;
                    Caption = 'Create Items';
                    Enabled = "No." <> '';
                    Image = NewItem;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        VELine: Record "Vendor Excel Line";
                    begin
                        VELine.RESET;
                        VELine.SETRANGE("Document No.", "No.");
                        VELine.SETRANGE("Vendor No.", "Vendor No.");
                        VELine.SETRANGE("Item Action", VELine."Item Action"::CreateItem);
                        IF VELine.FINDSET THEN
                            REPEAT
                                VELine.CreateItem();
                            UNTIL VELine.NEXT = 0;
                        MESSAGE(Text001);
                    end;
                }
                action(CreateInvoice)
                {
                    ApplicationArea = Suite;
                    Caption = 'Create Invoice';
                    Enabled = "No." <> '';
                    Image = NewInvoice;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        VELine: Record "Vendor Excel Line";
                        PayOrderMgt: Codeunit "Payment Order Management";
                    begin
                        VELine.RESET;
                        VELine.SETRANGE("Document No.", "No.");
                        VELine.SETRANGE("Vendor No.", "Vendor No.");
                        IF VELine.FINDSET THEN
                            REPEAT
                                VELine.CheckUoM;
                            UNTIL VELine.NEXT = 0;

                        PayOrderMgt.CreatePurchInvoiceFromVendorExcel(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    var
        Text001: Label 'Items are created!';
}