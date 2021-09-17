table 70023 "Projects Budget Entry Link"
{
    Caption = 'Projects Budget Entry Link';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            TableRelation = "Building project";
        }
        field(3; "Analysis Type"; Option)
        {
            Caption = 'Analysis type';
            OptionCaption = 'Investment Calculation,Detailed Planning,Estimate Calculation';
            OptionMembers = "Investment Calculation","Detailed Planning","Estimate Calculation";
        }
        field(4; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(6; "Main Entry No."; Integer)
        {
            Caption = 'Main Entry No.';
        }
        // field(7; Description; Text[250])
        // {
        //     Caption = 'Description';
        // }
        // field(8; "Description 2"; Text[250])
        // {
        //     Caption = 'Description 2';
        // }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate();
            begin
                if Curency = '' then begin
                    "Amount (LCY)" := Amount;
                End;

                if not gvCreateRepeat then
                    CreateRepeatEntry;

                New := false;
            End;
        }
        field(10; Curency; Code[20])
        {
            Caption = 'Curency';
        }
        // field(11; "Currency Factor"; Decimal)
        // {
        //     Caption = 'Currency Factor';
        // }
        field(12; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(13; Date; Date)
        {
            Caption = 'Date';
        }
        field(20; "Create User"; Code[20])
        {
            Caption = 'Create User';
        }
        field(21; "Create Date"; Date)
        {
            Caption = 'Create Date';
        }
        field(22; "Create Time"; Time)
        {
            Caption = 'Create Time';
        }
        field(23; "Parent Entry"; Integer)
        {
            Caption = 'Parent Entry';
        }
        field(24; "Project Turn Code"; Code[20])
        {
            Caption = 'Project Turn Code';
        }
        field(25; New; Boolean)
        {
            Caption = 'New';
        }
        field(26; "Fixed Version"; Boolean)
        {
            Caption = 'Fixed Version';
        }
        field(33; VAT; Decimal)
        {
            Caption = 'VAT';
        }
        field(34; "Without VAT"; Decimal)
        {
            Caption = 'Without VAT';
        }
        field(35; "Build Turn"; Code[20])
        {
            Caption = 'Build Turn';
        }
        field(36; Close; Boolean)
        {
            Caption = 'Close';
        }
        field(51; "Work Version"; Boolean)
        {
            Caption = 'Work Version';
        }
        // field(52; "Contragent No."; Code[20])
        // {
        //     Caption = 'Contragent No.';
        // }
        field(53; "Agrrement No."; Code[20])
        {
            Caption = 'Agrrement No.';
        }
        field(54; Reserv; Boolean)
        {
            Caption = 'Reserv';
        }
        // field(55; NEWL; Boolean)
        // {
        //     Caption = 'NEWL';
        // }
        // field(60088; "Original Company"; Code[2])
        // {
        //     Caption = 'Original Company';
        // }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
            Clustered = True;
        }
        key(Key2; "Project Code", "Analysis Type", "Version Code", "Line No.", "Entry No.", "Project Turn Code")
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key3; "Project Code", "Analysis Type", "Version Code", "Line No.", Date, "Fixed Version", "Create Date", "Project Turn Code")
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key4; Date)
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key5; "Project Code", "Analysis Type", "Version Code", "Line No.", "Project Turn Code", "Parent Entry", Date)
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key6; "Main Entry No.", "Project Code", "Analysis Type", "Version Code", "Line No.", Date, "Fixed Version", "Create Date", "Project Turn Code")
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key7; "Project Code", "Analysis Type", "Version Code", "Line No.", "Build Turn")
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key8; "Project Code", "Analysis Type", "Version Code", "Line No.", "Build Turn", Close)
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key9; "Project Code", "Analysis Type", "Version Code", "Line No.", "Project Turn Code", "Parent Entry", Date, Close)
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key10; "Main Entry No.", "Project Code", "Analysis Type", "Version Code", "Line No.", Date, "Fixed Version", "Create Date", "Project Turn Code", Close)
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key11; "Main Entry No.", "Project Code", "Analysis Type", "Version Code", "Line No.", Date, "Fixed Version", "Create Date", "Project Turn Code", Close, "Work Version")
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
        key(Key12; "Project Code", "Analysis Type", "Version Code", "Line No.", Date, "Fixed Version", "Create Date", "Project Turn Code", Close, "Agrrement No.", Reserv)
        {
            SumIndexFields = Amount, "Amount (LCY)", VAT, "Without VAT";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert();
    var
        CodeMonkeyTranslation: Codeunit "Code Monkey Translation";
        VATRate: Decimal;
    begin
        "Create User" := UserId;
        "Create Date" := Today;
        "Create Time" := Time;
        grProjectsBudgetEntry.SetRange("Project Code", "Project Code");
        grProjectsBudgetEntry.SetRange("Analysis Type", "Analysis Type");
        grProjectsBudgetEntry.SetRange("Version Code", "Version Code");
        grProjectsBudgetEntry.SetRange("Entry No.", "Main Entry No.");

        if WorkDate() >= 20190101D then
            VATRate := 1.2
        else
            VATRate := 1.18;

        if grProjectsBudgetEntry.Find('-') then begin
            if grProjectsBudgetEntry."Including VAT" then begin
                if Amount <> 0 then begin
                    VAT := Amount - ROUND(Amount / VATRate, 0.01);
                    "Without VAT" := Amount - VAT;
                end else begin
                    Amount := ROUND("Without VAT" * VATRate, 0.01);
                    VAT := Amount - "Without VAT";
                end
            end else begin
                VAT := 0;
                if Amount <> 0 then
                    "Without VAT" := Amount
                else
                    Amount := "Without VAT";
            End;
        end else begin
            VAT := 0;
            if Amount <> 0 then
                "Without VAT" := Amount
            else
                Amount := "Without VAT";
        End;
        "Amount (LCY)" := Amount;
    End;

    var
        grProjectsStructureLines: Record "Projects Structure Lines";
        grProjectsLineDimension: Record "Projects Line Dimension";
        grProjectsLineDimension1: Record "Projects Line Dimension";
        grBuildingProect: Record "Building project";
        grDevelopmentSetup: Record "Development Setup";
        ProjectsLineDimension: Record "Projects Line Dimension";
        grProjectsBudgetEntry: Record "Projects Budget Entry";
        gvCreateRepeat: Boolean;
        Text001: Label 'Create a periodic entries for\%1 ?';
        Text002: Label 'You must specify the ending date of the project!';
        Text003: Label 'Update related entries?';

    local procedure GetNextEntryNo(): Integer;
    var
        GLBudgetEntry: Record "Projects Budget Entry";
    begin
        GLBudgetEntry.SetCurrentKey("Entry No.");
        if GLBudgetEntry.Find('+') then
            Exit(GLBudgetEntry."Entry No." + 1)
        else
            Exit(1);
    End;

    procedure CreateRepeatEntry();
    var
        lrProjectsBudgetEntry: Record "Projects Budget Entry";
        lrProjectsStructureLines: Record "Projects Structure Lines";
        lrBuildingProject: Record "Building project";
        lEndingDate: Date;
        lrDate: Date;
        lvLastEntry: Integer;
    begin
        if New then begin
            lrProjectsStructureLines.SetRange("Project Code", "Project Code");
            lrProjectsStructureLines.SetRange(Type, "Analysis Type");
            lrProjectsStructureLines.SetRange(Version, "Version Code");
            lrProjectsStructureLines.SetRange("Line No.", "Line No.");
            if lrProjectsStructureLines.Find('-') then begin
                if Format(lrProjectsStructureLines."Repeat Interval") <> '' then begin
                    if Confirm(StrSubStNo(Text001, lrProjectsStructureLines.Description)) then begin
                        if lrProjectsStructureLines."Ending Date" = 0D then begin
                            lrBuildingProject.Get("Project Code");
                            if lrBuildingProject."Dev. Ending Date" = 0D then
                                Error(Text002)
                            else
                                lEndingDate := lrBuildingProject."Dev. Ending Date";
                        end else
                            lEndingDate := lrProjectsStructureLines."Ending Date";
                        "Parent Entry" := "Entry No.";
                        lrDate := Date;
                        lvLastEntry := GetNextEntryNo;
                        Repeat
                            lrDate := CALCDATE(lrProjectsStructureLines."Repeat Interval", lrDate);
                            if lrDate <= lEndingDate then begin
                                CLEAR(lrProjectsBudgetEntry);
                                lrProjectsBudgetEntry.SetCreateRepeat(True);
                                lrProjectsBudgetEntry.INIT;
                                lrProjectsBudgetEntry.COPY(Rec);
                                lvLastEntry := lvLastEntry + 1;
                                lrProjectsBudgetEntry."Entry No." := lvLastEntry;
                                lrProjectsBudgetEntry.Date := lrDate;
                                lrProjectsBudgetEntry.INSERT(True);
                            End;
                        Until (lrDate > lEndingDate);
                    End;
                End;
            End;
        End else begin
            if "Parent Entry" <> 0 then begin
                if Confirm(StrSubStNo(Text003, lrProjectsStructureLines.Description)) then begin
                    lrProjectsBudgetEntry.SetRange("Project Code", "Project Code");
                    lrProjectsBudgetEntry.SetRange("Analysis Type", "Analysis Type");
                    lrProjectsBudgetEntry.SetRange("Version Code", "Version Code");
                    lrProjectsBudgetEntry.SetRange("Line No.", "Line No.");
                    lrProjectsBudgetEntry.SetRange("Parent Entry", "Parent Entry");
                    lrProjectsBudgetEntry.SETFILTER("Entry No.", '<>%1', "Entry No.");
                    if lrProjectsBudgetEntry.Find('-') then begin
                        Repeat
                            lrProjectsBudgetEntry.SetCreateRepeat(True);
                            lrProjectsBudgetEntry.Validate(Amount, Amount);
                            lrProjectsBudgetEntry.MODIFY;
                        Until lrProjectsBudgetEntry.NEXT = 0;
                    End;
                End;
            End;
        End;
    End;

    procedure SetCreateRepeat(lvCreateRepeat: Boolean);
    begin
        gvCreateRepeat := lvCreateRepeat;
    End;
}

