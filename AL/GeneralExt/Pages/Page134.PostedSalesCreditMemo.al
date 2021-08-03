pageextension 80134 MyExtension extends "Posted Sales Credit Memo"
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
