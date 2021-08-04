table 70107 "Forecast Version"
{
    // LookupPageID = "Projects Version";
    // DrillDownPageID = Page70119;    

    fields
    {
        field(1; "Project Code"; Code[20])
        {
            TableRelation = "Building project";
            Caption = 'Project Code';

        }

        field(2; "Version Code"; Code[20])
        {
            Caption = 'Version Code';

        }

        field(3; Description; Text[250])
        {
            Caption = 'Description';

        }

        field(4; "Create User"; Code[20])
        {
            Caption = 'Create User';

        }

        field(5; "Create Date"; Date)
        {
            Caption = 'Create Date';

        }

        field(6; "Last Modify Date"; Date)
        {
            Caption = 'Last Modify Date';

        }

        field(7; "First Version"; Boolean)
        {
            Caption = 'First Version';

        }

        field(8; "Version Date"; Date)
        {
            Caption = 'Version Date';

        }

        field(9; Int; Integer)
        {
            Caption = 'Int';
        }

        field(60088; "Original Company"; Code[2])
        {
            Caption = 'Original Company';
        }


    }


    keys
    {
        key(Key1; "Project Code", "Version Code")
        {
            Clustered = true;

        }
        key(Key2; "Version Date")
        {

        }
        key(Key3; Int)
        {

        }
    }


    fieldgroups
    {
    }
    trigger OnInsert()
    begin
        //IF Description = '' THEN BEGIN
        //  Description:=GetNextVersion;
        //   grPrjStr.SETRANGE(Code,"Project Code");
        //   IF grPrjStr.FIND('-') THEN
        //   BEGIN
        //     grPrjStr.LastVersionFrc:=grPrjStr.LastVersionFrc+1;
        //     Int:=grPrjStr.LastVersionFrc+1;
        //     grPrjStr.MODIFY;
        //   END;
        // //END;
        "Create Date" := TODAY;
    end;



    var
        // grPrjStr: record "Projects Structure";
        grDevelopmentSetup: record "Development Setup";


    procedure GetNextVersion() Ret: code[20]
    begin
        // grPrjStr.SETRANGE(Code,"Project Code");
        // IF grPrjStr.FIND('-') THEN
        // BEGIN
        //   grDevelopmentSetup.GET;
        //   grDevelopmentSetup.TESTFIELD("Pref Forecast Code");
        //   Ret:=grDevelopmentSetup."Pref Forecast Code"+FORMAT(grPrjStr.LastVersionFrc+1);
        // END;
    end;


}