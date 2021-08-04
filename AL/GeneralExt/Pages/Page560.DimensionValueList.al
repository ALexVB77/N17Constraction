pageextension 80560 "Dimension Value List (Ext)" extends "Dimension Value List"
{
    layout
    {
        addafter("Consolidation Code")
        {
            field("Project Code"; Rec."Project Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Cost Holder"; Rec."Cost Holder")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Check CF Forecast"; Rec."Check CF Forecast")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Cost Code Type"; Rec."Cost Code Type")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Production Cost Place Holder"; Rec."Production Cost Place Holder")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Development Cost Place Holder"; Rec."Development Cost Place Holder")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Admin Cost Place Holder"; Rec."Admin Cost Place Holder")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
        GenLedgerSetup: Record "General Ledger Setup";
    begin
        GenLedgerSetup.Get();
        if UserSetup.Get(UserId) and UserSetup."Allow Edit DenDoc Dimension" then
            if Rec."Dimension Code" = GenLedgerSetup."Shortcut Dimension 8 Code" then
                CurrPage.Editable(true);
    end;
}