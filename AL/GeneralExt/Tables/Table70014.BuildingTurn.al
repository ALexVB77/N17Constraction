table 70014 "Building Turn"
{
    Caption = 'Construction Queue';
    //DrillDownPageID = 70113;
    //LookupPageID = 70113;
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        // field(2; Descriotion; Text[250])
        // {
        //     Caption = 'Description';
        // }
        // field(3; "Build address"; Text[250])
        // {
        //     Caption = 'Construction Adress';
        // }
        // field(4; "Police address"; Text[250])
        // {
        //     Caption = 'Policy Adress';
        // }
        // field(5; "Starting Date"; Date)
        // {
        //     Caption = 'Start Date';
        // }
        // field(6; "Ending Date (Plan)"; Date)
        // {
        //     Caption = 'Delivery Date';
        // }
        // field(7; "Ending Date (Fact)"; Date)
        // {
        //     Caption = 'Delivery Date (fact)';
        // }
        field(18; "Building project Code"; Code[20])
        {
            Caption = 'Project Code';
            TableRelation = "Building project";
        }
        // field(19; Sections; Integer)
        // {
        //     CalcFormula = Count(Sections where("Building turn Code" = field(Code)));
        //     FieldClass = FlowField;
        // }
        // field(20; "Number of Storeys From"; Integer)
        // {
        //     Caption = 'Number of Storeys From';
        // }
        // field(21; "Number of Storeys To"; Integer)
        // {
        //     Caption = 'Number of Storeys To';
        // }
        // field(22; "Available in sales"; Boolean)
        // {
        //     Caption = 'Available in sales';
        // }
        // field(23; "Dev. Starting Date"; Date)
        // {
        //     Caption = 'Start date';
        // }
        // field(24; "Dev. Ending Date"; Date)
        // {
        //     Caption = 'End date';
        // }
        // field(25; "Dev. Ending Date (Fact)"; Date)
        // {
        //     Caption = 'Ending date';
        // }
        field(26; "Turn Dimension Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';

            // trigger OnLookup();
            // begin
            //     grDevSetup.Get;
            //     grDevSetup.TestField(grDevSetup."Project Turn Dimension Code");

            //     grDimValue.SetRnage("Dimension Code", grDevSetup."Project Turn Dimension Code");
            //     if grDimValue.Find('-') then begin
            //         if Page.RunModal(Page::"Dimension Values", grDimValue) = ACTION::LookupOK THEN
            //             "Turn Dimension Code" := grDimValue.Code;
            //     end
            // end;
        }
        // field(27; "Analysis Type"; Option)
        // {
        //     Caption = 'Analysis type';
        //     FieldClass = FlowFilter;
        //     OptionCaption = 'Investment Calculation,Detailed Planning,Estimate Calculation';
        //     OptionMembers = "Investment Calculation","Detailed Planning","Estimate Calculation";
        // }
        // field(28; "Version Code"; Code[20])
        // {
        //     Caption = 'Version Code';
        //     FieldClass = FlowFilter;
        // }
        // field(29; "Line No."; Integer)
        // {
        //     Caption = 'Line No.';
        //     FieldClass = FlowFilter;
        // }
        // field(30; "Date Flter"; Date)
        // {
        //     Caption = 'Date Flter';
        //     FieldClass = FlowFilter;
        // }
        // field(31; Amount; Decimal)
        // {
        //     Caption = 'Amount';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Amount (LCY)" where("Project Code" = field("Building project Code"), "Analysis Type" = field("Analysis Type"), "Version Code" = field("Version Code"), "Line No." = field("Line No."), Date = field("Date Flter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Project Turn Code" = field(Code), Reserv = field("Reserv FLT"), "Agrrement No." = field("Agreement FLT"), Close = field("Close FLT")));
        // }
        // field(32; "Fixed Filter"; Boolean)
        // {
        //     Caption = 'Fixed Filter';
        //     FieldClass = FlowFilter;
        // }
        // field(33; "Create Date Filter"; Date)
        // {
        //     Caption = 'Create Date Filter';
        //     FieldClass = FlowFilter;
        // }
        // field(34; VAT; Decimal)
        // {
        //     CalcFormula = Sum("Projects Budget Entry Link".VAT where("Project Code" = field("Building project Code"), "Analysis Type" = field("Analysis Type"), "Version Code" = field("Version Code"), "Line No." = field("Line No."), Date = field("Date Flter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Project Turn Code" = field(Code), Reserv = field("Reserv FLT"), "Agrrement No." = field("Agreement FLT"), Close = field("Close FLT")));
        //     Caption = 'VAT';
        //     FieldClass = FlowField;
        // }
        // field(35; "Without VAT"; Decimal)
        // {
        //     Caption = 'Not VAT';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Project Turn Code" = field(TurnFlt), Date = field("Date Flter"), "Line No." = field("Line No.")));
        // }
        // field(36; "Fact Amount"; Decimal)
        // {
        //     Caption = 'Fact Amount';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Amount (LCY)" where("Project Code" = field("Building project Code"), "Analysis Type" = field("Analysis Type"), "Version Code" = field("Version Code"), "Line No." = field("Line No."), Date = field("Date Flter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Project Turn Code" = field(Code), Close = CONST(true)));
        // }
        // field(37; "Fact VAT"; Decimal)
        // {
        //     Caption = 'VAT';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link".VAT where("Project Code" = field("Building project Code"), "Analysis Type" = field("Analysis Type"), "Version Code" = field("Version Code"), "Line No." = field("Line No."), Date = field("Date Flter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Project Turn Code" = field(Code), Close = CONST(true)));
        // }
        // field(38; "Fact Without VAT"; Decimal)
        // {
        //     Caption = 'Not VAT';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = field("Analysis Type"), "Version Code" = field("Version Code"), "Line No." = field("Line No."), Date = field("Date Flter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Project Turn Code" = field(Code), Close = CONST(true)));
        // }
        // field(51; "Close FLT"; Boolean)
        // {
        //     Caption = 'Close FLT';
        //     FieldClass = FlowFilter;
        // }
        // field(52; "Agreement FLT"; Code[20])
        // {
        //     Caption = 'Agreement FLT';
        //     FieldClass = FlowFilter;
        // }
        // field(53; "Reserv FLT"; Boolean)
        // {
        //     Caption = 'Reserv FLT';
        //     FieldClass = FlowFilter;
        // }
        // field(57; "CMPPro Code"; Text[30])
        // {
        //     Caption = 'CMPPro Code';
        // }
        // field(58; "Original Budget"; Decimal)
        // {
        //     Caption = 'Original Budget';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const("Fix Budget"), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt")));
        // }
        // field(59; "Current Budget"; Decimal)
        // {
        //     Caption = 'Current Budget';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const("Current Budget"), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Version Code" = field("Version Code"), "Cost Type" = field("CostType Flt")));

        // }
        // field(61; Actual; Decimal)
        // {
        //     Caption = 'Actual';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(Actuals), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt")));
        // }
        // field(62; Committed; Decimal)
        // {
        //     Caption = 'Committed';
        // }
        // field(63; Forecast; Decimal)
        // {
        //     Caption = 'Forecast';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(Forecast), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt"), "Version Code" = field("Version Code")));
        // }
        // field(64; Group; Boolean)
        // {
        //     Caption = 'Group';
        // }
        // field(65; TurnFlt; Code[20])
        // {
        //     Caption = 'TurnFlt';
        //     FieldClass = FlowFilter;
        // }
        // field(66; "CostType Flt"; Code[20])
        // {
        //     Caption = 'CostType Flt';
        //     FieldClass = FlowFilter;
        // }
        field(67; Sort; Integer)
        {
            Caption = 'Sort';
        }
        // field(68; Advances; Decimal)
        // {
        //     Caption = 'Advances';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(Adv), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt")));
        // }
        // field(69; CashFlow; Decimal)
        // {
        //     Caption = 'CashFlow';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(CashFlow), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt"), Date = field("Date Flter")));
        // }
        // field(70; "Forecast Prev"; Decimal)
        // {
        //     Caption = 'Forecast Prev';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(PrevForecast), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt"), "Version Code" = field("Forecast Version Flt")));
        // }
        // field(71; "Forecast Version Flt"; Code[20])
        // {
        //     Caption = 'Forecast Version Flt';
        //     FieldClass = FlowFilter;
        // }
        // field(72; "Actual Alloc"; Decimal)
        // {
        //     Caption = 'Actual Alloc';
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(AllocActuals), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt")));
        //     FieldClass = FlowField;
        // }
        // field(73; "Forecast Alloc"; Decimal)
        // {
        //     Caption = 'Forecast Alloc';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(AllocForecast), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt")));
        // }
        // field(74; "Forecast Appr"; Decimal)
        // {
        //     Caption = 'Forecast Appr';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(ApprForecast), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt")));
        // }
        // field(75; "period Flt"; Code[20])
        // {
        //     Caption = 'period Flt';
        //     FieldClass = FlowFilter;
        // }
        // field(86; "PrevForecast Appr"; Decimal)
        // {
        //     Caption = 'PrevForecast Appr';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Building project Code"), "Analysis Type" = const(PrevApprForecast), "Line No." = field("Line No."), "Project Turn Code" = field(TurnFlt), "Cost Type" = field("CostType Flt")));
        // }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; Sort)
        {
        }
        key(Key3; "Turn Dimension Code")
        {
        }
    }

    trigger OnDelete();
    begin
        PCCE.Reset;
        PCCE.SetRange("Project Turn Code", Code);
        if not PCCE.IsEmpty then
            Error(Text001);
    end;

    var
        // grDevSetup: Record "Development Setup";
        // grDimValue: Record "Dimension Value";
        PCCE: Record "Projects Cost Control Entry";
        Text001: Label 'You cannot delete queue. There are project data exist.';
}

