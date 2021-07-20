pageextension 92431 "Advance Statement Ext" extends "Advance Statement"
{
    layout
    {
        addafter("Foreign Trade")
        {
            group(Agreements)
            {
                Caption = 'Agreements';
                field("Agreement No."; "Agreement No.")
                {
                    ApplicationArea = Basic, Suite;
                }
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