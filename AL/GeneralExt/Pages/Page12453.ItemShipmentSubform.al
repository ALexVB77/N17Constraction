pageextension 92453 "Item Shipment Subform (Ext)" extends "Item Shipment Subform"
{
    layout
    {
        modify("Shortcut Dimension 1 Code")
        {
            Visible = True;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Visible = True;
        }
        modify("ShortcutDimCode[3]")
        {
            Visible = True;
        }
        modify("ShortcutDimCode[4]")
        {
            Visible = True;
        }
        modify("ShortcutDimCode[5]")
        {
            Visible = True;
        }
        modify("ShortcutDimCode[6]")
        {
            Visible = True;
        }
        modify("ShortcutDimCode[7]")
        {
            Visible = True;
        }
        modify("ShortcutDimCode[8]")
        {
            Visible = True;
        }
        modify("Applies-to Entry")
        {
            Visible = True;
        }
        modify("Applies-from Entry")
        {
            Visible = True;
        }
        addafter("ShortcutDimCode[8]")
        {
            field("Utilities Dim. Value Code"; Rec."Utilities Dim. Value Code")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addafter("Item &Tracking Lines")
        {
            action(GetItemLedgerEntryLines)
            {
                Caption = 'Get Item Ledger Lines';
                Image = InventoryPick;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    GetInventory();
                end;
            }
        }
    }

    var
        myInt: Integer;

    procedure GetInventory()

    begin

        //NC 22512 > DP
        CODEUNIT.RUN(CODEUNIT::"Inven.-Get Inventory", Rec);
        //NC 22512 < DP

    end;
}