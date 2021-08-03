pageextension 80044 "Sales Credit Memo (Ext)" extends "Sales Credit Memo"
{
    layout
    {
        addlast(General)
        {
            field("Credit-Memo Reason"; Rec."Credit-Memo Reason")
            {
                ApplicationArea = All;
            }
        }
    }
}
