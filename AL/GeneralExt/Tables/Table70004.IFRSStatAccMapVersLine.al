table 70004 "IFRS Stat. Acc. Map. Vers.Line"
{
    Caption = 'IFRS Stat. Acc. Map. Vers.Line';

    fields
    {
        field(1; "Version ID"; Guid)
        {
            Caption = 'Version ID';
            Editable = false;
            NotBlank = true;
        }
        field(2; "Stat. Acc. Account No."; Code[20])
        {
            Caption = 'Stat. Acc. Account No.';
            NotBlank = true;
            TableRelation = "G/L Account"."No." Where("Account Type" = Const(Posting), Blocked = const(false));
        }
        field(3; "Cost Place Code"; Code[20])
        {
            Caption = 'Cost Place Code';

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
                    "Cost Place Code" := DimValue.Code;
                end;
            end;

            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
            begin
                if "Cost Place Code" <> '' then begin
                    GetPurchSetupWithTestDim();
                    if not DimMgt.CheckDimValue(PurchSetup."Cost Place Dimension", "Cost Place Code") then
                        Error(DimMgt.GetDimErr);
                end;
            end;
        }
        field(4; "Cost Code Code"; Code[20])
        {
            Caption = 'Cost Code Code';

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
                    "Cost Code Code" := DimValue.Code;
                end;
            end;

            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
            begin
                if "Cost Code Code" <> '' then begin
                    GetPurchSetupWithTestDim();
                    if not DimMgt.CheckDimValue(PurchSetup."Cost Code Dimension", "Cost Code Code") then
                        Error(DimMgt.GetDimErr);
                end;
            end;
        }
        field(5; "IFRS Account No."; Code[50])
        {
            Caption = 'IFRS Account No.';
            NotBlank = true;
            TableRelation = "IFRS Account";

            trigger OnValidate()
            var
                IFRSAcc: Record "IFRS Account";
            begin
                if "IFRS Account No." <> '' then begin
                    IFRSAcc.Get("IFRS Account No.");
                    if ("Cost Place Code" = '') and (IFRSAcc."Default Cost Place" <> '') then
                        "Cost Place Code" := IFRSAcc."Default Cost Place";
                    if ("Cost Code Code" = '') and (IFRSAcc."Default Cost Code" <> '') then
                        "Cost Code Code" := IFRSAcc."Default Cost Code";
                end;
            end;
        }
        field(6; "Rule ID"; Guid)
        {
            Caption = 'Rule ID';
            Editable = false;
        }
        field(10; "Stat. Acc. Account Name"; Text[100])
        {
            CalcFormula = lookup("G/L Account".Name where("No." = field("Stat. Acc. Account No.")));
            Caption = 'Stat. Acc. Account Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "IFRS Account Name"; Text[100])
        {
            CalcFormula = lookup("IFRS Account".Name where("No." = field("IFRS Account No.")));
            Caption = 'IFRS Account Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Version ID", "Stat. Acc. Account No.", "Cost Place Code", "Cost Code Code")
        {
            Clustered = true;
        }
        key(Key2; "Rule ID")
        {
        }
    }

    trigger OnInsert()
    begin
        CheckUsed();
        "Rule ID" := CreateGuid();
    end;

    trigger OnModify()
    begin
        CheckUsed();
    end;

    trigger OnDelete()
    begin
        CheckUsed();
    end;

    trigger OnRename()
    begin
        CheckUsed();
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchSetupFound: Boolean;
        Text002: Label 'You cannot change %1 because it is used in %1 %2.';

    local procedure GetPurchSetupWithTestDim()
    begin
        if not PurchSetupFound then begin
            PurchSetupFound := true;
            PurchSetup.Get();
            PurchSetup.TestField("Cost Place Dimension");
            PurchSetup.TestField("Cost Code Dimension");
        end;
    end;

    local procedure CheckUsed()
    var
        GLSetup: Record "General Ledger Setup";
        MappingVersion: Record "IFRS Stat. Acc. Map. Vers.";
    begin
        GLSetup.Get();
        if '' in [GLSetup."IFRS Stat. Acc. Map. Code", GLSetup."IFRS Stat. Acc. Map. Vers.Code"] then
            exit;
        MappingVersion.SetRange("Version ID", "Version ID");
        MappingVersion.FindFirst();
        if (GLSetup."IFRS Stat. Acc. Map. Code" = MappingVersion."IFRS Stat. Acc. Mapping Code") and
            (GLSetup."IFRS Stat. Acc. Map. Vers.Code" = MappingVersion."Code")
        then
            Error(Text002, TableCaption, GLSetup.TableCaption, GLSetup.FieldCaption("IFRS Stat. Acc. Map. Vers.Code"));
    end;

    procedure GetDimensionName(DimType: option CostPlace,CostCode; DimValueCode: code[20]): text
    var
        DimValue: Record "Dimension Value";
    begin
        GetPurchSetupWithTestDim();
        if DimValueCode = '' then
            exit('');
        case DimType of
            DimType::CostPlace:
                DimValue.SetRange("Dimension Code", PurchSetup."Cost Place Dimension");
            DimType::CostCode:
                DimValue.SetRange("Dimension Code", PurchSetup."Cost Code Dimension");
        end;
        DimValue.SetRange(Code, DimValueCode);
        if DimValue.FindFirst() then
            exit(DimValue.Name);
    end;
}

