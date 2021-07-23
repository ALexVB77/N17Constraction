pageextension 85740 "Transfer Order (Ext)" extends "Transfer Order"
{
    layout
    {
        addafter("Transfer-to Code")
        {
            field("Giv. Type"; Rec."Giv. Type")
            {
                ApplicationArea = All;
                // Editable = false;
                Description = 'NC 51410 EP';
            }
        }
        addafter(Status)
        {
            field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
            {
                ApplicationArea = All;
                Editable = false;
                Description = 'NC 51143 EP';
            }
        }
    }

    actions
    {

        addafter(GetReceiptLines)
        {
            action(GetItemLedgerEntryLines)
            {
                Caption = 'Get Item Ledger Lines';
                Image = InventoryPick;
                ApplicationArea = All;
                trigger OnAction()
                begin

                    //NC 22512 > DP
                    rec.GetInventoryLines;
                    //NC 22512 < DP
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // NC 51410 > EP
        Rec."Giv. Type" := Rec."Giv. Type"::Internal;
        // NC 51410 < EP
    end;
}