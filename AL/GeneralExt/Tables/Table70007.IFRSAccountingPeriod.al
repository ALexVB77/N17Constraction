table 70007 "IFRS Accounting Period"
{
    Caption = 'IFRS Accounting Period';
    LookupPageID = "IFRS Accounting Periods";

    fields
    {
        field(1; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            NotBlank = true;

            trigger OnValidate()
            begin
                Name := Format("Starting Date", 0, Text000);
            end;
        }
        field(2; Name; Text[10])
        {
            Caption = 'Name';
        }
        field(4; "Period Closed"; Boolean)
        {
            Caption = 'Period Closed';
        }
        field(10; "Last Modified Date Time"; DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }
        field(11; "Last Modified User ID"; code[50])
        {
            Caption = 'Last Modified User ID';
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "Starting Date")
        {
            Clustered = true;
        }
        key(Key2; "Period Closed")
        {
        }
    }

    trigger OnDelete()
    begin
        TestField("Period Closed", false);
    end;

    trigger OnInsert()
    begin
        AccountingPeriod2 := Rec;
        if AccountingPeriod2.Find('>') then
            AccountingPeriod2.TestField("Period Closed", false);
    end;

    trigger OnRename()
    begin
        TestField("Period Closed", false);
        AccountingPeriod2 := Rec;
        if AccountingPeriod2.Find('>') then
            AccountingPeriod2.TestField("Period Closed", false);
    end;

    var
        Text000: Label '<Month Text,10>', Locked = true;
        AccountingPeriod2: Record "IFRS Accounting Period";
}

