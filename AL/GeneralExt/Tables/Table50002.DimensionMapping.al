table 50002 "Dimension Mapping"
{
    Caption = 'Dimension Mapping';

    fields
    {
        field(1; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
        }
        field(2; "New Dimension Value Code"; Code[20])
        {
            Caption = 'New Dimension Value Code';
        }
        field(3; "Old Dimension Value Code"; Code[20])
        {
            Caption = 'Old Dimension Value Code';
        }
        field(4; "Description"; Code[20])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Dimension Code", "New Dimension Value Code", "Old Dimension Value Code")
        {
            Clustered = true;
        }
    }
}