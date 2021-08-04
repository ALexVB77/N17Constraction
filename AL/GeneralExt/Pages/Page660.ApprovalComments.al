pageextension 80660 "Approval Comments (Ext)" extends "Approval Comments"
{
    layout
    {
        addlast(Control1)
        {
            field("Status App Act"; Rec."Status App Act")
            {
                ApplicationArea = All;
            }
            field("Status App"; Rec."Status App")
            {
                ApplicationArea = All;
            }
            field("Approval Status"; "Approval Status")
            {
                HideValue = Rec."Linked Approval Entry No." = 0;
                ApplicationArea = All;
            }
        }
    }
}