table 70037 "Proj. Cost Control Entry Buf."
{
    // LookupPageID = Page70213;
    // DrillDownPageID = Page70213;


    fields
    {
        field(1; "Entry No."; Integer)
        {

        }

        field(2; "Project Code"; Code[20])
        {
            // TableRelation = "Building project";

        }

        field(3; "Analysis Type"; Enum "Analysis Type")
        {
            Caption = 'Analysis type';

        }

        field(4; "Version Code"; Code[20])
        {

        }

        field(5; "Line No."; Integer)
        {

        }

        field(6; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Own Works,Subcontract,Materials,Income';
            OptionMembers = OwnWorks,Subcontract,Materials,Income;
        }

        field(7; Description; Text[250])
        {
            Caption = 'Description';
        }

        field(8; "Description 2"; Text[250])
        {
            Caption = 'Description 2';
        }

        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            trigger OnValidate()
            begin
                IF Curency = '' THEN BEGIN
                    "Amount (LCY)" := Amount;
                END;

                IF NOT gvCreateRepeat THEN
                    CreateRepeatEntry;

                New := FALSE;
            end;


        }

        field(10; Curency; Code[20])
        {
            Caption = 'Curency';
        }

        field(11; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
        }

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

        }

        field(24; "Project Turn Code"; Code[20])
        {
            TableRelation = "Building turn";
            trigger OnValidate()
            var
                lrProjectsBudgetEntryLink: record "Projects Budget Entry Link";
            begin
            end;


        }

        field(25; New; Boolean)
        {

        }

        field(26; "Fixed Version"; Boolean)
        {
            Caption = 'Fixed Version';

        }

        field(27; "Fixed Version Filter"; Boolean)
        {
            FieldClass = FlowFilter;

        }

        field(28; "Budget On Date"; Date)
        {
            Caption = 'Budget On Date';
            FieldClass = FlowFilter;
        }

        field(29; Code; Code[20])
        {
            Caption = 'Code';
        }

        field(30; Linked; Boolean)
        {
            Caption = 'Linked';

        }

        field(31; "Contragent No."; Code[20])
        {
            TableRelation = IF ("Contragent Type" = CONST(Vendor)) Vendor ELSE
            IF ("Contragent Type" = CONST(Customer)) Customer;
            ;
            Caption = 'Contragent No.';
        }

        field(32; "Agreement No."; Code[20])
        {
            TableRelation = IF ("Contragent Type" = CONST(Vendor)) "Vendor Agreement"."No." WHERE("Vendor No." = FIELD("Contragent No."), Active = CONST(true)) ELSE
            IF ("Contragent Type" = CONST(Customer)) "Customer Agreement"."No." WHERE("Customer No." = FIELD("Contragent No."));
            Caption = 'Agreement No.';

        }

        field(33; VAT; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Projects Budget Entry Link".VAT WHERE("Main Entry No." = FIELD("Entry No."), "Project Code" = FIELD("Project Code"), "Analysis Type" = FIELD("Analysis Type"), "Version Code" = FIELD("Version Code"), "Line No." = FIELD("Line No."), "Date" = FIELD("Date"), "Fixed Version" = FIELD("Fixed Version Filter"), "Create Date" = FIELD("Budget On Date"), "Project Turn Code" = FIELD("Project Turn Code")));
            Caption = 'VAT';
        }

        field(34; "Without VAT"; Decimal)
        {
            Caption = 'Without VAT';
        }

        field(35; "Including VAT"; Boolean)
        {
            Caption = 'Including VAT';
        }

        field(36; "Contragent Name"; Text[250])
        {
            Caption = 'Contragent Name';
        }

        field(37; "External Agreement No."; Text[30])
        {
            Caption = 'External Agreement No.';
        }

        field(38; "Linked Entry No."; Integer)
        {

        }

        field(39; "Copy From Sales"; Boolean)
        {

        }

        field(40; "Contragent Type"; Option)
        {
            Caption = 'Contragent Type';
            OptionCaption = 'Vendor,Customer';
            OptionMembers = Vendor,Customer;
            trigger OnValidate()
            begin
                IF "Contragent Type" <> xRec."Contragent Type" THEN BEGIN
                    VALIDATE("Contragent No.", '');
                    VALIDATE("Agreement No.", '');
                END;
            end;


        }

        field(41; "Temp Line No."; Integer)
        {

        }

        field(42; "Temp Amount"; Decimal)
        {
            Caption = 'Amount';

        }

        field(43; "Main Enty No."; Integer)
        {

        }

        field(44; Close; Boolean)
        {
            Caption = 'Close';
            trigger OnValidate()
            begin
                lrProjectsBudgetEntryLink.SETRANGE("Main Entry No.", "Entry No.");
                lrProjectsBudgetEntryLink.SETRANGE("Project Code", "Project Code");
                lrProjectsBudgetEntryLink.SETRANGE("Analysis Type", "Analysis Type");
                lrProjectsBudgetEntryLink.SETRANGE("Version Code", "Version Code");
                IF lrProjectsBudgetEntryLink.FINDFIRST THEN BEGIN
                    REPEAT
                        lrProjectsBudgetEntryLink.Close := Close;
                        lrProjectsBudgetEntryLink.MODIFY;
                    UNTIL lrProjectsBudgetEntryLink.NEXT = 0;
                END;
            end;


        }

        field(45; "Shortcut Dimension 1 Code"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            trigger OnValidate()
            var
                // ApprovalMgt: codeunit "Approvals Management";
                // TemplateRec: record "Approval Templates";
                NextAppr: code[20];
            begin
                ValidateDimension1;
            end;


        }

        field(46; "Shortcut Dimension 2 Code"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            trigger OnValidate()
            begin
                ValidateDimension2;
            end;


        }

        field(47; "Building Turn"; Code[20])
        {
            TableRelation = "Building turn";
            Caption = 'Stage';
            trigger OnValidate()
            begin
                gvBuildingTurn.SETRANGE("Building project Code", "Project Code");
                gvBuildingTurn.SETRANGE(Code, "Building Turn");
                IF gvBuildingTurn.FINDFIRST THEN BEGIN
                    VALIDATE("Shortcut Dimension 1 Code", gvBuildingTurn."Turn Dimension Code");
                    //"Project Turn Code":="Building Turn";
                END;
            end;

            trigger OnLookup()
            begin
                // gvBuildingTurn.SETRANGE("Building project Code","Project Code");
                // IF gvBuildingTurn.FINDFIRST THEN
                // BEGIN
                //   IF PAGE.RUNMODAL(PAGE::"Dev Building turn",gvBuildingTurn) = ACTION::LookupOK THEN
                //   BEGIN
                //     "Building Turn":=gvBuildingTurn.Code;
                //     VALIDATE("Shortcut Dimension 1 Code",gvBuildingTurn."Turn Dimension Code");
                //   //  "Project Turn Code":="Building Turn";

                //   END;
                // END;
            end;


        }

        field(48; "Cost Code"; Code[20])
        {
            Caption = 'Budget Item';
            trigger OnValidate()
            var
                ProjectsLineDimension: record "Projects Line Dimension";
            begin
                grProjectsStructureLines1.SETRANGE("Project Code", "Project Code");
                grProjectsStructureLines1.SETRANGE("Version", "Version Code");
                grProjectsStructureLines1.SETRANGE("Structure Post Type", grProjectsStructureLines1."Structure Post Type"::Posting);
                grProjectsStructureLines1.SETRANGE(Code, "Cost Code");
                IF grProjectsStructureLines1.FINDFIRST THEN BEGIN
                    ProjectsLineDimension.SETRANGE("Project No.", "Project Code");
                    ProjectsLineDimension.SETRANGE("Project Version No.", "Version Code");
                    ProjectsLineDimension.SETRANGE("Project Line No.", grProjectsStructureLines1."Line No.");
                    ProjectsLineDimension.SETRANGE("Detailed Line No.", 0);
                    ProjectsLineDimension.SETRANGE("Dimension Code", 'CC');
                    IF ProjectsLineDimension.FINDFIRST THEN
                        VALIDATE("Shortcut Dimension 2 Code", ProjectsLineDimension."Dimension Value Code");
                    "New Lines" := grProjectsStructureLines1."Line No.";
                    "Line No." := grProjectsStructureLines1."Line No.";
                    Code := grProjectsStructureLines1.Code;
                    Description := grProjectsStructureLines1.Description;
                END;
                ChangeDate2;
            end;

            trigger OnLookup()
            var
                ProjectsLineDimension: record "Projects Line Dimension";
            begin
                // grProjectsStructureLines1.SETRANGE("Project Code","Project Code");
                // grProjectsStructureLines1.SETRANGE(Version,"Version Code");
                // grProjectsStructureLines1.SETRANGE("Structure Post Type",grProjectsStructureLines1."Structure Post Type"::Posting);
                // IF grProjectsStructureLines1.FINDFIRST THEN
                // BEGIN
                //   IF "New Lines"=0 THEN
                //   BEGIN
                //     IF grProjectsStructureLines1.GET("Project Code","Analysis Type","Version Code","Line No.") THEN;
                //   END
                //   ELSE
                //     IF grProjectsStructureLines1.GET("Project Code","Analysis Type","Version Code","New Lines") THEN;

                //   IF PAGE.RUNMODAL(PAGE::"Projects Article List",grProjectsStructureLines1) = ACTION::LookupOK THEN
                //   BEGIN
                //     "Cost Code":=grProjectsStructureLines1.Code;
                //     ProjectsLineDimension.SETRANGE("Project No.","Project Code");
                //     ProjectsLineDimension.SETRANGE("Project Version No.","Version Code");
                //     ProjectsLineDimension.SETRANGE("Project Line No.",grProjectsStructureLines1."Line No.");
                //     ProjectsLineDimension.SETRANGE("Detailed Line No.",0);
                //     ProjectsLineDimension.SETRANGE("Dimension Code",'CC');
                //     IF ProjectsLineDimension.FINDFIRST THEN
                //     VALIDATE("Shortcut Dimension 2 Code",ProjectsLineDimension."Dimension Value Code");

                //     "New Lines":=grProjectsStructureLines1."Line No.";
                //     "Line No.":=grProjectsStructureLines1."Line No.";
                //     Code:=grProjectsStructureLines1.Code;
                //     Description:=grProjectsStructureLines1.Description;
                //   END;
                // END;
                // ChangeDate2;
            end;


        }

        field(49; "New Lines"; Integer)
        {

        }

        field(50; "Not Run OnInsert"; Boolean)
        {

        }

        field(51; "Work Version"; Boolean)
        {
            Caption = 'Work Version';
        }

        field(52; Reserve; Boolean)
        {
            Caption = 'Reserve';
            trigger OnValidate()
            begin
                lrProjectsBudgetEntryLink.SETRANGE("Main Entry No.", "Entry No.");
                lrProjectsBudgetEntryLink.SETRANGE("Project Code", "Project Code");
                lrProjectsBudgetEntryLink.SETRANGE("Analysis Type", "Analysis Type");
                lrProjectsBudgetEntryLink.SETRANGE("Version Code", "Version Code");
                IF lrProjectsBudgetEntryLink.FINDFIRST THEN BEGIN
                    REPEAT
                        lrProjectsBudgetEntryLink.Reserv := Reserve;
                        lrProjectsBudgetEntryLink.MODIFY;
                    UNTIL lrProjectsBudgetEntryLink.NEXT = 0;
                END;
            end;
        }

        field(53; "Building Turn All"; Code[20])
        {
            TableRelation = "Building turn";
            Caption = 'Stage';

        }

        field(54; "Cost Type"; Code[20])
        {
            Caption = 'Cost Type';
            trigger OnLookup()
            begin
                // GLS.GET;
                // DimensionValue.SETRANGE("Dimension Code",GLS."Cost Type Dimension Code");
                // IF DimensionValue.FINDFIRST THEN
                // BEGIN
                //   IF DimensionValue.GET(GLS."Cost Type Dimension Code","Cost Type") THEN;

                //   IF PAGE.RUNMODAL(PAGE::"Dimension Value List",DimensionValue) = ACTION::LookupOK THEN
                //   BEGIN
                //     "Cost Type":=DimensionValue.Code;
                //   END;
                // END;
            end;


        }

        field(55; "Doc No."; Code[20])
        {
            Caption = 'Doc No.';
        }

        field(56; "Doc Type"; Option)
        {
            Caption = 'Doc Type';
            OptionMembers = Pre,Post;

        }

        field(57; "Close Date"; Date)
        {
            Caption = 'Close Date';
        }

        field(60088; "Original Company"; Code[2])
        {
            Description = 'NCS-980';

        }

        field(70018; "Original Date"; Date)
        {
            Caption = 'Original Date';
        }

        field(70019; ID; Integer)
        {

        }

        field(70020; "IFRS Account No."; Text[250])
        {
            FieldClass = FlowField;
            // CalcFormula = Lookup("Budget Correction Journal"."G/L Account Totaling" WHERE (ID=FIELD(ID),"Project Code"=FIELD("Project Code")));;
            Caption = 'IFRS Account No.';
        }

        field(70021; "Frc Version Code"; Code[20])
        {

        }

        field(70022; "Original Ammount"; Decimal)
        {
            Caption = 'Original Ammount';
        }

        field(70023; Reversed; Boolean)
        {
            Caption = 'Reversed';

        }

        field(70024; "Reversed ID"; Integer)
        {
            Caption = 'Reversed ID';
        }

        field(70025; "User Created"; Boolean)
        {
            Caption = 'User Created';
        }

        field(70026; Changed; Boolean)
        {
            FieldClass = Normal;
            Caption = 'Changed';

        }

        field(70027; "Company Name"; Text[60])
        {
            Caption = 'Company Name';
        }

        field(70028; "Allocation Line No."; Integer)
        {

        }

        field(70029; "Template Code"; Code[20])
        {

        }

        field(70030; "Error Line"; Boolean)
        {

        }

        field(70031; "Reversed Without Entry"; Boolean)
        {
            Caption = 'Reversed Without Entry';
        }

        field(70032; "INIT CP"; Code[20])
        {
            Caption = 'INIT CP';
        }

        field(70033; ByOrder; Boolean)
        {
            Caption = 'By Order';
            FieldClass = FlowField;
            // CalcFormula = Lookup("Vendor Agreement".WithOut WHERE ("Vendor No."=FIELD("Contragent No."),"No."=FIELD("Agrrement No.")));
        }

        field(70034; "Close Commitment"; Boolean)
        {

        }


    }


    keys
    {
        key(Key1; "Project Code", "Analysis Type", "Version Code", "Line No.", "Entry No.", "Project Turn Code", "Temp Line No.", "Cost Type")
        {
            Clustered = true;

        }
        key(Key2; "Entry No.")
        {

        }
        key(Key3; "Project Code", "Analysis Type", "Version Code", "Line No.", Date)
        {

        }
        key(Key4; Date)
        {

        }
        key(Key5; "Project Code", "Analysis Type", "Version Code", "Line No.", "Project Turn Code", "Parent Entry", Date)
        {

        }
        key(Key6; "Project Code", "Analysis Type", "Version Code", "Line No.", "Copy From Sales")
        {

        }
        key(Key7; "Project Code", "Analysis Type", "Line No.")
        {
            SumIndexFields = "Without VAT";

        }
        key(Key8; "Doc No.")
        {

        }
        key(Key9; "Project Code", "Line No.", "Building Turn All", "Cost Type")
        {
            SumIndexFields = "Without VAT";

        }
        key(Key10; "Project Code", "Line No.", "Building Turn All", "Cost Type", Date)
        {
            SumIndexFields = "Without VAT";

        }
        key(Key11; "Project Code", "Line No.", "Building Turn All", "Cost Type", "Close Date")
        {
            SumIndexFields = "Without VAT";

        }
        key(Key12; "Reversed Without Entry")
        {

        }
        key(Key13; ID)
        {

        }
        key(Key14; "Create Date")
        {

        }
        key(Key15; "Analysis Type", "Close Commitment")
        {

        }
        key(Key16; "Analysis Type", "Contragent No.", "Agreement No.", "Project Turn Code", "Line No.", "Cost Type")
        {
            SumIndexFields = "Without VAT";

        }
        key(Key17; "Analysis Type", "Contragent No.", "Agreement No.", "Line No.", "Cost Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code")
        {
            SumIndexFields = "Without VAT";

        }
        key(Key18; "Project Code", "Line No.", "Agreement No.", "Analysis Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Cost Type")
        {
            SumIndexFields = "Without VAT";

        }
    }


    fieldgroups
    {
    }

    trigger OnInsert()
    var
        lrGeneralLedgerSetup: record "General Ledger Setup";
        CI: record "Company Information";
    begin
        // IF "Entry No." = 0 THEN
        //   "Entry No." := GetNextEntryNo;

        // "Create User":=USERID;
        // "Create Date":=TODAY;
        // "Create Time":=TIME;

        // BEGIN
        //   lrGeneralLedgerSetup.GET;
        //   grProjectsLineDimension.SETRANGE("Project No.","Project Code");
        //   grProjectsLineDimension.SETRANGE("Project Line No.","Line No.");
        //   grProjectsLineDimension.SETRANGE("Detailed Line No.",0);
        //   grProjectsLineDimension.SETRANGE("Project Version No.",GetDefVersion("Project Code"));
        //   IF grProjectsLineDimension.FIND('-') THEN
        //   BEGIN
        //     REPEAT
        //       IF lrGeneralLedgerSetup."Global Dimension 2 Code" = grProjectsLineDimension."Dimension Code" THEN
        //         "Shortcut Dimension 2 Code":=grProjectsLineDimension."Dimension Value Code";
        //     UNTIL grProjectsLineDimension.NEXT=0;
        //   END;

        //   IF "Project Turn Code"<>'' THEN
        //   BEGIN
        //     grBuildingturn.GET("Project Turn Code");
        //     IF grBuildingturn."Turn Dimension Code"<>'' THEN
        //     BEGIN
        //       "Shortcut Dimension 1 Code":=grBuildingturn."Turn Dimension Code";
        //     END;
        //   END
        //   ELSE
        //   BEGIN
        //     grBuildingProect.GET("Project Code");
        //     IF grBuildingProect."Project Dimension Code"<>'' THEN
        //     BEGIN
        //        "Shortcut Dimension 1 Code":=grBuildingProect."Project Dimension Code";
        //     END;
        //   END;
        // END;

        // CI.GET;
        // IF CI."Company Type"=CI."Company Type"::Housing THEN
        // "Cost Type":='0';

        // IF "Analysis Type"<>"Analysis Type"::Forecast THEN
        // IF "Cost Type"='' THEN
        //   "Cost Type":='0';

        // IF Code = '' THEN ERROR(TEXT0004);
    end;

    trigger OnDelete()
    begin
        grProjectsLineDimension.SETRANGE("Project No.", "Project Code");
        grProjectsLineDimension.SETRANGE(Type, "Analysis Type");
        grProjectsLineDimension.SETRANGE("Project Version No.", "Version Code");
        grProjectsLineDimension.SETRANGE("Project Line No.", "Line No.");
        grProjectsLineDimension.SETRANGE("Detailed Line No.", "Entry No.");
        IF grProjectsLineDimension.FINDFIRST THEN grProjectsLineDimension.DELETEALL;


        lrProjectsBudgetEntryLink.SETRANGE("Main Entry No.", "Entry No.");
        lrProjectsBudgetEntryLink.SETRANGE("Project Code", "Project Code");
        lrProjectsBudgetEntryLink.SETRANGE("Analysis Type", "Analysis Type");
        lrProjectsBudgetEntryLink.SETRANGE("Version Code", "Version Code");
        IF lrProjectsBudgetEntryLink.FINDFIRST THEN lrProjectsBudgetEntryLink.DELETEALL;
    end;



    var
        grProjectsStructureLines: record "Projects Structure Lines";
        grProjectsLineDimension: record "Projects Line Dimension";
        grProjectsLineDimension1: record "Projects Line Dimension";
        grBuildingProect: record "Building project";
        grDevelopmentSetup: record "Development Setup";
        grBuildingturn: record "Building turn";
        TEXT0001: Label 'Create a periodic entries for\%1 ?';
        TEXT0002: Label 'You must specify the ending date of the project!';
        gvCreateRepeat: boolean;
        TEXT0003: Label 'Update related entries?';
        ProjectsLineDimension: record "Projects Line Dimension";
        lrProjectsBudgetEntryLink: record "Projects Budget Entry Link";
        grProjectsStructureLines1: record "Projects Structure Lines";
        gvBuildingTurn: record "Building turn";
        GLS: record "General Ledger Setup";
        DimensionValue: record "Dimension Value";
        TEXT0004: Label 'Cost Code value can not be empty';


    local procedure GetNextEntryNo(): Integer
    var
        GLBudgetEntry: record "Projects Cost Control Entry";
    begin
        GLBudgetEntry.SETCURRENTKEY("Entry No.");
        IF GLBudgetEntry.FINDLAST THEN
            EXIT(GLBudgetEntry."Entry No." + 1)
        ELSE
            EXIT(1);
    end;

    procedure CreateRepeatEntry()
    var
        lrProjectsBudgetEntry: record "Projects Budget Entry";
        lrProjectsStructureLines: record "Projects Structure Lines";
        lrBuildingProject: record "Building project";
        lEndingDate: date;
        lrDate: date;
        lvLastEntry: integer;
    begin
        IF New THEN BEGIN
            lrProjectsStructureLines.SETRANGE("Project Code", "Project Code");
            lrProjectsStructureLines.SETRANGE(Type, "Analysis Type");
            lrProjectsStructureLines.SETRANGE(Version, "Version Code");
            lrProjectsStructureLines.SETRANGE("Line No.", "Line No.");
            IF lrProjectsStructureLines.FIND('-') THEN BEGIN
                IF FORMAT(lrProjectsStructureLines."Repeat Interval") <> '' THEN BEGIN
                    IF CONFIRM(STRSUBSTNO(TEXT0001, lrProjectsStructureLines.Description)) THEN BEGIN
                        IF lrProjectsStructureLines."Ending Date" = 0D THEN BEGIN
                            lrBuildingProject.GET("Project Code");
                            IF lrBuildingProject."Dev. Ending Date" = 0D THEN
                                ERROR(TEXT0002)
                            ELSE
                                lEndingDate := lrBuildingProject."Dev. Ending Date";
                        END
                        ELSE
                            lEndingDate := lrProjectsStructureLines."Ending Date";
                        //----------------------------------------------------
                        "Parent Entry" := "Entry No.";
                        lrDate := Date;
                        lvLastEntry := GetNextEntryNo;
                        REPEAT
                            lrDate := CALCDATE(lrProjectsStructureLines."Repeat Interval", lrDate);
                            IF lrDate <= lEndingDate THEN BEGIN
                                CLEAR(lrProjectsBudgetEntry);
                                lrProjectsBudgetEntry.SetCreateRepeat(TRUE);
                                lrProjectsBudgetEntry.INIT;
                                lrProjectsBudgetEntry.COPY(Rec);
                                lvLastEntry := lvLastEntry + 1;
                                lrProjectsBudgetEntry."Entry No." := lvLastEntry;
                                lrProjectsBudgetEntry.Date := lrDate;
                                lrProjectsBudgetEntry.INSERT(TRUE);
                            END;
                        UNTIL (lrDate > lEndingDate);
                    END;
                END;
            END;
        END
        ELSE BEGIN
            IF "Parent Entry" <> 0 THEN BEGIN
                IF CONFIRM(STRSUBSTNO(TEXT0003, lrProjectsStructureLines.Description)) THEN BEGIN
                    lrProjectsBudgetEntry.SETRANGE("Project Code", "Project Code");
                    lrProjectsBudgetEntry.SETRANGE("Analysis Type", "Analysis Type");
                    lrProjectsBudgetEntry.SETRANGE("Version Code", "Version Code");
                    lrProjectsBudgetEntry.SETRANGE("Line No.", "Line No.");
                    lrProjectsBudgetEntry.SETRANGE("Parent Entry", "Parent Entry");
                    lrProjectsBudgetEntry.SETFILTER("Entry No.", '<>%1', "Entry No.");
                    IF lrProjectsBudgetEntry.FIND('-') THEN BEGIN
                        REPEAT
                            lrProjectsBudgetEntry.SetCreateRepeat(TRUE);
                            lrProjectsBudgetEntry.VALIDATE(Amount, Amount);
                            lrProjectsBudgetEntry.MODIFY;
                        UNTIL lrProjectsBudgetEntry.NEXT = 0;
                    END;
                END;
            END;
        END;
    end;

    procedure SetCreateRepeat(lvCreateRepeat: boolean)
    begin
        gvCreateRepeat := lvCreateRepeat;
    end;

    procedure ValidateDimension()
    var
        lrProjectsLineDimension: record "Projects Line Dimension";
        lrGeneralLedgerSetup: record "General Ledger Setup";
    begin
        lrGeneralLedgerSetup.GET;

        lrProjectsLineDimension.SETRANGE("Project No.", "Project Code");
        lrProjectsLineDimension.SETRANGE("Project Line No.", "Line No.");
        lrProjectsLineDimension.SETRANGE("Detailed Line No.", "Entry No.");
        lrProjectsLineDimension.SETRANGE(Type, "Analysis Type");
        IF lrProjectsLineDimension.FIND('-') THEN BEGIN
            REPEAT
                // IF lrGeneralLedgerSetup."Global Dimension 1 Code" = lrProjectsLineDimension."Dimension Code" THEN
                //   "Shortcut Dimension 1 Code":=lrProjectsLineDimension."Dimension Value Code";

                IF lrGeneralLedgerSetup."Global Dimension 2 Code" = lrProjectsLineDimension."Dimension Code" THEN
                    "Shortcut Dimension 2 Code" := lrProjectsLineDimension."Dimension Value Code";

            UNTIL lrProjectsLineDimension.NEXT = 0;
        END;
    end;

    procedure ValidateDimension1()
    var
        lrProjectsLineDimension: record "Projects Line Dimension";
        lrGeneralLedgerSetup: record "General Ledger Setup";
    begin
        lrGeneralLedgerSetup.GET;
        lrProjectsLineDimension.RESET;
        lrProjectsLineDimension.SETRANGE("Project No.", "Project Code");
        lrProjectsLineDimension.SETRANGE("Project Line No.", "Line No.");
        lrProjectsLineDimension.SETRANGE("Detailed Line No.", "Entry No.");
        lrProjectsLineDimension.SETRANGE("Dimension Code", lrGeneralLedgerSetup."Global Dimension 1 Code");
        IF lrProjectsLineDimension.FIND('-') THEN BEGIN
            lrProjectsLineDimension."Dimension Value Code" := "Shortcut Dimension 1 Code";
            lrProjectsLineDimension.MODIFY;
        END
        ELSE BEGIN
            lrProjectsLineDimension.INIT;
            lrProjectsLineDimension."Project No." := "Project Code";
            lrProjectsLineDimension.Type := "Analysis Type";
            lrProjectsLineDimension."Project Version No." := "Version Code";
            lrProjectsLineDimension."Project Line No." := "Line No.";
            lrProjectsLineDimension."Detailed Line No." := "Entry No.";
            lrProjectsLineDimension."Dimension Code" := lrGeneralLedgerSetup."Global Dimension 1 Code";
            lrProjectsLineDimension."Dimension Value Code" := "Shortcut Dimension 1 Code";
            lrProjectsLineDimension.INSERT;
        END;
    end;

    procedure ValidateDimension2()
    var
        lrProjectsLineDimension: record "Projects Line Dimension";
        lrGeneralLedgerSetup: record "General Ledger Setup";
    begin
        lrGeneralLedgerSetup.GET;
        lrProjectsLineDimension.RESET;
        lrProjectsLineDimension.SETRANGE("Project No.", "Project Code");
        lrProjectsLineDimension.SETRANGE(Type, "Analysis Type");
        lrProjectsLineDimension.SETRANGE("Project Version No.", "Version Code");
        lrProjectsLineDimension.SETRANGE("Project Line No.", "Line No.");
        lrProjectsLineDimension.SETRANGE("Detailed Line No.", "Entry No.");
        lrProjectsLineDimension.SETRANGE("Dimension Code", lrGeneralLedgerSetup."Global Dimension 2 Code");
        IF lrProjectsLineDimension.FIND('-') THEN BEGIN
            lrProjectsLineDimension."Dimension Value Code" := "Shortcut Dimension 2 Code";
            lrProjectsLineDimension.MODIFY;
        END
        ELSE BEGIN
            lrProjectsLineDimension.INIT;
            lrProjectsLineDimension."Project No." := "Project Code";
            lrProjectsLineDimension.Type := "Analysis Type";
            lrProjectsLineDimension."Project Version No." := "Version Code";
            lrProjectsLineDimension."Project Line No." := "Line No.";
            lrProjectsLineDimension."Detailed Line No." := "Entry No.";
            lrProjectsLineDimension."Dimension Code" := lrGeneralLedgerSetup."Global Dimension 2 Code";
            lrProjectsLineDimension."Dimension Value Code" := "Shortcut Dimension 2 Code";
            lrProjectsLineDimension.INSERT;
        END;
    end;

    procedure GetInvoiceDate() Ret: Date
    var
        lrPL: record "Purchase Line";
        lrPH: record "Purchase Header";
    begin
        IF Close THEN BEGIN
            lrPL.SETCURRENTKEY("Forecast Entry");
            lrPL.SETRANGE("Forecast Entry", "Entry No.");
            IF lrPL.FINDFIRST THEN BEGIN
                lrPH.SETRANGE("Document Type", lrPL."Document Type");
                lrPH.SETRANGE("No.", lrPL."Document No.");
                IF lrPH.FINDFIRST THEN BEGIN
                    lrPH.CalcFields("Paid Date Fact");
                    Ret := lrPH."Paid Date Fact";
                END;
            END;
        END;
    end;

    procedure GetInvoiceNo() Ret: Code[20]
    var
        lrPL: record "Purchase Line";
        lrPH: record "Purchase Header";
    begin
        IF Close THEN BEGIN
            lrPL.SETCURRENTKEY("Forecast Entry");
            lrPL.SETRANGE("Forecast Entry", "Entry No.");
            IF lrPL.FINDFIRST THEN BEGIN
                lrPH.SETRANGE("Document Type", lrPL."Document Type");
                lrPH.SETRANGE("No.", lrPL."Document No.");
                IF lrPH.FINDFIRST THEN BEGIN
                    Ret := lrPH."No.";
                END;
            END;
        END;
    end;

    procedure ChangeDate2()
    var
        lrProjectsBudgetEntry: record "Projects Budget Entry";
        lrProjectsBudgetEntryLink: record "Projects Budget Entry Link";
        lvAmount: decimal;
    begin
        //IF xRec.Date<>0D THEN
        BEGIN

            lrProjectsBudgetEntryLink.SETRANGE("Main Entry No.", "Entry No.");
            IF lrProjectsBudgetEntryLink.FINDFIRST THEN BEGIN
                lrProjectsBudgetEntryLink.MODIFYALL("Project Code", "Project Code");
                lrProjectsBudgetEntryLink.MODIFYALL("Version Code", "Version Code");
                lrProjectsBudgetEntryLink.MODIFYALL("Line No.", "Line No.");
                lrProjectsBudgetEntryLink.MODIFYALL("Project Turn Code", "Project Turn Code");
            END;
        END;
    end;

    // procedure GetDefVersion(pProjectCode: code[20]) Ret: Code[20]
    // var 
    //     lrProjectVersion: record "Project Version";
    // begin
    //     //lrProjectVersion.SETRANGE("Project Code",pProjectCode);
    //     //lrProjectVersion.SETRANGE("Fixed Version",TRUE);
    //     //IF lrProjectVersion.FIND('-') THEN
    //     //  Ret:=lrProjectVersion."Version Code"
    //     //ELSE
    //     //BEGIN
    //     lrProjectVersion.SETRANGE("Project Code",pProjectCode);
    //     lrProjectVersion.SETRANGE("Fixed Version");
    //     lrProjectVersion.SETRANGE("First Version",TRUE);
    //     IF lrProjectVersion.FIND('-') THEN
    //       Ret:=lrProjectVersion."Version Code";
    //     //END;
    // end;


}


