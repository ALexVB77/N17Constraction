table 70006 "IFRS Account"
{
    Caption = 'IFRS Account';
    DataCaptionFields = "No.", Name;
    // DrillDownPageID = "Chart of Accounts";
    LookupPageID = "Chart of IFRS Accounts";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(4; "Account Type"; Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'Posting,Heading,Total,Begin-Total,End-Total';
            OptionMembers = Posting,Heading,Total,"Begin-Total","End-Total";

            trigger OnValidate()
            begin
                Totaling := '';
            end;
        }
        field(6; "Default Cost Place"; Code[20])
        {
            Caption = 'Default Cost Plase';

            trigger OnLookup()
            var
                DimValue: Record "Dimension Value";
                DimMgt: Codeunit DimensionManagement;
            begin
                GetPurchSetupWithTestDim();
                DimValue.SetRange("Dimension Code", PurchSetup."Cost Place Dimension");
                if Page.RunModal(0, DimValue) = Action::LookupOK then begin
                    if not DimMgt.CheckDimValue(DimValue."Dimension Code", DimValue.Code) then
                        Error(DimMgt.GetDimErr);
                    "Default Cost Place" := DimValue.Code;
                end;
            end;

            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
            begin
                if "Default Cost Place" <> '' then begin
                    GetPurchSetupWithTestDim();
                    if not DimMgt.CheckDimValue(PurchSetup."Cost Place Dimension", "Default Cost Place") then
                        Error(DimMgt.GetDimErr);
                end;
            end;
        }
        field(7; "Default Cost Code"; Code[20])
        {
            Caption = 'Default Cost Code';

            trigger OnLookup()
            var
                DimValue: Record "Dimension Value";
                DimMgt: Codeunit DimensionManagement;
            begin
                GetPurchSetupWithTestDim();
                DimValue.SetRange("Dimension Code", PurchSetup."Cost Code Dimension");
                if Page.RunModal(0, DimValue) = Action::LookupOK then begin
                    if not DimMgt.CheckDimValue(DimValue."Dimension Code", DimValue.Code) then
                        Error(DimMgt.GetDimErr);
                    "Default Cost Code" := DimValue.Code;
                end;
            end;

            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
            begin
                if "Default Cost Code" <> '' then begin
                    GetPurchSetupWithTestDim();
                    if not DimMgt.CheckDimValue(PurchSetup."Cost Code Dimension", "Default Cost Code") then
                        Error(DimMgt.GetDimErr);
                end;
            end;
        }
        field(13; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(19; Indentation; Integer)
        {
            Caption = 'Indentation';
            MinValue = 0;

            trigger OnValidate()
            begin
                if Indentation < 0 then
                    Indentation := 0;
            end;
        }
        field(25; "Last Modified Date Time"; DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }
        field(34; Totaling; Text[250])
        {
            Caption = 'Totaling';

            trigger OnValidate()
            begin
                if not IsTotaling then
                    FieldError("Account Type");
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Name, Blocked)
        {
        }
    }

    trigger OnInsert()
    begin
        "Last Modified Date Time" := CurrentDateTime;
        if Indentation < 0 then
            Indentation := 0;
    end;

    trigger OnModify()
    begin
        "Last Modified Date Time" := CurrentDateTime;
        if Indentation < 0 then
            Indentation := 0;
    end;

    trigger OnDelete()
    var
        MapVersLine: Record "IFRS Stat. Acc. Map. Vers.Line";
        Mapping: Record "IFRS Statutory Account Mapping";
        MapVersion: Record "IFRS Stat. Acc. Map. Vers.";
    begin
        MapVersLine.SetRange("IFRS Account No.", "No.");
        if not MapVersLine.IsEmpty then begin
            MapVersion.SetRange("Version ID", MapVersLine."Version ID");
            MapVersion.FindFirst();
            Error(AccountUseError, "No.", Mapping.TableCaption, MapVersion."IFRS Stat. Acc. Mapping Code", MapVersion."Code");
        end;
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchSetupFound: Boolean;
        AccountUseError: Label 'You cannot delete %1 because this IFRS account is used in %2 %3 version %4.';
        Text001: Label 'You cannot rename %1.';

    procedure IsTotaling(): Boolean
    begin
        exit("Account Type" in ["Account Type"::Total, "Account Type"::"End-Total"]);
    end;

    local procedure GetPurchSetupWithTestDim()
    begin
        if not PurchSetupFound then begin
            PurchSetupFound := true;
            PurchSetup.Get();
            PurchSetup.TestField("Cost Place Dimension");
            PurchSetup.TestField("Cost Code Dimension");
        end;
    end;
}
