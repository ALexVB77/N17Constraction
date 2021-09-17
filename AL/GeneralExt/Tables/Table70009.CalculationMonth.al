table 70009 "Calculation Month"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Mes; Integer)
        {
            Caption = 'Month';
            DataClassification = ToBeClassified;
            MinValue = 1;
            MaxValue = 12;
        }
        field(50000; Year; Integer)
        {
            Caption = 'Year';
            DataClassification = ToBeClassified;

        }
        field(50001; Name; Text[60])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(Key1; Year, Mes)
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