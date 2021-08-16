pageextension 80537 "Dimension Values Ext" extends "Dimension Values"
{
    layout
    {
        addafter("Consolidation Code")
        {
            field("Project Code"; Rec."Project Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Check CF Forecast"; Rec."Check CF Forecast")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Cost Holder"; Rec."Cost Holder")
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
            field("Check Address Dimension"; "Check Address Dimension")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}