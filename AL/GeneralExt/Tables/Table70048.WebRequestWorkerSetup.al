table 70048 "Web Request Worker Setup"
{
    Caption = ' Web Request Worker';
    DataPerCompany = false;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';

        }

        field(10; CodeunitId; Integer)
        {
            Caption = 'Codeunit Id';
        }

        field(11; FailureCodeunitId; Integer)
        {
            Caption = 'Failure Codeunit Id';
        }

    }

    keys
    {
        key(Key1; Code)
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
