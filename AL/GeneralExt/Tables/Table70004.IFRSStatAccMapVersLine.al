table 70004 "IFRS Stat. Acc. Map. Vers.Line"
{
    Caption = 'IFRS Stat. Acc. Map. Vers.Line';

    fields
    {
        field(1; "IFRS Stat. Acc. Mapping Code"; code[20])
        {
            Caption = 'IFRS Stat. Acc. Mapping Code';
            NotBlank = true;
            TableRelation = "IFRS Statutory Account Mapping";
        }
        field(2; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            NotBlank = true;
            TableRelation = "IFRS Stat. Acc. Map. Vers."."Code" WHERE("IFRS Stat. Acc. Mapping Code" = FIELD("IFRS Stat. Acc. Mapping Code"));
        }
        field(3; "Stat. Acc. Account No."; Code[20])
        {
            Caption = 'Stat. Acc. Account No.';
            NotBlank = true;
            TableRelation = "G/L Account"."No." Where("Account Type" = Const(Posting));
        }
        field(4; "Cost Place Code"; Code[20])
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
        field(5; "Cost Code Code"; Code[20])
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
        field(6; "IFRS Account No."; Code[50])
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
        key(Key1; "IFRS Stat. Acc. Mapping Code", "Version Code", "Stat. Acc. Account No.", "Cost Place Code", "Cost Code Code")
        {
            Clustered = true;
        }
    }

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
    begin
        GLSetup.Get();
        if (GLSetup."IFRS Stat. Acc. Map. Code" = Rec."IFRS Stat. Acc. Mapping Code") and
            (GLSetup."IFRS Stat. Acc. Map. Vers.Code" = Rec."Version Code")
        then
            Error(Text002, TableCaption, GLSetup.TableCaption, GLSetup.FieldCaption("IFRS Stat. Acc. Map. Vers.Code"));
    end;
}
