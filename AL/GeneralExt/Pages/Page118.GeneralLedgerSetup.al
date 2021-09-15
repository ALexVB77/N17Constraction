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
        addafter(Templates)
        {
            group("IFRS Translation")
            {
                Caption = 'IFRS Translation';

                field("IFRS Stat. Acc. Map. Code"; "IFRS Stat. Acc. Map. Code")
                {
                    ApplicationArea = All;
                }
                field("IFRS Stat. Acc. Map. Vers.Code"; "IFRS Stat. Acc. Map. Vers.Code")
                {
                    ApplicationArea = All;
                }
                field("IFRS Transfer Period"; "IFRS Transfer Period")
                {
                    ApplicationArea = All;
                }
                field("Check IFRS Trans. Consistent"; "Check IFRS Trans. Consistent")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}