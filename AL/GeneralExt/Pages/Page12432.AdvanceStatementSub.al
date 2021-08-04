pageextension 92432 "Advance Statement Subform Ext" extends "Advance Statement Subform"
{
    layout
    {
        addafter("Qty. Assigned")
        {
            field("Agreement No."; Rec."Agreement No.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}