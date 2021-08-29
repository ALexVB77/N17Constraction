pageextension 85745 "Posted Transfer Receipt (Ext)" extends "Posted Transfer Receipt"
{
    layout
    {
        // NC 51411 > EP
        modify("Shortcut Dimension 1 Code")
        {
            Visible = false;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Visible = false;
        }
        addlast(General)
        {
            field("New Shortcut Dimension 1 Code"; Rec."New Shortcut Dimension 1 Code")
            {
                ApplicationArea = Dimensions;
                Editable = false;
                Importance = Additional;
            }
            field("New Shortcut Dimension 2 Code"; Rec."New Shortcut Dimension 2 Code")
            {
                ApplicationArea = Dimensions;
                Editable = false;
                Importance = Additional;
            }
        }
        // NC 51411 < EP
        modify("Direct Transfer")
        {
            Importance = Additional;
        }
        addafter("Posting Date")
        {
            field("Agreement No."; Rec."Agreement No.")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
            field("Vendor No."; Rec."Vendor No.")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}