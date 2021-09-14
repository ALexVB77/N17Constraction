pageextension 80017 "G/L Account Card (Ext)" extends "G/L Account Card"
{
    layout
    {
        addlast(General)
        {
            field("Non-transmit"; "Non-transmit")
            {
                ApplicationArea = All;
            }
        }
    }
}