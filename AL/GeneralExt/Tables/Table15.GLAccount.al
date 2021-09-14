tableextension 80015 "G/L Account (Ext)" extends "G/L Account"
{
    fields
    {
        field(70001; "Non-transmit"; Boolean)
        {
            Caption = 'Non-transmit';
            Description = 'NC 51559 AB';
        }
    }
}