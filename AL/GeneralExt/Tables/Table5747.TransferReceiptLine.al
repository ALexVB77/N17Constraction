tableextension 85747 "Transfer Receipt Line (Ext)" extends "Transfer Receipt Line"
{
    fields
    {
        field(50000; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            Description = 'SWC1066 DD 27.06.17';
            TableRelation = "Gen. Business Posting Group";
        }
    }
}