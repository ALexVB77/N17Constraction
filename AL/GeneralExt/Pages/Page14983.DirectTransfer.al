pageextension 94983 "Direct Transfer (Ext)" extends "Direct Transfer"
{
    layout
    {
        // NC 51410 > EP
        addafter(Status)
        {
            field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
            {
                ApplicationArea = All;
                // Editable = false;
                Description = 'NC 51410 EP';
            }
        }
        addlast(General)
        {
            field("New Shortcut Dimension 1 Code"; Rec."New Shortcut Dimension 1 Code")
            {
                ApplicationArea = All;
                Description = 'NC 51410 EP';
            }
            field("New Shortcut Dimension 2 Code"; Rec."New Shortcut Dimension 2 Code")
            {
                ApplicationArea = All;
                Description = 'NC 51410 EP';
            }
        }
        // NC 51410 < EP
    }
    actions
    {
        // NC 51410 > EP
        modify(Dimensions)
        {
            ShortcutKey = 'Alt+D';
            ApplicationArea = Dimensions;
            Promoted = true;
            PromotedIsBig = true;

            trigger OnAfterAction()
            begin
                Rec.ShowDocDim();
                CurrPage.SaveRecord();
            end;
        }
        // NC 51410 < EP
    }
}