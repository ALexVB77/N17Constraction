table 70053 "Investment Object"
{
    Caption = 'Investment Object';
    LookupPageID = "Investment Agreements";
    DrillDownPageID = "Investment Agreements";
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

        field(26; Type; Enum "Investment Object Type")
        {
            Caption = 'Type';
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
