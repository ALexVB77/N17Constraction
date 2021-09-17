table 50005 "Act Stage"
{
    Caption = 'Act Stage';
    LookupPageID = "Act Stage";
    DrillDownPageID = "Act Stage";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Stage Code"; Code[30])
        {
            Caption = 'Stage';
            DataClassification = ToBeClassified;
        }

        field(2; "Stage Description"; Text[250])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }

        field(3; Ordering; Integer)
        {
            Caption = 'Procedure';
            DataClassification = ToBeClassified;
        }

        field(4; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = ToBeClassified;
        }

    }


    keys
    {
        key(Key1; "Stage Code")
        {
            Clustered = true;

        }
        key(Key2; Ordering)
        {

        }
    }

    fieldgroups
    {
    }

    var
        grActStage: record "Act Stage";

}


