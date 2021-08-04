pageextension 80118 "General Ledger Setup (Ext)" extends "General Ledger Setup"
{
    layout
    {
        addafter("Shortcut Dimension 8 Code")
        {
            field("Utilities Dimension Code"; Rec."Utilities Dimension Code")
            {
                ApplicationArea = All;
            }
            field("Project Dimension Code"; "Project Dimension Code")
            {
                ApplicationArea = All;
            }
        }
    }
}