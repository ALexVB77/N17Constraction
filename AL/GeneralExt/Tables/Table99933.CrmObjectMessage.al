table 99933 "Crm Object Message"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; MessageId; Guid)
        {
            Caption = 'MessageId', Locked = true;

        }

        field(2; Id; Guid)
        {
            Caption = 'OData Key Field ', Locked = true;

        }


        field(10; Name; Text[250])
        {
            Caption = 'Name', Locked = true;
        }

        field(11; "Is Active"; Boolean)
        {
            Caption = 'Is Active', Locked = true;
        }

        field(12; "Posting Date"; Date)
        {
            Caption = 'Posting Date', Locked = true;
        }

        field(13; Amount; Decimal)
        {
            Caption = 'Amount', Locked = true;
        }

        field(14; "Crm Object Json"; Blob)
        {
            Caption = 'Crm Object Json', Locked = true;
        }


        field(20; "Receive Datetime"; DateTime)
        {
            Caption = 'Receive Datetime', Locked = true;
        }


    }

    keys
    {
        key(Key1; MessageId)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        Id := CreateGuid();
        MessageId := Id;
        "Receive Datetime" := CurrentDateTime();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    var
        RenameErr: Label 'Rename is not allowed', Locked = true;
    begin
        Error('RenameErr')
    end;

}
