page 70024 "Get Item Ledger Entry Lines"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Item Ledger Entry";
    Editable = false;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Comment; rec.Comment)
                {
                    ApplicationArea = All;
                }
                field("User ID from Value"; rec."User ID from Value")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Cost Amount (Expected)"; Rec."Cost Amount (Expected)")
                {
                    ApplicationArea = All;
                }
                field("Cost Amount (Actual)"; Rec."Cost Amount (Actual)")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }


            }
        }

    }
    var
        ItemDocumentHeader: Record "Item Document Header";
        TempILELine: Record "Item Ledger Entry" temporary;
        GetInventory: Codeunit "Inven.-Get Inventory";

    procedure SetItemDocumentHeader(var ItemShipmentHeader2: Record "Item Document Header")
    begin
        ItemDocumentHeader.GET(ItemShipmentHeader2."Document Type", ItemShipmentHeader2."No.");
    end;

    procedure CreateLines()
    begin
        IF NOT Rec.ISEMPTY THEN BEGIN
            CurrPage.SETSELECTIONFILTER(Rec);
            GetInventory.SetItemDocumentHeader(ItemDocumentHeader);
            GetInventory.CreateItemDocumentLines(Rec);
        END;
    end;

    procedure SetSource(var ItemLEdgerEntryLine: Record "Item Ledger Entry")
    begin

        Rec.DELETEALL;
        IF ItemLedgerEntryLine.FINDSET THEN
            REPEAT
                Rec := ItemLedgerEntryLine;
                REc.INSERT;
            UNTIL ItemLedgerEntryLine.NEXT = 0;

    end;



}