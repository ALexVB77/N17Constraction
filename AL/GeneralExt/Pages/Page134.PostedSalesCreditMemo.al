pageextension 80134 "Posted Sales Credit Memo (Ext)" extends "Posted Sales Credit Memo"
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
