table 70018 "Projects Structure"
{
    Caption = 'Project Structure';
    DataClassification = CustomerContent;
    //DrillDownPageID = 70122;
    //LookupPageID = 70122;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';

            trigger OnLookup()
            begin
                // BuildPtoject.Filtergroup(2);
                // BuildPtoject.SetFilter("Development/Production", Erpc.GetBldPrjTypeFilter);
                // BuildPtoject.Filtergroup(0);
                // IF Page.RunModal(0, BuildPtoject) = Action::LookupOK THEN
                //     Code := BuildPtoject.Code;
            end;

            trigger OnValidate();
            begin
                // if Code <> '' then
                //     Erpc.TestBuildPtojectectCode(Code, 70050);
            end;
        }
        // field(2; Description; Text[250])
        // {
        //     Caption = 'Description';
        // }
        field(3; Type; Option)
        {
            Caption = 'Analysis type';
            OptionCaption = 'Investment Calculation,Detailed Planning,Estimate Calculation';
            OptionMembers = "Investment Calculation","Detailed Planning","Estimate Calculation";
        }
        // field(4; Template; Boolean)
        // {
        //     Caption = 'Template';
        // }
        // field(5; Version; Code[20])
        // {
        //     Caption = 'Version';
        // }
        // field(6; "Fixed"; Boolean)
        // {
        //     Caption = 'Fixing';
        // }
        // field(7; "Create User"; Code[20])
        // {
        //     Caption = 'Create User';
        // }
        // field(8; "Create Date"; Date)
        // {
        //     Caption = 'Create date';
        // }
        field(81; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            Editable = true;
            TableRelation = Dimension;
        }
        field(82; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            Editable = true;
            TableRelation = Dimension;
        }
        field(83; "Shortcut Dimension 3 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 3 Code';
            TableRelation = Dimension;
        }
        field(84; "Shortcut Dimension 4 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 4 Code';
            TableRelation = Dimension;
        }
        field(85; "Shortcut Dimension 5 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 5 Code';
            TableRelation = Dimension;
        }
        field(86; "Shortcut Dimension 6 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 6 Code';
            TableRelation = Dimension;
        }
        field(87; "Shortcut Dimension 7 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 7 Code';
            TableRelation = Dimension;
        }
        field(88; "Shortcut Dimension 8 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 8 Code';
            TableRelation = Dimension;
        }
        field(89; LastVersion; Integer)
        {
            Caption = 'LastVersion';
        }
        // field(90; "Template Code"; Code[20])
        // {
        //     Caption = 'Template Code';
        // }
        // field(91; LastVersionFrc; Integer)
        // {
        //     Caption = 'LastVersionFrc';
        // }
        // field(92; "Company Name"; Text[100])
        // {
        //     Caption = 'Company Name';
        //     TableRelation = Company;
        // }
        // field(60088; "Original Company"; Code[2])
        // {
        //     Caption = 'Original Company';
        // }
        // field(70000; "Development/Production"; Option)
        // {
        //     CalcFormula = Lookup("Building project"."Development/Production" where(Code = field(Code)));
        //     Caption = 'Development/Production';
        //     FieldClass = FlowField;
        //     OptionMembers = " ",Development,Production;
        // }
    }
    keys
    {
        key(Key1; "Code", Type)
        {
            Clustered = true;
        }
    }

    // trigger OnInsert();
    // begin
    //     "Company Name" := CompanyName();
    // end;

    var
        Dim: Record Dimension;
        //Erpc: Codeunit Codeunit70000;
        BuildPtoject: Record "Building project";
}

