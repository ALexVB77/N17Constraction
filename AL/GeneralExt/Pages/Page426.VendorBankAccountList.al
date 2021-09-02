pageextension 80426 "Vendor Bank Account List Ext" extends "Vendor Bank Account List"
{
    layout
    {
        addlast(Control1)
        {

            field(BIC; Rec.BIC)
            {
                ApplicationArea = All;
            }
        }
        modify("Bank Account No.")
        {
            Visible = true;
        }

    }



    var
        myInt: Integer;
}