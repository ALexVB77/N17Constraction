pageextension 80050 "Purchase Order Ext" extends "Purchase Order"
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