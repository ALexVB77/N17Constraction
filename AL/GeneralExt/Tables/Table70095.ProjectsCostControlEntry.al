table 70095 "Projects Cost Control Entry"
{
    Caption = 'Projects Cost Control Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = 70213;
    LookupPageID = 70213;
    fields
    {
        field(1; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            DataClassification = CustomerContent;
            TableRelation = "Building project";
        }
        field(2; "Analysis Type"; Enum "Analysis Type")
        {
            Caption = 'Analysis Type';
        }
        field(3; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(6; "Project Turn Code"; Code[20])
        {
            Caption = 'Project Turn Code';
            TableRelation = "Building turn";
        }
        field(7; "Temp Line No."; Integer)
        {
        }
        field(8; "Cost Type"; Code[20])
        {
            Caption = 'Cost Type';

            // trigger OnLookup();
            // var
            //     GLSetup: Record "General Ledger Setup";
            //     DimensionValue: Record "Dimension Value";
            // begin
            //     GLSetup.Get;
            //     DimensionValue.SetRange("Dimension Code", GLSetup."Cost Type Dimension Code");
            //     if DimensionValue.FindFirst then begin
            //         if DimensionValue.Get(GLSetup."Cost Type Dimension Code", "Cost Type") then;

            //         if Page.RunModal(Page::"Dimension Value List", DimensionValue) = Action::LookupOK then begin
            //             "Cost Type" := DimensionValue.Code;
            //         end;
            //     end;
            // end;
        }
        // field(10; "Entry Type"; Option)
        // {
        //     Caption = 'Entry Type';
        //     DataClassification = CustomerContent;
        //     OptionCaption = 'OwnWorks,Subcontract,Materials,Income';
        //     OptionMembers = OwnWorks,Subcontract,Materials,Income;
        // }
        field(20; Description; Text[250])
        {
            Caption = 'Description';
            NotBlank = true;
        }
        field(30; "Description 2"; Text[250])
        {
            Caption = 'Decription 2';
            NotBlank = true;
        }
        field(40; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate();
            begin
                if Curency = '' then begin
                    "Amount (LCY)" := Amount;
                end;

                // if (not gvCreateRepeat) then
                //     CreateRepeatEntry();
                New := false;
            end;
        }
        field(50; Curency; Code[20])
        {
            Caption = 'Currency';
        }
        // field(60; "Currency Factor"; Decimal)
        // {
        //     Caption = 'Currency Factor';
        // }
        field(70; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(80; Date; Date)
        {
            Caption = 'Date';
        }
        field(90; "Create User"; Code[65])
        {
            Caption = 'Create User';
        }
        field(100; "Create Date"; Date)
        {
            Caption = 'Create Date';
        }
        field(110; "Create Time"; Time)
        {
            Caption = 'Create Time';
        }
        field(120; "Parent Entry"; Integer)
        {
            Caption = 'Parent Entry';
        }
        field(130; New; Boolean)
        {
            Caption = 'New';
        }
        // field(140; "Fixed Version"; Boolean)
        // {
        //     Caption = 'Fixed Version';
        // }
        // field(150; "Fixed Version Filter"; Boolean)
        // {
        //     Caption = 'Fixed Version Filter';
        //     FieldClass = FlowFilter;
        // }
        // field(160; "Budget On Date"; Date)
        // {
        //     Caption = 'Budget On Date';
        //     FieldClass = FlowFilter;
        // }
        field(170; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        // field(180; Linked; Boolean)
        // {
        //     Caption = 'Linked';
        // }
        field(190; "Contragent No."; Code[20])
        {
            Caption = 'Contragent No.';
            TableRelation = if ("Contragent Type" = const(Vendor)) Vendor else
            if ("Contragent Type" = const(Customer)) Customer;

            trigger OnValidate();
            var
                Vendor: Record Vendor;
                Customer: Record Customer;
            begin
                if ("Contragent No." <> '') and ("Contragent No." <> xRec."Contragent No.") then begin
                    if "Contragent Type" = "Contragent Type"::Vendor then begin
                        if Vendor.Get("Contragent No.") then
                            "Contragent Name" := Vendor."Full Name";
                    end;
                    if "Contragent Type" = "Contragent Type"::Customer then begin
                        if Customer.Get("Contragent No.") then
                            "Contragent Name" := Customer."Full Name";
                    end;
                end;
            end;
        }
        field(200; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            TableRelation = if ("Contragent Type" = const(Vendor)) "Vendor Agreement"."No." WHERE("Vendor No." = field("Contragent No."), Active = const(true)) else
            if ("Contragent Type" = const(Customer)) "Customer Agreement"."No." where("Customer No." = field("Contragent No."));

            trigger OnValidate();
            var
                VendAgr: Record "Vendor Agreement";
                CustAgr: Record "Customer Agreement";
            begin
                if "Contragent Type" = "Contragent Type"::Vendor then begin
                    VendAgr.Reset;
                    if VendAgr.Get(Rec."Contragent No.", "Agreement No.") then
                        "External Agreement No." := VendAgr."External Agreement No.";
                end;
                if "Contragent Type" = "Contragent Type"::Customer then begin
                    CustAgr.Reset;
                    if CustAgr.Get(Rec."Contragent No.", "Agreement No.") then
                        "External Agreement No." := CustAgr."External Agreement No.";
                end;
            end;
        }
        // field(210; VAT; Decimal)
        // {
        //     CalcFormula = Sum("Projects Budget Entry Link".VAT where("Main Entry No." = field("Entry No."), "Project Code" = field("Project Code"), "Analysis Type" = field("Analysis Type"), "Version Code" = field("Version Code"), "Line No." = field("Line No."), Date = field(Date), "Fixed Version" = field("Fixed Version Filter"), "Create Date" = field("Budget On Date"), "Project Turn Code" = field("Project Turn Code")));
        //     Caption = 'VAT';
        //     FieldClass = FlowField;
        // }
        field(220; "Without VAT"; Decimal)
        {
            Caption = 'Without VAT';
        }
        // field(230; "Including VAT"; Boolean)
        // {
        //     Caption = 'Including VAT';
        // }
        field(240; "Contragent Name"; Text[250])
        {
            Caption = 'Contragent Name';
        }
        field(250; "External Agreement No."; Text[30])
        {
            Caption = 'External Agreement No.';
        }
        // field(260; "Linked Entry No."; Integer)
        // {
        //     Caption = 'Linked Entry No.';
        // }
        // field(270; "Copy From Sales"; Boolean)
        // {
        //     Caption = 'Copy From Sales';
        // }
        field(280; "Contragent Type"; Option)
        {
            Caption = 'Contragent Type';
            OptionCaption = 'Vendor,Customer';
            OptionMembers = Vendor,Customer;

            trigger OnValidate();
            begin
                if Rec."Contragent Type" <> xRec."Contragent Type" then begin
                    Rec.Validate("Contragent No.", '');
                    Rec.Validate("Agreement No.", '');
                end;
            end;
        }
        // field(290; "Temp Amount"; Decimal)
        // {
        //     Caption = 'Temp Amount';
        // }
        // field(300; "Main Enty No."; Integer)
        // {
        // }
        // field(310; Close; Boolean)
        // {
        //     Caption = 'Close';

        //     trigger OnValidate();
        //     begin
        //         lrProjectsBudgetEntryLink.SetRange("Main Entry No.", "Entry No.");
        //         lrProjectsBudgetEntryLink.SetRange("Project Code", "Project Code");
        //         lrProjectsBudgetEntryLink.SetRange("Analysis Type", "Analysis Type");
        //         lrProjectsBudgetEntryLink.SetRange("Version Code", "Version Code");
        //         if lrProjectsBudgetEntryLink.FindFirst then begin
        //             Repeat
        //                 lrProjectsBudgetEntryLink.Close := Close;
        //                 lrProjectsBudgetEntryLink.Modify;
        //             until lrProjectsBudgetEntryLink.Next = 0;
        //         end;
        //     end;
        // }
        field(320; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate();
            begin
                ValidateDimension1;
            end;
        }
        field(330; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate();
            begin
                ValidateDimension2;
            end;
        }
        field(340; "Building Turn"; Code[20])
        {
            Caption = 'Stage';
            TableRelation = "Building turn";

            // trigger OnLookup();
            // begin
            //     gvBuildingTurn.SetRange("Building project Code", "Project Code");
            //     if gvBuildingTurn.FindFirst then begin
            //         if Page.RunModal(Page::"Dev Building turn", gvBuildingTurn) = ACTION::LookupOK then begin
            //              "Building Turn" := gvBuildingTurn.Code;
            //              Validate("Shortcut Dimension 1 Code", gvBuildingTurn."Turn Dimension Code");
            //              "Project Turn Code" := "Building Turn";
            //         end;
            //     end;
            // end;

            trigger OnValidate();
            begin
                gvBuildingTurn.SetRange("Building project Code", "Project Code");
                gvBuildingTurn.SetRange(Code, "Building Turn");
                if gvBuildingTurn.FindFirst then begin
                    Validate("Shortcut Dimension 1 Code", gvBuildingTurn."Turn Dimension Code");
                    "Project Turn Code" := "Building Turn";
                end;
            end;
        }
        field(350; "Cost Code"; Code[20])
        {
            Caption = 'Budget Item';

            trigger OnLookup();
            var
                ProjectsLineDimension: Record "Projects Cost Control Entry";
            begin
                grProjectsStructureLines1.SetRange("Project Code", "Project Code");
                grProjectsStructureLines1.SetRange(Version, "Version Code");
                grProjectsStructureLines1.SetRange("Structure Post Type", grProjectsStructureLines1."Structure Post Type"::Posting);
                if grProjectsStructureLines1.FindFirst then begin
                    if "New Lines" = 0 then begin
                        if grProjectsStructureLines1.Get("Project Code", "Analysis Type", "Version Code", "Line No.") then;
                    END
                    else
                        if grProjectsStructureLines1.Get("Project Code", "Analysis Type", "Version Code", "New Lines") then;

                    // if Page.RunModal(Page::"Projects Article List", grProjectsStructureLines1) = ACTION::LookupOK then begin
                    //     "Cost Code" := grProjectsStructureLines1.Code;
                    //     ProjectsLineDimension.SetRange("Project No.", "Project Code");
                    //     ProjectsLineDimension.SetRange("Project Version No.", "Version Code");
                    //     ProjectsLineDimension.SetRange("Project Line No.", grProjectsStructureLines1."Line No.");
                    //     ProjectsLineDimension.SetRange("Detailed Line No.", 0);
                    //     ProjectsLineDimension.SetRange("Dimension Code", 'CC');
                    //     if ProjectsLineDimension.FindFirst then
                    //         Validate("Shortcut Dimension 2 Code", ProjectsLineDimension."Dimension Value Code");

                    //     "New Lines" := grProjectsStructureLines1."Line No.";
                    //     "Line No." := grProjectsStructureLines1."Line No.";
                    //     Code := grProjectsStructureLines1.Code;
                    //     Description := grProjectsStructureLines1.Description;
                    // end;
                end;
                ChangeDate2;
            end;

            trigger OnValidate();
            var
                ProjectsLineDimension: Record "Projects Line Dimension";
                CodeMonkeyTranslation: Codeunit "Code Monkey Translation";
            begin
                grProjectsStructureLines1.SetRange("Project Code", "Project Code");
                grProjectsStructureLines1.SetRange(Version, "Version Code");
                grProjectsStructureLines1.SetRange("Structure Post Type", grProjectsStructureLines1."Structure Post Type"::Posting);
                grProjectsStructureLines1.SetRange(Code, "Cost Code");
                if grProjectsStructureLines1.FindFirst then begin
                    ProjectsLineDimension.SetRange("Project No.", "Project Code");
                    ProjectsLineDimension.SetRange("Project Version No.", "Version Code");
                    ProjectsLineDimension.SetRange("Project Line No.", grProjectsStructureLines1."Line No.");
                    ProjectsLineDimension.SetRange("Detailed Line No.", 0);
                    ProjectsLineDimension.SetRange("Dimension Code", CodeMonkeyTranslation.ConstOther('CC'));
                    if ProjectsLineDimension.FindFirst then
                        Validate("Shortcut Dimension 2 Code", ProjectsLineDimension."Dimension Value Code");
                    "New Lines" := grProjectsStructureLines1."Line No.";
                    "Line No." := grProjectsStructureLines1."Line No.";
                    Code := grProjectsStructureLines1.Code;
                    Description := grProjectsStructureLines1.Description;
                end;
                ChangeDate2;
            end;
        }
        field(360; "New Lines"; Integer)
        {
            Caption = 'New Lines';
        }
        // field(370; "Not Run OnInsert"; Boolean)
        // {
        // }
        // field(380; "Work Version"; Boolean)
        // {
        //     Caption = 'Рабочая версия';
        // }
        field(390; Reserve; Boolean)
        {
            Caption = 'Reserve';

            trigger OnValidate();
            begin
                lrProjectsBudgetEntryLink.SetRange("Main Entry No.", "Entry No.");
                lrProjectsBudgetEntryLink.SetRange("Project Code", "Project Code");
                lrProjectsBudgetEntryLink.SetRange("Analysis Type", "Analysis Type");
                lrProjectsBudgetEntryLink.SetRange("Version Code", "Version Code");
                if lrProjectsBudgetEntryLink.FindFirst then begin
                    Repeat
                        lrProjectsBudgetEntryLink.Reserv := Reserve;
                        lrProjectsBudgetEntryLink.Modify;
                    until lrProjectsBudgetEntryLink.Next = 0;
                end;
            end;
        }
        field(400; "Building Turn All"; Code[20])
        {
            Caption = 'Building Turn All';
            TableRelation = "Building turn";
        }

        field(410; "Doc No."; Code[20])
        {
            Caption = 'Doc No.';
        }
        field(420; "Doc Type"; Option)
        {
            Caption = 'Doc Type';
            OptionMembers = Pre,Post;
        }
        field(430; "Close Date"; Date)
        {
            Caption = 'Close Date';
        }
        field(50000; "Amount 2"; Decimal)
        {
            BlankZero = true;
            Caption = 'Amount (new)';
        }
        field(50010; "Amount Including VAT 2"; Decimal)
        {
            BlankZero = true;
            Caption = 'Amount Including VAT (new)';
            Description = '28312';
        }
        field(50020; "VAT Amount 2"; Decimal)
        {
            BlankZero = true;
            Caption = 'VAT Amount (new)';
        }
        field(50030; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
        }
        field(50040; "Imported Form File"; Boolean)
        {
            Caption = 'Imported Form File';
            Editable = false;
        }
        field(60090; "Original Company"; Code[2])
        {
            Caption = 'Original Company';
        }
        field(70000; "Original Date"; Date)
        {
            Caption = 'Original Date';
        }
        field(70010; ID; Integer)
        {
            Caption = 'ID';
        }
        // field(70020; "IFRS Account No."; Text[250])
        // {
        //     CalcFormula = Lookup("Budget Correction Journal"."G/L Account Totaling" where(ID = field(ID), "Project Code" = field("Project Code")));
        //     Caption = 'IFRS Account No.';
        //     FieldClass = FlowField;
        // }
        field(70025; "User Created"; Boolean)
        {
            Caption = 'User Created';
        }
        // field(70030; "Frc Version Code"; Code[20])
        // {
        // }
        field(70040; "Original Ammount"; Decimal)
        {
            Caption = 'Original Ammount';
        }
        field(70050; Reversed; Boolean)
        {
            Caption = 'Reversed';
        }
        field(70060; "Reversed ID"; Integer)
        {
            Caption = 'Reversed ID';
        }
        // field(70070; "User Created"; Boolean)
        // {
        //     Caption = 'User Created';
        // }
        field(70080; Changed; Boolean)
        {
            Caption = 'Changed';
            FieldClass = Normal;
        }
        field(70090; "Company Name"; Text[60])
        {
            Caption = 'Company Name';
        }
        // field(70100; "Allocation Line No."; Integer)
        // {
        //     Caption = 'Allocation Line No.';
        // }
        // field(70110; "Template Code"; Code[20])
        // {
        //     Caption = 'Template Code';
        // }
        // field(70120; "Error Line"; Boolean)
        // {
        //     Caption = 'Error Line';
        // }
        // field(70130; "Reversed Without Entry"; Boolean)
        // {
        //     Caption = 'Reversed';
        // }
        // field(70140; "INIT CP"; Code[20])
        // {
        //     Caption = 'INIT CP';
        // }
        // field(70150; ByOrder; Boolean)
        // {
        //     CalcFormula = Lookup("Vendor Agreement".WithOut where ("Vendor No." = field("Contragent No."), "No." = field("Agrrement No.")));
        //     Caption = 'ByOrder';
        //     FieldClass = FlowField;
        // }
        field(70160; "Close Commitment"; Boolean)
        {
            Caption = 'Close Commitment';
        }
        field(70170; "Estimate Line No."; Integer)
        {
            Caption = 'Estimate Line No.';
        }
        field(70180; "Estimate Quantity"; Decimal)
        {
            Caption = 'Estimate Quantity';
        }
        field(70190; "Estimate Unit Price"; Decimal)
        {
            Caption = 'Estimate Unit Price';
        }
        field(70200; "Estimate Unit of Measure"; Text[10])
        {
            Caption = 'Estimate Unit of Measure';
        }
        field(70210; "Estimate Line ID"; Integer)
        {
            Caption = 'Estimate Line ID';
        }
        field(70220; "Estimate Subproject Code"; Text[10])
        {
            Caption = 'Estimate Subproject Code';
        }
        field(70230; "Project Storno"; Boolean)
        {
            Caption = 'Project Storno';
        }
        // field(70240; "Journal Batch Name"; Code[100])
        // {
        //     CalcFormula = Lookup("Budget Correction Journal"."Journal Batch Name" where(Id = Field(ID)));
        //     Caption = 'Code Batch Journal';
        //     Editable = false;
        //     FieldClass = FlowField;
        //     TableRelation = "Gen. Journal Batch".Name;
        // }
    }

    keys
    {
        key(Key1; "Project Code", "Analysis Type", "Version Code", "Line No.", "Entry No.", "Project Turn Code", "Temp Line No.", "Cost Type")
        {
            Clustered = true;
        }
        key(Key2; "Entry No.") { }
        key(Key3; "Project Code", "Analysis Type", "Version Code", "Line No.", Date) { }
        //key(Key4; Date) { }
        key(Key5; "Project Code", "Analysis Type", "Version Code", "Line No.", "Project Turn Code", "Parent Entry", Date) { }
        //key(Key6; "Project Code", "Analysis Type", "Version Code", "Line No.", "Copy From Sales") { }
        key(Key7; "Project Code", "Analysis Type", "Line No.")
        {
            SumIndexFields = "Without VAT", "Amount 2", "Amount Including VAT 2", "VAT Amount 2";
        }
        //key(Key8; "Doc No.") { }
        key(Key9; "Project Code", "Line No.", "Building Turn All", "Cost Type")
        {
            SumIndexFields = "Without VAT", "Amount 2", "Amount Including VAT 2", "VAT Amount 2";
        }
        key(Key10; "Project Code", "Line No.", "Building Turn All", "Cost Type", Date)
        {
            SumIndexFields = "Without VAT", "Amount 2", "Amount Including VAT 2", "VAT Amount 2";
        }
        key(Key11; "Project Code", "Line No.", "Building Turn All", "Cost Type", "Close Date")
        {
            SumIndexFields = "Without VAT", "Amount 2", "Amount Including VAT 2", "VAT Amount 2";
        }
        //key(Key12; "Reversed Without Entry") { }
        //key(Key13; ID) { }
        //key(Key14; "Create Date") { }
        key(Key15; "Analysis Type", "Close Commitment") { }
        key(Key16; "Analysis Type", "Contragent No.", "Agreement No.", "Project Turn Code", "Line No.", "Cost Type")
        {
            SumIndexFields = "Without VAT", "Amount Including VAT 2", "VAT Amount 2";
        }
        key(Key17; "Analysis Type", "Contragent No.", "Agreement No.", "Line No.", "Cost Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code")
        {
            SumIndexFields = "Without VAT", "Amount Including VAT 2", "VAT Amount 2";
        }
        key(Key18; "Project Code", "Line No.", "Agreement No.", "Analysis Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type")
        {
            SumIndexFields = "Without VAT", "Amount Including VAT 2", "VAT Amount 2";
        }
        key(Key19; "Project Code", "Line No.", "Agreement No.", "Analysis Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type", Reversed, "Project Storno")
        {
            SumIndexFields = "Without VAT", "Amount Including VAT 2", "VAT Amount 2";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        grProjectsLineDimension.SetRange("Project No.", "Project Code");
        grProjectsLineDimension.SetRange(Type, "Analysis Type");
        grProjectsLineDimension.SetRange("Project Version No.", "Version Code");
        grProjectsLineDimension.SetRange("Project Line No.", "Line No.");
        grProjectsLineDimension.SetRange("Detailed Line No.", "Entry No.");
        if grProjectsLineDimension.FindFirst then grProjectsLineDimension.DELETEALL;


        lrProjectsBudgetEntryLink.SetRange("Main Entry No.", "Entry No.");
        lrProjectsBudgetEntryLink.SetRange("Project Code", "Project Code");
        lrProjectsBudgetEntryLink.SetRange("Analysis Type", "Analysis Type");
        lrProjectsBudgetEntryLink.SetRange("Version Code", "Version Code");
        if lrProjectsBudgetEntryLink.FindFirst then lrProjectsBudgetEntryLink.DELETEALL;
    end;

    trigger OnInsert();
    var
        lrGeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
    begin
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo;

        "Create User" := UserId();
        "Create Date" := Today();
        "Create Time" := Time();
        begin
            lrGeneralLedgerSetup.Get;
            // grProjectsLineDimension.SetRange("Project No.", "Project Code");
            // grProjectsLineDimension.SetRange("Project Line No.", "Line No.");
            // grProjectsLineDimension.SetRange("Detailed Line No.", 0);
            // grProjectsLineDimension.SetRange("Project Version No.", GetDefVersion("Project Code"));
            // if grProjectsLineDimension.Find('-') then begin
            //     Repeat
            //         if lrGeneralLedgerSetup."Global Dimension 2 Code" = grProjectsLineDimension."Dimension Code" then
            //             "Shortcut Dimension 2 Code" := grProjectsLineDimension."Dimension Value Code";
            //     until grProjectsLineDimension.Next = 0;
            // end;

            // if "Project Turn Code" <> '' then begin
            //     grBuildingturn.Get("Project Turn Code");
            //     if grBuildingturn."Turn Dimension Code" <> '' then begin
            //         "Shortcut Dimension 1 Code" := grBuildingturn."Turn Dimension Code";
            //     end;
            // END
            // else begin
            //     grBuildingProect.Get("Project Code");
            //     if grBuildingProect."Project Dimension Code" <> '' then begin
            //         "Shortcut Dimension 1 Code" := grBuildingProect."Project Dimension Code";
            //     end;
            // end;
        end;

        CompanyInformation.Get();
        if "Analysis Type" <> "Analysis Type"::Forecast then
            if "Cost Type" = '' then
                "Cost Type" := '0';
        if not StructurePostTypeIsTotal then
            if Code = '' then Error(Text004);
        UserSetup.Get(UserID());
        // if CompanyName = 'NCC Construction' then
        //     if not UserSetup."Not Check Duplicate Operations" then
        //         if not IFRSCost then
        //             CheckDuplicateNumber();
    end;

    var
        grBuildingProect: Record "Building project";
        grBuildingturn: Record "Building turn";
        gvBuildingTurn: Record "Building turn";
        grDevelopmentSetup: Record "Development Setup";
        grProjectsStructureLines: Record "Projects Structure Lines";
        grProjectsStructureLines1: Record "Projects Structure Lines";
        grProjectsLineDimension: Record "Projects Line Dimension";
        grProjectsLineDimension1: Record "Projects Line Dimension";
        ProjectsLineDimension: Record "Projects Line Dimension";
        lrProjectsBudgetEntryLink: Record "Projects Budget Entry Link";
        GLSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
        PCCEntryTmp: Record "Projects Cost Control Entry" temporary;
        UserSetup: Record "User Setup";
        IFRSCost: Boolean;
        StructurePostTypeIsTotal: Boolean;
        gvCreateRepeat: Boolean;
        Text001: Label 'Create a periodic entries for\%1 ?';
        Text002: Label 'You must specify the ending date of the project!';
        Text003: Label 'Update related entries?';
        Text004: Label 'Cost Code value can not be empty';
        Text005: Label 'While posting, there is a line created with the number %1, which already exists in the system! Contact the Technical Support department.';

    procedure GetNextEntryNo(): Integer;
    var
        GLBudgetEntry: Record "Projects Cost Control Entry";
    begin
        GLBudgetEntry.SetCurrentkey("Entry No.");
        if GLBudgetEntry.Find('+') then
            Exit(GLBudgetEntry."Entry No." + 1)
        else
            Exit(1);
    end;

    procedure CreateRepeatEntry();
    var
        lrBuildingProject: Record "Building project";
        lrProjectsStructureLines: Record "Projects Structure Lines";
        lrProjectsBudgetEntry: Record "Projects Budget Entry";
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
                    if Confirm(StrSubstno(Text001, lrProjectsStructureLines.Description)) then begin
                        if lrProjectsStructureLines."Ending Date" = 0D then begin
                            lrBuildingProject.Get("Project Code");
                            if lrBuildingProject."Dev. Ending Date" = 0D then
                                Error(Text002)
                            else
                                lEndingDate := lrBuildingProject."Dev. Ending Date";
                        END
                        else
                            lEndingDate := lrProjectsStructureLines."Ending Date";
                        "Parent Entry" := "Entry No.";
                        lrDate := Date;
                        lvLastEntry := GetNextEntryNo;
                        Repeat
                            lrDate := CALCDATE(lrProjectsStructureLines."Repeat Interval", lrDate);
                            if lrDate <= lEndingDate then begin
                                CLEAR(lrProjectsBudgetEntry);
                                lrProjectsBudgetEntry.SetCreateRepeat(TRUE);
                                lrProjectsBudgetEntry.INIT;
                                lrProjectsBudgetEntry.COPY(Rec);
                                lvLastEntry := lvLastEntry + 1;
                                lrProjectsBudgetEntry."Entry No." := lvLastEntry;
                                lrProjectsBudgetEntry.Date := lrDate;
                                lrProjectsBudgetEntry.Insert(TRUE);
                            end;
                        until (lrDate > lEndingDate);
                    end;
                end;
            end;
        END
        else begin
            if "Parent Entry" <> 0 then begin
                if Confirm(StrSubstno(Text003, lrProjectsStructureLines.Description)) then begin
                    lrProjectsBudgetEntry.SetRange("Project Code", "Project Code");
                    lrProjectsBudgetEntry.SetRange("Analysis Type", "Analysis Type");
                    lrProjectsBudgetEntry.SetRange("Version Code", "Version Code");
                    lrProjectsBudgetEntry.SetRange("Line No.", "Line No.");
                    lrProjectsBudgetEntry.SetRange("Parent Entry", "Parent Entry");
                    lrProjectsBudgetEntry.SetFilter("Entry No.", '<>%1', "Entry No.");
                    if lrProjectsBudgetEntry.Find('-') then begin
                        Repeat
                            lrProjectsBudgetEntry.SetCreateRepeat(true);
                            lrProjectsBudgetEntry.Validate(Amount, Amount);
                            lrProjectsBudgetEntry.Modify;
                        until lrProjectsBudgetEntry.Next = 0;
                    end;
                end;
            end;
        end;
    end;

    procedure SetCreateRepeat(lvCreateRepeat: Boolean);
    begin
        gvCreateRepeat := lvCreateRepeat;
    end;

    procedure ValidateDimension();
    var
        lrProjectsLineDimension: Record "Projects Line Dimension";
        lrGeneralLedgerSetup: Record "General Ledger Setup";
    begin
        lrGeneralLedgerSetup.Get;

        lrProjectsLineDimension.SetRange("Project No.", "Project Code");
        lrProjectsLineDimension.SetRange("Project Line No.", "Line No.");
        lrProjectsLineDimension.SetRange("Detailed Line No.", "Entry No.");
        lrProjectsLineDimension.SetRange(Type, "Analysis Type");
        if lrProjectsLineDimension.Find('-') then begin
            Repeat
                if lrGeneralLedgerSetup."Global Dimension 2 Code" = lrProjectsLineDimension."Dimension Code" then
                    "Shortcut Dimension 2 Code" := lrProjectsLineDimension."Dimension Value Code";

            until lrProjectsLineDimension.Next = 0;
        end;
    end;

    procedure ValidateDimension1();
    var
        lrProjectsLineDimension: Record "Projects Line Dimension";
        lrGeneralLedgerSetup: Record "General Ledger Setup";
    begin
        lrGeneralLedgerSetup.Get;
        lrProjectsLineDimension.Reset;
        lrProjectsLineDimension.SetRange("Project No.", "Project Code");
        lrProjectsLineDimension.SetRange("Project Line No.", "Line No.");
        lrProjectsLineDimension.SetRange("Detailed Line No.", "Entry No.");
        lrProjectsLineDimension.SetRange("Dimension Code", lrGeneralLedgerSetup."Global Dimension 1 Code");
        if lrProjectsLineDimension.Find('-') then begin
            lrProjectsLineDimension."Dimension Value Code" := "Shortcut Dimension 1 Code";
            lrProjectsLineDimension.Modify;
        END
        else begin
            lrProjectsLineDimension.INIT;
            lrProjectsLineDimension."Project No." := "Project Code";
            lrProjectsLineDimension.Type := "Analysis Type";
            lrProjectsLineDimension."Project Version No." := "Version Code";
            lrProjectsLineDimension."Project Line No." := "Line No.";
            lrProjectsLineDimension."Detailed Line No." := "Entry No.";
            lrProjectsLineDimension."Dimension Code" := lrGeneralLedgerSetup."Global Dimension 1 Code";
            lrProjectsLineDimension."Dimension Value Code" := "Shortcut Dimension 1 Code";
            lrProjectsLineDimension.Insert;
        end;
    end;

    procedure ValidateDimension2();
    var
        lrProjectsLineDimension: Record "Projects Line Dimension";
        lrGeneralLedgerSetup: Record "General Ledger Setup";
    begin
        lrGeneralLedgerSetup.Get;
        lrProjectsLineDimension.Reset;
        lrProjectsLineDimension.SetRange("Project No.", "Project Code");
        lrProjectsLineDimension.SetRange(Type, "Analysis Type");
        lrProjectsLineDimension.SetRange("Project Version No.", "Version Code");
        lrProjectsLineDimension.SetRange("Project Line No.", "Line No.");
        lrProjectsLineDimension.SetRange("Detailed Line No.", "Entry No.");
        lrProjectsLineDimension.SetRange("Dimension Code", lrGeneralLedgerSetup."Global Dimension 2 Code");
        if lrProjectsLineDimension.Find('-') then begin
            lrProjectsLineDimension."Dimension Value Code" := "Shortcut Dimension 2 Code";
            lrProjectsLineDimension.Modify;
        END
        else begin
            lrProjectsLineDimension.INIT;
            lrProjectsLineDimension."Project No." := "Project Code";
            lrProjectsLineDimension.Type := "Analysis Type";
            lrProjectsLineDimension."Project Version No." := "Version Code";
            lrProjectsLineDimension."Project Line No." := "Line No.";
            lrProjectsLineDimension."Detailed Line No." := "Entry No.";
            lrProjectsLineDimension."Dimension Code" := lrGeneralLedgerSetup."Global Dimension 2 Code";
            lrProjectsLineDimension."Dimension Value Code" := "Shortcut Dimension 2 Code";
            lrProjectsLineDimension.Insert;
        end;
    end;

    procedure GetInvoiceDate() Ret: Date;
    var
        lrPL: Record "Purchase Line";
        lrPH: Record "Purchase Header";
    begin
        // if Close then begin
        //     lrPL.SetCurrentkey("Forecast Entry");
        //     lrPL.SetRange("Forecast Entry", "Entry No.");
        //     if lrPL.FindFirst then begin
        //         lrPH.SetRange("Document Type", lrPL."Document Type");
        //         lrPH.SetRange("No.", lrPL."Document No.");
        //         if lrPH.FindFirst then begin
        //             Ret := lrPH."Paid Date Fact";
        //         end;
        //     end;
        // end;
    end;

    procedure GetInvoiceNo() Ret: Code[20];
    var
        lrPL: Record "Purchase Line";
        lrPH: Record "Purchase Header";
    begin
        // if Close then begin
        //     lrPL.SetCurrentkey("Forecast Entry");
        //     lrPL.SetRange("Forecast Entry", "Entry No.");
        //     if lrPL.FindFirst then begin
        //         lrPH.SetRange("Document Type", lrPL."Document Type");
        //         lrPH.SetRange("No.", lrPL."Document No.");
        //         if lrPH.FindFirst then begin
        //             Ret := lrPH."No.";
        //         end;
        //     end;
        // end;
    end;

    procedure ChangeDate2();
    var
        lrProjectsBudgetEntry: Record "Projects Budget Entry";
        lrProjectsBudgetEntryLink: Record "Projects Budget Entry Link";
        lvAmount: Decimal;
    begin
        //if xRec.Date<>0D then
        begin

            lrProjectsBudgetEntryLink.SetRange("Main Entry No.", "Entry No.");
            if lrProjectsBudgetEntryLink.FindFirst then begin
                lrProjectsBudgetEntryLink.ModifyAll("Project Code", "Project Code");
                lrProjectsBudgetEntryLink.ModifyAll("Version Code", "Version Code");
                lrProjectsBudgetEntryLink.ModifyAll("Line No.", "Line No.");
                lrProjectsBudgetEntryLink.ModifyAll("Project Turn Code", "Project Turn Code");
            end;
        end;
    end;

    procedure GetDefVersion(pProjectCode: Code[20]) Ret: Code[20];
    var
    //lrProjectVersion: Record Table70075;
    begin
        // lrProjectVersion.SetRange("Project Code", pProjectCode);
        // lrProjectVersion.SetRange("Fixed Version");
        // lrProjectVersion.SetRange("First Version", TRUE);
        // if lrProjectVersion.Find('-') then
        //     Ret := lrProjectVersion."Version Code";
    end;

    procedure CheckDuplicateNumber();
    var
        PCCEntryLoc: Record "Projects Cost Control Entry";
        EntryFilter: Text;
    begin
        if (COPYSTR("Doc No.", 1, 3) = 'PAC') OR (COPYSTR("Doc No.", 1, 3) = 'PIB') then begin
            PCCEntryTmp.INIT;
            PCCEntryTmp.TRANSFERFIELDS(Rec);
            PCCEntryTmp.Insert();
            EntryFilter := '';
            PCCEntryTmp.Reset;
            if PCCEntryTmp.FINDSET then
                Repeat
                    if EntryFilter = '' then
                        EntryFilter := '<>' + Format(PCCEntryTmp."Entry No.")
                    else
                        EntryFilter += '&' + '<>' + Format(PCCEntryTmp."Entry No.");
                until PCCEntryTmp.Next = 0;
            PCCEntryLoc.Reset;
            PCCEntryLoc.SetRange("Doc No.", "Doc No.");
            PCCEntryLoc.SetRange("Project Code", "Project Code");
            PCCEntryLoc.SetRange(Amount, Amount);
            PCCEntryLoc.SetFilter("Entry No.", EntryFilter);
            if PCCEntryLoc.FindFirst then
                Error(Text005, PCCEntryLoc."Doc No.");
        end;
    end;

    procedure SetIFRSCost(IFRSCostParam: Boolean);
    begin
        IFRSCost := IFRSCostParam;
    end;

    procedure SetStructurePostTypeIsTotal(skip: Boolean);
    begin
        StructurePostTypeIsTotal := skip;
    end;

    procedure IsProductionProject() Result: Boolean;
    var
        BldProj: Record "Building project";
    begin
        Result := false;
        if "Project Code" <> '' then begin
            BldProj.Get("Project Code");
            Result := BldProj."Development/Production" = BldProj."Development/Production"::Production;
        end;
    end;
}