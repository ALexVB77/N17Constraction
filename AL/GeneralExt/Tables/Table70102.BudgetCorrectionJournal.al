table 70102 "Budget Correction Journal"
{
    Permissions = TableData 17 = rm;
    // LookupPageID = Page70187;
    // DrillDownPageID = Page70187;


    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'ID';
        }

        field(2; Code; Code[20])
        {
            Caption = 'Code';

        }

        field(3; Name; Text[250])
        {
            Caption = 'Name';

        }

        field(4; "Dimension Totaling 1"; Code[20])
        {
            CaptionClass = GetCaptionClass(1);
            Caption = 'Dimension 1';

        }

        field(5; "Dimension Totaling 2"; Code[20])
        {
            CaptionClass = GetCaptionClass(2);
            Caption = 'Dimension 2';

        }

        field(6; "G/L Account Totaling"; Text[250])
        {
            Caption = 'Account';

        }

        field(7; "Priod Group Type"; Option)
        {
            Caption = 'Group';
            OptionCaption = 'Day,Week,Month';
            OptionMembers = Day,Week,Month;

        }

        field(8; Description; Text[250])
        {
            Caption = 'Description';

        }

        field(9; "Journal Template Name"; Code[100])
        {
            TableRelation = "Gen. Journal Template";
            Caption = 'Batch Jornal Name';

        }

        field(10; "Journal Batch Name"; Code[100])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
            Caption = 'Code Batch Journal';

        }

        field(11; "Source Code"; Code[10])
        {
            TableRelation = "Source Code";
            Caption = 'Source Code';

        }

        field(12; "Company Name"; Text[30])
        {
            TableRelation = Company;
            Caption = 'Company';

        }

        field(13; Date; Date)
        {
            Caption = 'Date';

        }

        field(14; Amount; Decimal)
        {
            Caption = 'Amount';

        }

        field(15; "Project Code"; Code[20])
        {
            // TableRelation = "Building project";
            Caption = 'Investment Code';

        }

        // field(16; "Apply Amount"; Decimal)
        // {
        //     FieldClass = FlowField;
        //     CalcFormula = Sum("Apply Budget Correction"."Apply Amount" WHERE ("Budget Journal ID"=FIELD(ID)));
        //     Editable = false;
        //     Caption = 'Applications Amount';

        // }

        // field(17; "Apply Corrections"; Boolean)
        // {
        //     FieldClass = FlowField;
        //     CalcFormula = Exist("Projects Budget Entry" WHERE ("Project Code"=FIELD("Project Code"), "Shortcut Dimension 1 Code"=FIELD("Dimension Totaling 1"), "Shortcut Dimension 2 Code"=FIELD("Dimension Totaling 2"), "Work Version"=CONST(Yes), Close=CONST(No)));
        //     Editable = false;
        //     Caption = 'There is a budget line';

        // }

        field(18; "Diff Amount"; Decimal)
        {
            Caption = 'Balance';

        }

        field(19; Posted; Boolean)
        {
            Caption = 'Posted';

        }

        field(20; "Dimension Error"; Boolean)
        {
            Caption = 'Dimension Error';
        }

        field(21; "Budget Amount"; Decimal)
        {
            Caption = 'Budget Entry';

        }

        field(22; "Correction Batch"; Boolean)
        {
            Caption = 'Batch Correction';

        }

        field(23; "Entry No"; Integer)
        {
            Caption = 'Entry No.';
        }

        field(24; "Doc No"; Code[20])
        {
            Caption = 'Document No.';

        }

        field(25; "Agreement No."; Code[20])
        {
            TableRelation = "Vendor Agreement"."No.";
            Caption = 'Agreement No.';

        }

        field(26; "Vendor No."; Code[20])
        {

            Caption = 'Vendor No.';

        }

        field(27; "External Agreement No."; Text[30])
        {

            Caption = 'External Agreement No.';

        }

        field(28; "Vendor Name"; Text[250])
        {

            Caption = 'Vendor Name';

        }

        field(50000; "Amount 2"; Decimal)
        {
            BlankZero = true;
            Editable = false;
            Caption = 'Amount (New)';

        }

        field(50001; "Amount Including VAT 2"; Decimal)
        {
            BlankZero = true;
            Editable = false;
            Caption = 'Amount Including VAT (new)';

        }

        field(50002; "VAT Amount 2"; Decimal)
        {
            BlankZero = true;
            Editable = false;
            Caption = 'VAT Amount (new)';

        }

        field(50003; "VAT %"; Decimal)
        {
            Caption = 'VAT %';

        }

        field(60088; "Original Company"; Code[2])
        {
            Caption = 'Original Company';

        }

        field(70016; "Cost Type"; Code[20])
        {
            Caption = 'COST TYPE';
            trigger OnLookup()
            var
                GLS: record "General Ledger Setup";
                DimensionValue: record "Dimension Value";

            begin
                GLS.GET;
                DimensionValue.SETRANGE("Dimension Code", GLS."Cost Type Dimension Code");
                IF DimensionValue.FINDFIRST THEN BEGIN
                    IF DimensionValue.GET(GLS."Cost Type Dimension Code", "Cost Type") THEN;

                    IF PAGE.RUNMODAL(PAGE::"Dimension Value List", DimensionValue) = ACTION::LookupOK THEN BEGIN
                        "Cost Type" := DimensionValue.Code;
                    END;
                END;
            end;


        }

        field(70017; Advances; Boolean)
        {
            Caption = 'Advances';
        }

        field(70018; "Original Date"; Date)
        {
            Caption = 'Original Date';

        }

        field(70019; "Exist Error"; Boolean)
        {
            Caption = 'Exist Error';
        }

        field(70020; RecognitionOfExpenses; Boolean)
        {
            Caption = 'Recognition of Expenses';
        }

        field(70021; "Original Amount"; Decimal)
        {
            Caption = 'Original Amount';

        }

        field(70022; Reversed; Boolean)
        {
            Caption = 'Reversed';

        }

        field(70024; "Reversed ID"; Integer)
        {
            Caption = 'Reversed ID';

        }

        field(70025; Allocation; Boolean)
        {
            Caption = 'Allocation';
        }

        field(70026; "Real Contragent No."; Code[20])
        {
            Caption = 'Real Contragent no.';
        }

        field(70027; "Real Contragent Name"; Text[250])
        {
            Caption = 'Real Contragent Name';
        }

        field(70028; "Real External Agreement No."; Text[30])
        {
            Caption = 'Real External Agreement No.';
        }

        field(70029; "Exist Entry"; Boolean)
        {
            Caption = 'Exist Entry';
        }

        // field(70030; "Exist Linck Entry"; Boolean)
        // {
        //     FieldClass = FlowField;
        //     CalcFormula = Exist("Projects Cost Control Entry" WHERE(ID = FIELD(ID)));

        // }

        field(70031; "Real Agreement No."; Code[20])
        {
            Caption = 'Real Agreement No.';
        }

        field(70032; "User id"; Code[20])
        {
            Caption = 'User Id';

        }

        field(70033; "Creation Date"; Date)
        {
            Caption = 'Creation Date';

        }


    }


    keys
    {
        key(Key1; ID, "Company Name")
        {
            Clustered = true;

        }
        key(Key2; "Project Code")
        {

        }
        key(Key3; "Entry No", "Project Code")
        {

        }
    }



    trigger OnInsert()
    begin
        //SWC768 KAE 290616 >>
        "User id" := USERID;
        "Creation Date" := TODAY;
        //SWC768 KAE 290616 <<
    end;

    trigger OnDelete()
    var
        ProjectsCostControlEntry: record "Projects Cost Control Entry";
    begin
        //EXIT;
        GLE.RESET;
        GLE.SETCURRENTKEY("G/L Account No.", "Posting Date", "Journal Batch Name",
          "Global Dimension 1 Code", "Global Dimension 2 Code", "Source Code"
        //   ,ID
        );
        IF "Company Name" <> '' THEN
            GLE.CHANGECOMPANY("Company Name")
        ELSE
            GLE.CHANGECOMPANY(COMPANYNAME);
        IF "Dimension Totaling 1" <> '' THEN
            GLE.SETFILTER("Global Dimension 1 Code", "Dimension Totaling 1");
        IF "Dimension Totaling 2" <> '' THEN
            GLE.SETFILTER("Global Dimension 2 Code", "Dimension Totaling 2");
        IF "G/L Account Totaling" <> '' THEN
            GLE.SETFILTER("G/L Account No.", "G/L Account Totaling");
        IF "Journal Batch Name" <> '' THEN
            GLE.SETFILTER("Journal Batch Name", "Journal Batch Name");
        IF "Source Code" <> '' THEN
            GLE.SETFILTER("Source Code", "Source Code");

        CASE "Priod Group Type" OF
            "Priod Group Type"::Day:
                GLE.SETRANGE("Posting Date", Date, Date);
            "Priod Group Type"::Week:
                GLE.SETRANGE("Posting Date", Date, CALCDATE('<CW>', Date));
            "Priod Group Type"::Month:
                GLE.SETRANGE("Posting Date", Date, CALCDATE('<CM>', Date));
        END;

        GLE.RESET;
        GLE.SETCURRENTKEY("G/L Account No.", "Posting Date", "Journal Batch Name",
          "Global Dimension 1 Code", "Global Dimension 2 Code", "Source Code"
        //   , ID
          );

        GLE.CHANGECOMPANY("Company Name");

        // IF GLE.GET("Entry No") THEN BEGIN
        //     GLE.ID := 0;
        //     GLE.MODIFY;
        // END;



        // ABC.RESET;
        // ABC.SETRANGE("Budget Journal ID", ID);
        // IF NOT ABC.ISEMPTY THEN
        //     ABC.DELETEALL;
    end;



    var
        GLSetup: record "General Ledger Setup";
        Text001: Label '1,1,1';
        Text002: Label '1,1,2';
        GLE: record "G/L Entry";
        // ABC: record "Apply Budget Correction";
        GLE1: record "G/L Entry";


    procedure LookUpDimFilter(DimNo: integer; var Text: text[250]): boolean
    var
        DimVal: record "Dimension Value";
        DimValList: page "Dimension Value List";
    begin
        GLSetup.GET;

        DimVal.RESET;
        IF "Company Name" <> '' THEN
            DimVal.CHANGECOMPANY("Company Name")
        ELSE
            DimVal.CHANGECOMPANY(COMPANYNAME);

        CASE DimNo OF
            1:
                DimVal.SETRANGE("Dimension Code", GLSetup."Global Dimension 1 Code");
            2:
                DimVal.SETRANGE("Dimension Code", GLSetup."Global Dimension 2 Code");
            3:
                DimVal.SETRANGE("Dimension Code", GLSetup."Shortcut Dimension 3 Code");
            4:
                DimVal.SETRANGE("Dimension Code", GLSetup."Shortcut Dimension 4 Code");
        END;
        IF DimVal.FINDFIRST THEN;

        CASE DimNo OF
            1:
                IF DimVal.GET(GLSetup."Global Dimension 1 Code", "Dimension Totaling 1") THEN
                    ;
            2:
                IF DimVal.GET(GLSetup."Global Dimension 2 Code", "Dimension Totaling 2") THEN
                    ;
        END;

        //DimValList.SetCompany("Company Name");
        DimValList.LOOKUPMODE(TRUE);
        DimValList.GETRECORD(DimVal);
        DimValList.SETTABLEVIEW(DimVal);
        IF DimValList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            DimValList.GETRECORD(DimVal);
            //Text := Text + DimValList.GetSelectionFilter;
            Text := DimVal.Code;
            EXIT(TRUE);
        END ELSE
            EXIT(FALSE)
    end;

    procedure GetCaptionClass(i: integer): text[250]
    begin
        CASE i OF
            1:
                EXIT(Text001);
            2:
                EXIT(Text002);
        END;
    end;


}