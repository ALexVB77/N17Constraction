table 70019 "Projects Structure Lines"
{
    Caption = 'Projects Structure Lines';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            TableRelation = "Building project";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            NotBlank = true;
        }
        field(3; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = "Projects Article";

            trigger OnValidate();
            begin
                if "Line No." = 0 then
                    exit;
                if ProjectsArticle.Get(Code) then begin
                    Description := ProjectsArticle.Description;
                    "By Building turn" := ProjectsArticle."By Building turn";
                    "Repeat Interval" := ProjectsArticle."Repeat Interval";
                end else begin
                    clear("Repeat Interval");
                    Description := '';
                    "By Building turn" := false;
                end;

                CopyDimentions(Code);
            end;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(5; "Structure Post Type"; Option)
        {
            Caption = 'Job Task Type';
            OptionCaption = 'Posting,Heading,Total,Begin-Total,End-Total';
            OptionMembers = Posting,Heading,Total,"Begin-Total","End-Total";
        }
        field(6; "By Building turn"; Boolean)
        {
            Caption = 'In terms of queuing';
        }
        // field(7; Totaling; Text[250])
        // {
        //     Caption = 'Totaling';
        // }
        // field(8; Indentation; Integer)
        // {
        //     Caption = 'Ident';
        // }
        field(9; Version; Code[20])
        {
            Caption = 'Version';
        }
        field(12; "Project Dimension 1 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(1);
            Caption = 'Budget Dimension 1 Code';

            trigger OnLookup();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                if ProjectsStructure."Shortcut Dimension 1 Code" <> '' then begin
                    DimValue.SetRange("Dimension Code", ProjectsStructure."Shortcut Dimension 1 Code");
                    if DimValue.Find('-') then begin
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                            Validate("Project Dimension 1 Code", DimValue.Code);
                        end;
                    end;
                end;
            end;

            trigger OnValidate();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                UpdateDim(ProjectsStructure."Shortcut Dimension 1 Code", "Project Dimension 1 Code");
            end;
        }
        field(13; "Project Dimension 2 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(2);
            Caption = 'Budget Dimension 2 Code';

            trigger OnLookup();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                if ProjectsStructure."Shortcut Dimension 2 Code" <> '' then begin
                    DimValue.SetRange("Dimension Code", ProjectsStructure."Shortcut Dimension 2 Code");
                    if DimValue.Find('-') then begin
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                            Validate("Project Dimension 2 Code", DimValue.Code);
                        end;
                    end;
                end;
            end;

            trigger OnValidate();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                UpdateDim(ProjectsStructure."Shortcut Dimension 2 Code", "Project Dimension 2 Code");
            end;
        }
        field(14; "Project Dimension 3 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(3);
            Caption = 'Budget Dimension 3 Code';

            trigger OnLookup();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                if ProjectsStructure."Shortcut Dimension 3 Code" <> '' then begin
                    DimValue.SetRange("Dimension Code", ProjectsStructure."Shortcut Dimension 3 Code");
                    if DimValue.Find('-') then begin
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                            Validate("Project Dimension 3 Code", DimValue.Code);
                        end;
                    end;
                end;
            end;

            trigger OnValidate();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                UpdateDim(ProjectsStructure."Shortcut Dimension 3 Code", "Project Dimension 3 Code");
            end;
        }
        field(15; "Project Dimension 4 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(4);
            Caption = 'Budget Dimension 4 Code';

            trigger OnLookup();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                if ProjectsStructure."Shortcut Dimension 4 Code" <> '' then begin
                    DimValue.SetRange("Dimension Code", ProjectsStructure."Shortcut Dimension 4 Code");
                    if DimValue.Find('-') then begin
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                            Validate("Project Dimension 4 Code", DimValue.Code);
                        end;
                    end;
                end;
            end;

            trigger OnValidate();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                UpdateDim(ProjectsStructure."Shortcut Dimension 4 Code", "Project Dimension 4 Code");
            end;
        }
        field(16; "Project Dimension 5 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(5);
            Caption = 'Budget Dimension 5 Code';

            trigger OnLookup();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                if ProjectsStructure."Shortcut Dimension 5 Code" <> '' then begin
                    DimValue.SetRange("Dimension Code", ProjectsStructure."Shortcut Dimension 5 Code");
                    if DimValue.Find('-') then begin
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                            Validate("Project Dimension 5 Code", DimValue.Code);
                        end;
                    end;
                end;
            end;
        }
        field(17; "Project Dimension 6 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(6);
            Caption = 'Budget Dimension 6 Code';

            trigger OnLookup();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                if ProjectsStructure."Shortcut Dimension 6 Code" <> '' then begin
                    DimValue.SetRange("Dimension Code", ProjectsStructure."Shortcut Dimension 6 Code");
                    if DimValue.Find('-') then begin
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                            Validate("Project Dimension 6 Code", DimValue.Code);
                        end;
                    end;
                end;
            end;
        }
        field(18; "Project Dimension 7 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(7);
            Caption = 'Budget Dimension 7 Code';

            trigger OnLookup();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                if ProjectsStructure."Shortcut Dimension 7 Code" <> '' then begin
                    DimValue.SetRange("Dimension Code", ProjectsStructure."Shortcut Dimension 7 Code");
                    if DimValue.Find('-') then begin
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                            Validate("Project Dimension 7 Code", DimValue.Code);
                        end;
                    end;
                end;
            end;
        }
        field(19; "Project Dimension 8 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(8);
            Caption = 'Budget Dimension 8 Code';

            trigger OnLookup();
            begin
                if ProjectsStructure.Code <> "Project Code" then
                    if not ProjectsStructure.Get("Project Code") then
                        exit;

                if ProjectsStructure."Shortcut Dimension 8 Code" <> '' then begin
                    DimValue.SetRange("Dimension Code", ProjectsStructure."Shortcut Dimension 8 Code");
                    if DimValue.Find('-') then begin
                        if Page.RunModal(Page::"Dimension Value List", DimValue) = Action::LookupOK then begin
                            Validate("Project Dimension 8 Code", DimValue.Code);
                        end;
                    end;
                end;
            end;
        }
        field(20; Type; Option)
        {
            Caption = 'Analysis type';
            OptionCaption = 'Investment Calculation,Detailed Planning,Estimate Calculation';
            OptionMembers = "Investment Calculation","Detailed Planning","Estimate Calculation";
        }
        // field(21; "Starting Date"; Date)
        // {
        //     Caption = 'Starting Date';
        // }
        field(22; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
        // field(23; Predecessor; Integer)
        // {
        //     Caption = 'Predecessor';
        // }
        // field(24; "Predecessor Type"; Option)
        // {
        //     Caption = 'Predecessor Type';
        //     OptionCaption = 'ON,NN,OO,NO';
        //     OptionMembers = ON,NN,OO,NO;
        // }
        // field(25; "Predecessor Name"; Text[250])
        // {
        //     CalcFormula = Lookup("Projects Structure Lines".Description where("Project Code" = field("Project Code"), "Line No." = field(Predecessor), Type = field(Type)));
        //     Caption = 'Predecessor Name';
        //     FieldClass = FlowField;
        // }
        // field(26; Amount; Decimal)
        // {
        //     Caption = 'Amount';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link".Amount where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line No."), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Reserv = field("Reserv FLT"), "Agrrement No." = field("Agreement FLT"), Close = field("Close FLT")));
        // }
        // field(27; "Date Filter"; Date)
        // {
        //     Caption = 'Date Filter';
        //     FieldClass = FlowFilter;
        // }
        // field(28; "Amount Group"; Decimal)
        // {
        //     Caption = 'Amount Group';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link".Amount where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line Filter"), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Reserv = field("Reserv FLT"), "Agrrement No." = field("Agreement FLT"), Close = field("Close FLT")));
        // }
        // field(29; "Line Filter"; Integer)
        // {
        //     Caption = 'Line Filter';
        //     FieldClass = FlowFilter;
        // }
        field(30; "Repeat Interval"; DateFormula)
        {
            Caption = 'Repeat Interval';
        }
        // field(31; Calculate; Boolean)
        // {
        //     Caption = 'Calculate';
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
        //     Caption = 'VAT';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link".VAT where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line No."), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Reserv = field("Reserv FLT"), "Agrrement No." = field("Agreement FLT"), Close = field("Close FLT")));
        // }
        // field(35; "Without VAT"; Decimal)
        // {
        //     Caption = 'Without VAT';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Without VAT" where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line No."), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Reserv = field("Reserv FLT"), "Agrrement No." = field("Agreement FLT"), Close = field("Close FLT")));
        // }
        // field(36; "VAT Group"; Decimal)
        // {
        //     Caption = 'VAT Group';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link".VAT where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line Filter"), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Reserv = field("Reserv FLT"), "Agrrement No." = field("Agreement FLT"), Close = field("Close FLT")));
        // }
        // field(37; "Without VAT Group"; Decimal)
        // {
        //     Caption = 'Without VAT Group';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Without VAT" where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line Filter"), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Reserv = field("Reserv FLT"), "Agrrement No." = field("Agreement FLT"), Close = field("Close FLT")));
        // }
        // field(38; "Copy From Sales"; Boolean)
        // {
        //     Caption = 'Copy From Sales';
        // }
        // field(39; "Version Filter"; Code[20])
        // {
        //     Caption = 'Version Filter';
        //     FieldClass = FlowFilter;
        // }
        // field(40; "Amount Type"; Option)
        // {
        //     Caption = 'Amount Type';
        //     OptionCaption = 'pOut,pIN';
        //     OptionMembers = pOut,pIN;
        // }
        // field(41; Color; Integer)
        // {
        //     Caption = 'Color';
        // }
        // field(42; "Turn Flt"; Code[20])
        // {
        //     Caption = 'Turn Flt';
        //     FieldClass = FlowFilter;
        // }
        // field(44; "Fact Amount"; Decimal)
        // {
        //     Caption = 'Fact Amount';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Amount (LCY)" where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line No."), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Close = const(true)));
        // }
        // field(45; "Fact VAT"; Decimal)
        // {
        //     Caption = 'Fact VAT';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link".VAT where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line No."), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Close = const(true)));
        // }
        // field(46; "Fact Without VAT"; Decimal)
        // {
        //     Caption = 'Fact Without VAT';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Without VAT" where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line No."), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Close = const(true)));
        // }
        // field(47; "Fact Amount Group"; Decimal)
        // {
        //     Caption = 'Fact Amount Group';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Amount (LCY)" where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line Filter"), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Close = const(true)));
        // }
        // field(48; "Fact VAT Group"; Decimal)
        // {
        //     Caption = 'Fact VAT Group';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link".VAT where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line Filter"), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Close = const(true)));
        // }
        // field(49; "Fact Without VAT Group"; Decimal)
        // {
        //     Caption = 'Fact Without VAT Group';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Budget Entry Link"."Without VAT" where("Project Code" = field("Project Code"), "Analysis Type" = field(Type), "Version Code" = field(Version), "Line No." = field("Line Filter"), Date = field("Date Filter"), "Fixed Version" = field("Fixed Filter"), "Create Date" = field("Create Date Filter"), "Version Code" = field("Version Filter"), "Project Turn Code" = field("Turn Flt"), Close = const(true)));
        // }
        // field(50; "Exist Dim"; Code[20])
        // {
        //     CalcFormula = Lookup("Projects Line Dimension"."Dimension Value Code" where("Project No." = field("Project Code"), "Project Version No." = field(Version), "Project Line No." = field("Line No."), "Dimension Code" = const('CC'), "Detailed Line No." = const(0)));
        //     Caption = 'Exist Dim';
        //     FieldClass = FlowField;
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
        // field(54; MainLineNo; Integer)
        // {
        //     Caption = 'MainLineNo';
        // }
        // field(84; Blocked; Boolean)
        // {
        //     CalcFormula = Lookup("Dimension Value".Blocked where("Dimension Code" = const('CC'), Code = field(Code)));
        //     Caption = 'Blocked';
        //     FieldClass = FlowField;
        // }
        // field(94; "Forecast Approve Status"; Option)
        // {
        //     Caption = 'Forecast Approve Status';
        //     OptionCaption = 'Appr,Cancel,Waiting';
        //     OptionMembers = Appr,Cancel,Waiting;
        // }
        // field(95; Forecast; Decimal)
        // {
        //     Caption = 'Forecast';
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" where("Project Code" = field("Project Code"), "Analysis Type" = const(Forecast), "Line No." = field("Line No."), "Project Turn Code" = field("Turn Flt")));
        // }
        // field(50000; "Do not Use In Housing"; Boolean)
        // {
        //     Caption = 'Do not Use In Housing';
        // }
        // field(50010; "Posting Line"; Boolean)
        // {
        //     Caption = 'Posting Line';
        // }
        // field(60088; "Original Company"; Code[2])
        // {
        //     Caption = 'Original Company';
        // }
    }

    keys
    {
        key(Key1; "Project Code", Type, Version, "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete();
    var
        PCCE: Record "Projects Cost Control Entry";
    begin
        PCCE.SetRange("Project Code", "Project Code");
        PCCE.SetRange("Line No.", "Line No.");
        if PCCE.FindFIRST then
            Error(Text009);


        DelDimentions;
    end;

    trigger OnInsert();
    begin
        if "Line No." = 0 then
            exit;
        if ProjectsArticle.Get(Code) then begin
            Description := ProjectsArticle.Description;
            "By Building turn" := ProjectsArticle."By Building turn";
            "Repeat Interval" := ProjectsArticle."Repeat Interval";
        end else begin
            clear("Repeat Interval");
            Description := '';
            "By Building turn" := false;
        end;

        CopyDimentions(Code);
    end;

    trigger OnModify();
    begin
        if ProjectsStructure.Code <> "Project Code" then
            if not ProjectsStructure.Get("Project Code") then
                exit;

        if "Project Dimension 1 Code" <> xRec."Project Dimension 1 Code" then
            UpdateDim(ProjectsStructure."Shortcut Dimension 1 Code", "Project Dimension 1 Code");
        if "Project Dimension 2 Code" <> xRec."Project Dimension 2 Code" then
            UpdateDim(ProjectsStructure."Shortcut Dimension 2 Code", "Project Dimension 2 Code");
        if "Project Dimension 3 Code" <> xRec."Project Dimension 3 Code" then
            UpdateDim(ProjectsStructure."Shortcut Dimension 3 Code", "Project Dimension 3 Code");
        if "Project Dimension 4 Code" <> xRec."Project Dimension 4 Code" then
            UpdateDim(ProjectsStructure."Shortcut Dimension 4 Code", "Project Dimension 4 Code");
        if "Project Dimension 5 Code" <> xRec."Project Dimension 5 Code" then
            UpdateDim(ProjectsStructure."Shortcut Dimension 5 Code", "Project Dimension 5 Code");
        if "Project Dimension 6 Code" <> xRec."Project Dimension 6 Code" then
            UpdateDim(ProjectsStructure."Shortcut Dimension 6 Code", "Project Dimension 6 Code");
        if "Project Dimension 7 Code" <> xRec."Project Dimension 7 Code" then
            UpdateDim(ProjectsStructure."Shortcut Dimension 7 Code", "Project Dimension 7 Code");
        if "Project Dimension 8 Code" <> xRec."Project Dimension 8 Code" then
            UpdateDim(ProjectsStructure."Shortcut Dimension 8 Code", "Project Dimension 8 Code");
    end;

    trigger OnRename();
    var
        ProjectsCostControlEntry: Record "Projects Cost Control Entry";
    begin
        ProjectsCostControlEntry.SetRange("Project Code", "Project Code");
        ProjectsCostControlEntry.SetRange("Analysis Type", Type);
        ProjectsCostControlEntry.SetRange("Version Code", Version);
        ProjectsCostControlEntry.SetRange("Line No.", "Line No.");
    end;

    var
        DimValue: Record "Dimension Value";
        ProjectsArticle: Record "Projects Article";
        ProjectsStructure: Record "Projects Structure";
        gViewCode: Code[20];
        Text000: Label 'The dimension value %1 has not been set up for dimension %2.';
        Text001: Label '1,5,,Budget Dimension 1 Code';
        Text002: Label '1,5,,Budget Dimension 2 Code';
        Text003: Label '1,5,,Budget Dimension 3 Code';
        Text004: Label '1,5,,Budget Dimension 4 Code';
        Text005: Label '1,5,,Budget Dimension 5 Code';
        Text006: Label '1,5,,Budget Dimension 6 Code';
        Text007: Label '1,5,,Budget Dimension 7 Code';
        Text008: Label '1,5,,Budget Dimension 8 Code';
        Text009: Label 'You can not delete a row, exist project data';

    procedure CopyDimentions(ACode: Code[20]);
    var
        lrDefDim: Record "Default Dimension";
        lrPrjLineDin: Record "Projects Line Dimension";
    begin
        lrDefDim.SetRange("Table ID", 70071);
        lrDefDim.SetRange("No.", ACode);
        if lrDefDim.Find('-') then begin
            Repeat
                lrPrjLineDin.INIT;
                lrPrjLineDin."Project No." := "Project Code";
                lrPrjLineDin."Project Version No." := Version;
                lrPrjLineDin."Project Line No." := "Line No.";
                lrPrjLineDin."Dimension Code" := lrDefDim."Dimension Code";

                lrPrjLineDin."Dimension Value Code" := lrDefDim."Dimension Value Code";
                if lrPrjLineDin.INSERT then;
            Until lrDefDim.Next = 0;
        end;

        if ACode = '' then begin
            lrPrjLineDin.SetRange("Project No.", "Project Code");
            lrPrjLineDin.SetRange("Project Line No.", "Line No.");
            lrPrjLineDin.SetRange("Project Version No.", Version);
            if lrPrjLineDin.Find('-') then
                lrPrjLineDin.DeleteAll;
        end;
    end;

    procedure DelDimentions();
    var
        lrPrjLineDin: Record "Projects Line Dimension";
    begin
        lrPrjLineDin.SetRange("Project No.", "Project Code");
        lrPrjLineDin.SetRange("Project Line No.", "Line No.");
        lrPrjLineDin.SetRange("Project Version No.", Version);
        if lrPrjLineDin.Find('-') then
            lrPrjLineDin.DeleteAll;
    end;

    procedure GetCaptionClass(BudgetDimType: Integer): Text[250];
    begin
        if ProjectsStructure.Code <> "Project Code" then
            if not ProjectsStructure.Get("Project Code") then
                Exit('');


        Case BudgetDimType of
            1:
                begin
                    if ProjectsStructure."Shortcut Dimension 1 Code" <> '' then
                        Exit('1,5,' + ProjectsStructure."Shortcut Dimension 1 Code")
                    else
                        Exit(Text001);
                end;
            2:
                begin
                    if ProjectsStructure."Shortcut Dimension 2 Code" <> '' then
                        Exit('1,5,' + ProjectsStructure."Shortcut Dimension 2 Code")
                    else
                        Exit(Text002);
                end;
            3:
                begin
                    if ProjectsStructure."Shortcut Dimension 3 Code" <> '' then
                        Exit('1,5,' + ProjectsStructure."Shortcut Dimension 3 Code")
                    else
                        Exit(Text003);
                end;
            4:
                begin
                    if ProjectsStructure."Shortcut Dimension 4 Code" <> '' then
                        Exit('1,5,' + ProjectsStructure."Shortcut Dimension 4 Code")
                    else
                        Exit(Text004);
                end;
            5:
                begin
                    if ProjectsStructure."Shortcut Dimension 5 Code" <> '' then
                        Exit('1,5,' + ProjectsStructure."Shortcut Dimension 5 Code")
                    else
                        Exit(Text005);
                end;
            6:
                begin
                    if ProjectsStructure."Shortcut Dimension 6 Code" <> '' then
                        Exit('1,5,' + ProjectsStructure."Shortcut Dimension 6 Code")
                    else
                        Exit(Text006);
                end;
            7:
                begin
                    if ProjectsStructure."Shortcut Dimension 7 Code" <> '' then
                        Exit('1,5,' + ProjectsStructure."Shortcut Dimension 7 Code")
                    else
                        Exit(Text007);
                end;
            8:
                begin
                    if ProjectsStructure."Shortcut Dimension 8 Code" <> '' then
                        Exit('1,5,' + ProjectsStructure."Shortcut Dimension 8 Code")
                    else
                        Exit(Text008);
                end;
        end;
    end;

    procedure UpdateDim(DimCode: Code[20]; DimValueCode: Code[20]);
    var
        ProjectDim: Record "Projects Line Dimension";
    begin
        if DimCode = '' then
            exit;

        ProjectDim.SetRange("Project No.", "Project Code");
        ProjectDim.SetRange("Project Version No.", Version);
        ProjectDim.SetRange("Project Line No.", "Line No.");
        ProjectDim.SetRange("Dimension Code", DimCode);
        if ProjectDim.Find('-') then
            ProjectDim.Delete;

        if DimValueCode <> '' then begin
            ProjectDim.Reset;
            ProjectDim.Init;
            ProjectDim."Project No." := "Project Code";
            ProjectDim."Project Version No." := Version;
            ProjectDim."Project Line No." := "Line No.";
            ProjectDim."Dimension Code" := DimCode;
            ProjectDim."Dimension Value Code" := DimValueCode;
            ProjectDim.Insert;
        end;
    end;
}

