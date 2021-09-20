table 70045 "BW Account"
{
    DataClassification = ToBeClassified;
    Caption = 'BW Account';

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No.';

        }
        field(2; Name; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Name';

        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

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
