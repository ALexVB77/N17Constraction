table 70047 "BW Translation Entry"
{
    DataClassification = ToBeClassified;
    Caption = 'BW Translation Entry';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = ToBeClassified;
            Caption = 'Entry No.';

        }
        field(10; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';

        }

        field(11; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Posting Date';

        }

        field(12; "Period"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Period';

        }


        field(13; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Document Date';

        }


        field(14; "G/L Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'G/L Account No.';

        }

        field(15; "BW Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BW Account No.';

        }

        field(16; "Source No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source No.';

        }

        field(17; "Cost Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Cost Code';

        }

        field(18; "Cost Place"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Cost Place';

        }


        field(19; "Amount (LCY)"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Amount (LCY)';

        }

        field(20; "Currency Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Currency Code';

        }

    }

    keys
    {
        key(Key1; "Entry No.")
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
