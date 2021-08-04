pageextension 85607 "Fixed Asset Setup (Ext)" extends "Fixed Asset Setup"
{
    layout
    {
        addafter("FA-1 Template Code")
        {
            field("FA-1a Template Code"; Rec."FA-1a Template Code")
            {
                ApplicationArea = FixedAssets;
            }
            field("FA-1b Template Code"; Rec."FA-1b Template Code")
            {
                ApplicationArea = FixedAssets;
            }
        }
        addafter("FA-4a Template Code")
        {
            field("FA-4b Template Code"; Rec."FA-4b Template Code")
            {
                ApplicationArea = FixedAssets;
            }
        }
        addlast(Templates)
        {
            field("FA Turnover Template Code"; Rec."FA Turnover Template Code")
            {
                ApplicationArea = FixedAssets;
            }
        }
    }
}