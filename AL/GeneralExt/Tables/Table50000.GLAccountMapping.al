table 50000 "G/L Account Mapping"
{
    Caption = 'G/L Account Mapping';

    fields
    {
        field(1; "New No."; Code[20])
        {
            Caption = 'New No."';
        }
        field(2; "Old No."; Code[20])
        {
            Caption = 'Old No."';
        }
    }

    keys
    {
        key(Key1; "New No.")
        {
            Clustered = true;
        }
    }
}