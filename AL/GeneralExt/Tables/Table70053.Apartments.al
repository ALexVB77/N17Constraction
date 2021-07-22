table 70053 "Apartments"
{
    Caption = 'Investment object';
    LookupPageID = Apartments;
    DrillDownPageID = Apartments;
    fields
    {
        field(1; "Object No."; Code[20])
        {
            Caption = 'Object Code';
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
        }

        field(10; "Total Area (Project)"; Decimal)
        {
            Caption = 'Total Area (Projected)';
        }

        field(26; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'VPP,MOP,Flat,Garage,Parking,Storage';
            OptionMembers = ВПП,МОП,apartment,garage,parking,pantry;
        }

        field(27; "Origin Type"; Text[60])
        {
            Caption = 'Origin Type';
        }

    }

    keys
    {
        key(Key1; "Object No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

}
