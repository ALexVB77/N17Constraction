table 70049 "Web Request Queue"
{
    Caption = 'Web Request Queue';

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
        }

        field(10; "Worker Code"; Code[10])
        {
            Caption = 'Worker Code';
            TableRelation = "Web Request Worker Setup";
        }

        field(20; "Request Body"; Blob)
        {
            Caption = 'Request Body';

        }
        field(21; "Datetime creating"; DateTime)
        {
            Caption = 'Datetime creating';
        }

        field(22; "Datetime processing"; DateTime)
        {
            Caption = 'Datetime processing';
        }

        field(30; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = New,Complete,"Processing Error";
            OptionCaption = 'New,Complete,Processing Error';
        }

        field(31; "Error Message"; Text[2024])
        {
            Caption = 'Error Message';
        }

    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
        key(Key2; "Datetime creating")
        {
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
