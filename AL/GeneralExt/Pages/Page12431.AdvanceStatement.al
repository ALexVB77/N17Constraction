pageextension 92431 "Advance Statement Ext" extends "Advance Statement"
{
    layout
    {
        addlast(content)
        {
            group(Agreements)
            {
                Caption = 'Agreements';
                field("Agreement No."; "Agreement No.")
                {

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