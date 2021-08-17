pageextension 80001 "Company Information (Ext)" extends "Company Information"
{
    layout
    {
        addlast("System Indicator")
        {
            field("Use RedFlags in Agreements"; Rec."Use RedFlags in Agreements")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Use RedFlags in Agreements';
            }
            field("Expired Date"; "Expired Date")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Director Name 2"; "Director Name 2")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}