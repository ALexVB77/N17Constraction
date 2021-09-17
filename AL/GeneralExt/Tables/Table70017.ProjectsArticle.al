table 70017 "Projects Article"
{
    Caption = 'Project Line';
    DataClassification = CustomerContent;
    //DrillDownPageID = 70115;
    //LookupPageID = 70115;
    fields
    {
        field(1; "Code"; Text[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
        }
        // field(3; "Structure Type"; Option)
        // {
        //     Caption = 'Structure Type';
        //     OptionCaption = 'Investment,Construction';
        //     OptionMembers = Investment,Construction;
        // }
        // field(4; "Structure Post Type"; Option)
        // {
        //     Caption = 'Job Task Type';
        //     OptionCaption = 'Posting,Heading,Total,Begin-Total,End-Total';
        //     OptionMembers = Posting,Heading,Total,"Begin-Total","End-Total";
        // }
        field(5; Sequence; Integer)
        {
            Caption = 'Succession';
        }
        field(6; "By Building turn"; Boolean)
        {
            Caption = 'In terms of queuing';
        }
        field(8; "Repeat Interval"; DateFormula)
        {
            Caption = 'Repeat Interval';
        }
        // field(50; "Exist Dim"; Code[20])
        // {
        //     CalcFormula = Lookup("Default Dimension"."Dimension Value Code" where("Table ID" = const(70071), "No." = field(Code), "Dimension Code" = const('CC')));
        //     Caption = 'Exist Dim';
        //     FieldClass = FlowField;
        // }
        // field(51; "Exist Prj Line"; Boolean)
        // {
        //     CalcFormula = Exist("Projects Structure Lines" where(Code = field(Code)));
        //     Caption = 'Exist Prj Line';
        //     FieldClass = FlowField;
        // }
    }
    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}

