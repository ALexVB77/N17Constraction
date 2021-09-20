table 70026 "Budget Correction"
{
    Caption = 'Budget Correction';
    LookupPageId = "Budget Corrections";
    DrillDownPageId = "Budget Corrections";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Name; Text[250])
        {
            Caption = 'Name';
        }
        field(3; "Dimension Totaling 1"; Text[250])
        {
            Caption = 'Dimension 1';
            CaptionClass = GetCaptionClass(1);
        }
        field(4; "Dimension Totaling 2"; Text[250])
        {
            Caption = 'Dimension 2';
            CaptionClass = GetCaptionClass(2);
        }
        field(5; "G/L Account Totaling"; Text[250])
        {
            Caption = 'Account';
        }

        field(6; "Period Group Type"; Option)
        {
            Caption = 'Group';
            OptionMembers = " ",Day,Week,Month;
            OptionCaption = 'No,Day,Week,Month';
        }
        field(7; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(8; "Journal Template Name"; Code[100])
        {
            Caption = 'Journal Template Name';
            trigger OnValidate()
            begin
                "Journal Batch Name" := '';
            end;

            trigger OnLookup()
            begin
                GJT.RESET;
                IF "Company Name" <> '' THEN
                    GJT.CHANGECOMPANY("Company Name")
                ELSE
                    GJT.CHANGECOMPANY(COMPANYNAME);
                IF GJT.GET("Journal Template Name") THEN;

                IF Page.RUNMODAL(0, GJT) = ACTION::LookupOK THEN
                    VALIDATE("Journal Template Name", GJT.Name);
            end;
        }
        field(9; "Journal Batch Name"; Code[100])
        {
            Caption = 'Journal Batch Name';
            trigger OnLookup()
            begin

                GJB.RESET;
                IF "Company Name" <> '' THEN
                    GJB.CHANGECOMPANY("Company Name")
                ELSE
                    GJB.CHANGECOMPANY(COMPANYNAME);

                GJB.SETRANGE("Journal Template Name", "Journal Template Name");
                IF GJB.FINDFIRST THEN;

                IF Page.RUNMODAL(0, GJB) = ACTION::LookupOK THEN
                    VALIDATE("Journal Batch Name", GJB.Name);
            end;
        }
        field(10; "Source Code"; Code[100])
        {
            Caption = 'Source Code';
            trigger OnLookup()
            begin

                SC.RESET;
                IF "Company Name" <> '' THEN
                    SC.CHANGECOMPANY("Company Name")
                ELSE
                    SC.CHANGECOMPANY(COMPANYNAME);
                IF SC.GET("Source Code") THEN;

                IF Page.RUNMODAL(0, SC) = ACTION::LookupOK THEN
                    "Source Code" := SC.Code;
            end;
        }
        field(11; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
        }
        field(12; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = " ",Active;
            OptionCaption = ' ,Active';
        }
        field(13; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
        }
        field(14; "Correction Batch"; Boolean)
        {
            Caption = 'Batch Adjustments';
        }
        field(19; "G/L Account Totaling 1"; Text[250])
        {
            Caption = 'Account 1';
        }
        field(20; "G/L Account Totaling 2"; Text[250])
        {
            Caption = 'Account 2';
        }
        field(21; "G/L Account Totaling 3"; Text[250])
        {
            Caption = 'Account 3';
        }
        field(60088; "Original Company"; Code[2])
        {
            Caption = 'Original Company';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    var
        GLSetup: Record "General Ledger Setup";
        GJT: Record "Gen. Journal Template";
        GJB: Record "Gen. Journal Batch";
        SC: Record "Source Code";
        Text001: Label '1,1,1';
        Text002: Label '1,1,2';
        Text003: Label 'You cannot register line. Budget Correction with these parameters already exists!';

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure LookUpDimFilter(DimNo: integer; var Text: text[250]): boolean
    var
        DimVal: record "Dimension Value";
        DimValList: page "Dimension Value List";
    begin
        GLSetup.GET;

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
        //DimValList.SetCompany("Company Name");
        DimValList.LOOKUPMODE(TRUE);
        DimValList.SETTABLEVIEW(DimVal);
        IF DimValList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            DimValList.GETRECORD(DimVal);

            Text := Text + DimValList.GetSelectionFilter;

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