tableextension 70609 "General Ledger Setup (Req)" extends "General Ledger Setup"
{
    fields
    {
        field(50040; "Utilities Dimension Code"; Code[20])
        {
            Caption = 'UTILITIES Dim. Code';
            TableRelation = Dimension;
            Description = 'NC 51373 AB';
        }
    }
}