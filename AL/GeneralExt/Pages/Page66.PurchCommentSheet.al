pageextension 80066 "Purch. Comment Sheet (Ext)" extends "Purch. Comment Sheet"
{
    layout
    {
        addafter(Comment)
        {
            field("Comment 2"; Rec."Comment 2")
            {
                ApplicationArea = Comments;
            }
            field("Add. Line Type"; Rec."Add. Line Type")
            {
                ApplicationArea = Comments;
                Editable = false;
            }
        }
    }
}