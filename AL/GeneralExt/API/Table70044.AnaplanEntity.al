table 70044 "Anaplan Entity"
{
    Caption = 'Anaplan Entity';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Verification Number"; BigInteger)
        {
            DataClassification = ToBeClassified;
            Caption = 'Verification Number', Locked = true;

        }
        field(10; "Verification Type"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Verification Type', Locked = true;

        }


        field(20; "Date Time Uploading"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Date Time Uploading', Locked = true;

        }

        field(30; "ERP Project"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'ERP Project', Locked = true;

        }

        field(40; "Legal Entity"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Legal Entity', Locked = true;

        }


        field(50; "Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Account', Locked = true;

        }
        field(60; Activity; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Activity', Locked = true;

        }
        field(70; "Accounting Period"; Text[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Accounting Period', Locked = true;

        }
        field(80; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Posting Date', Locked = true;

        }
        field(90; "Base Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Base Amount', Locked = true;

        }
        field(100; "Base Amount Sign"; Text[1])
        {
            DataClassification = ToBeClassified;
            Caption = 'Base Amount Sign', Locked = true;

        }
        field(110; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Currency Code', Locked = true;

        }
        field(120; "Agreement No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Agreement No.', Locked = true;

        }
        field(130; "External Agreement No."; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'External Agreement No.', Locked = true;

        }
        field(140; "Supplier No."; Code[20])
        {
            TableRelation = Vendor;
            DataClassification = ToBeClassified;
            Caption = 'Supplier No.', Locked = true;

        }

        field(150; "Supplier Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Supplier Name', Locked = true;

        }

    }

    keys
    {
        key(KP; "Verification Number")
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
