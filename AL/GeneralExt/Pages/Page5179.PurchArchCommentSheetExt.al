pageextension 85179 "Purch. Arch. Comment Sheet Ext" extends "Purch. Archive Comment Sheet"
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