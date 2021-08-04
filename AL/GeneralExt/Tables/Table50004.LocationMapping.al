table 50004 "Location Mapping"
{
    Caption = 'Location Mapping';

    fields
    {
        field(1; "New Location Code"; Code[10])
        {
            Caption = 'New Location Code';
        }
        field(2; "Old Location Code"; Code[20])
        {
            Caption = 'Old Location Code';
        }
    }

    keys
    {
        key(Key1; "New Location Code")
        {
            Clustered = true;
        }
    }
}