tableextension 82458 "Direct Transfer Header (Ext)" extends "Direct Transfer Header"
{
    fields
    {
        field(50000; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            Description = 'NC 51411 EP';
            TableRelation = "Gen. Business Posting Group";
        }
    }
}