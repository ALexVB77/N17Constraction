pageextension 80051 "Purchase Invoice Ext" extends "Purchase Invoice"
{
    layout
    {
        modify("Posting Description")
        {
            Visible = true;
        }
        addafter("Posting Description")
        {
            field("Act is Received"; Rec."Act is Received")
            {
                ApplicationArea = All;
            }
            field("Inv.-Fact. is Received"; Rec."Inv.-Fact. is Received")
            {
                ApplicationArea = All;
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