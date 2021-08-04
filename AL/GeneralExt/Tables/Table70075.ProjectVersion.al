table 70075 "Project Version"
{
    Caption = 'Project Version';
    Description = 'NC 50085 PA';
    //LookupPageId = "Project Version";
    //DrillDownPageId = "Project Version";

    fields
    {
        field(1; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            TableRelation = "Building Project";
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
        field(8; "Analysis Type"; Option)
        {
            Caption = 'Analysis Type';
            OptionMembers = "Investment Calculation","Detailed Planning","Estimate Calculation";
            OptionCaption = 'Investment Calculation,Detailed Planning,Estimate Calculation';
        }
        field(9; "Fixed Version"; Boolean)
        {
            Caption = 'Fixed Version';
        }
        field(10; "Fixed User"; Code[20])
        {
            Caption = 'Fixed User';
        }
        field(11; "Fixed Date"; Date)
        {
            Caption = 'Fixed Date';
        }
        field(13; Int; Integer)
        {
            Caption = 'Int';
        }
        field(14; "Archive Version"; Boolean)
        {
            Caption = 'Archive Version';
        }
        field(15; "Archive User"; Code[20])
        {
            Caption = 'Archive User';
        }
        field(16; "Archive Date"; Date)
        {
            Caption = 'Archive Date';
        }
        field(17; "Version Date"; Date)
        {
            Caption = 'Version Date';
        }
        field(18; "No Show"; Boolean)
        {
            Caption = 'No Show';
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
            Enabled = true;
        }
        key(Key2; "Version Date")
        {
            Enabled = true;
        }
        key(Key3; Int)
        {
            Enabled = true;
        }
    }

    var
        grPrjVer: Record "Project Version";
        grDevelopmentSetup: Record "Development Setup";

    trigger OnInsert()
    begin
        if "Version Code" = '' then begin
            "Version Code" := GetNextVersion;
            grPrjVer.SetCurrentKey(Int);
            grPrjVer.SetRange("Project Code", "Project Code");
            grPrjVer.SetRange("Analysis Type", "Analysis Type");
            if grPrjVer.FindLast then
                Int := grPrjVer.Int + 1;
        end;

        "Version Date" := Today;
    end;

    procedure GetNextVersion() Ret: Code[20]
    begin
        grPrjVer.SETRANGE("Project Code", "Project Code");
        grPrjVer.SETRANGE("Analysis Type", "Analysis Type");
        if grPrjVer.FindLast() then begin
            grDevelopmentSetup.Get;
            grDevelopmentSetup.TestField("Pref Vesion Code");
            Ret := grDevelopmentSetup."Pref Vesion Code" + Format(grPrjVer.Int + 1);
        end;
    end;
}