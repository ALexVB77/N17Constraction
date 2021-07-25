table 99881 "BW Dimension"
{
    DataClassification = ToBeClassified;
    Caption = 'BW Dimension';

    fields
    {
        field(1; "Type"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Type';

        }
        field(2; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Code';

        }

        field(10; Name; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Name';

        }

        field(20; Blocked; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Blocked';

        }

    }

    keys
    {
        key(Key1; Type, Code)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
