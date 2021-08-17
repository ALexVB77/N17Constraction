tableextension 80079 "Company Information (Ext)" extends "Company Information"
{
    fields
    {
        field(50001; "Company Type"; Option)
        {
            Caption = 'Company Type';
            OptionMembers = Housing,Construction;
            OptionCaption = 'Housing,Construction';
            Description = '50086';
        }
        field(50005; "Expired Date"; Date)
        {
            Caption = 'Expired Date';
            Description = '50543';
        }
        field(50006; "Director Name 2"; Text[50])
        {
            Caption = 'Director Name 2';
            Description = '50543';
        }
        field(50008; "Use RedFlags in Agreements"; Boolean)
        {
            Caption = 'Use RedFlags in Agreements';
            Description = 'NC 51432 PA';
        }
    }
}