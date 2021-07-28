tableextension 82459 "Direct Transfer Line (Ext)" extends "Direct Transfer Line"
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