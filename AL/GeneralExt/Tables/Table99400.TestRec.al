table 99400 "Test rec"
{
    DataClassification = ToBeClassified;
    Caption = 'Test Rec';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Entry No.';

        }
        field(10; Name; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Name';

        }

    }

    keys
    {
        key(Key1; "Entry No.")
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
