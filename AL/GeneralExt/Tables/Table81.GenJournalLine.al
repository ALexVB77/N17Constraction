tableextension 80081 "Gen. Journal Line (Ext)" extends "Gen. Journal Line"
{
    fields
    {
        field(50020; "Notify Customer"; boolean)
        {
            Caption = 'Notify Customer';
        }
        field(50030; Gift; Boolean)
        {
            Caption = 'Gift';
        }
        field(70020; "IW Document No."; Code[20])
        {
            Description = 'NC 50112 AB';
            Caption = 'IW Document No.';
        }
    }
}
