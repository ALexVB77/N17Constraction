table 70005 "IFRS Stat. Acc. Map. Vers.Line"
{
    Caption = 'IFRS Stat. Acc. Map. Vers.Line';

    fields
    {
        field(1; "Version ID"; Guid)
        {
            Caption = 'Version ID';
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Stat. Acc. Account No."; Code[20])
        {
            Caption = 'Stat. Acc. Account No.';
            NotBlank = true;
            TableRelation = "G/L Account"."No." Where("Account Type" = Const(Posting), Blocked = const(false));
        }
        field(4; "Cost Place Code"; Code[20])
        {
            Caption = 'Cost Place Code';

            trigger OnLookup()
            var
                DimValue: Record "Dimension Value";
                DimMgt: Codeunit DimensionManagement;
            begin
                GetPurchSetupWithTestDim(1);
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
                    GetPurchSetupWithTestDim(1);
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
                GetPurchSetupWithTestDim(2);
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
                    GetPurchSetupWithTestDim(2);
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
        field(7; "Rule ID"; Guid)
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
        key(Key1; "Version ID", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Stat. Acc. Account No.", "Cost Place Code", "Cost Code Code")
        {
        }
        key(Key3; "Rule ID")
        {
        }
    }

    trigger OnInsert()
    begin
        CheckDuplicate();
        CheckUsed();
        "Rule ID" := CreateGuid();
    end;

    trigger OnModify()
    begin
        CheckDuplicate();
        CheckUsed();
    end;

    trigger OnDelete()
    begin
        CheckUsed();
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchSetupFound: Boolean;
        Text001: Label 'You cannot rename %1.';
        Text002: Label 'You cannot change %1 because it is used in %1 %2.';
        DubErrorText: Label 'This setting already exists in this version (line %1).';
        DimError1Text: Label 'A rule has already been defined with an empty value of dimension %1 for G/L Account %2 (line %3).';
        DimError2Text: Label 'A rule has already been defined with a specific value of dimension %1 for G/L Account %2 (line %3).';

    local procedure GetPurchSetupWithTestDim(TestDimType: option "",CostPlace,CostCode)
    begin
        if not PurchSetupFound then begin
            PurchSetupFound := true;
            PurchSetup.Get();
            case TestDimType of
                TestDimType::CostPlace:
                    PurchSetup.TestField("Cost Place Dimension");
                TestDimType::CostCode:
                    PurchSetup.TestField("Cost Code Dimension");
            end;
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
            ShowErrorAsMessage(StrSubstNo(Text002, TableCaption, GLSetup.TableCaption, GLSetup.FieldCaption("IFRS Stat. Acc. Map. Vers.Code")));
    end;

    local procedure CheckDuplicate()
    var
        MapVerLine: Record "IFRS Stat. Acc. Map. Vers.Line";
    begin
        MapVerLine.SetRange("Version ID", "Version ID");
        MapVerLine.SetFilter("Line No.", '<>%1', "Line No.");
        MapVerLine.SetRange("Stat. Acc. Account No.", "Stat. Acc. Account No.");
        MapVerLine.SetRange("Cost Place Code", "Cost Place Code");
        MapVerLine.SetRange("Cost Code Code", "Cost Code Code");
        if MapVerLine.FindFirst() then
            ShowErrorAsMessage(StrSubstNo(DubErrorText, MapVerLine."Line No."));
        MapVerLine.SetRange("Cost Place Code");
        MapVerLine.SetRange("Cost Code Code");

        GetPurchSetupWithTestDim(0);
        if "Cost Place Code" <> '' then begin
            MapVerLine.SetRange("Cost Place Code", '');
            if MapVerLine.FindFirst() then
                ShowErrorAsMessage(StrSubstNo(DimError1Text, PurchSetup."Cost Place Dimension", "Stat. Acc. Account No.", MapVerLine."Line No."));
        end else begin
            MapVerLine.SetFilter("Cost Place Code", '<>%1', '');
            if MapVerLine.FindFirst() then
                ShowErrorAsMessage(StrSubstNo(DimError2Text, PurchSetup."Cost Place Dimension", "Stat. Acc. Account No.", MapVerLine."Line No."));
        end;
        MapVerLine.SetRange("Cost Place Code");

        if "Cost Code Code" <> '' then begin
            MapVerLine.SetRange("Cost Code Code", '');
            if MapVerLine.FindFirst() then
                ShowErrorAsMessage(StrSubstNo(DimError1Text, PurchSetup."Cost Code Dimension", "Stat. Acc. Account No.", MapVerLine."Line No."));
        end else begin
            MapVerLine.SetFilter("Cost Code Code", '<>%1', '');
            if MapVerLine.FindFirst() then
                ShowErrorAsMessage(StrSubstNo(DimError2Text, PurchSetup."Cost Code Dimension", "Stat. Acc. Account No.", MapVerLine."Line No."));
        end;
    end;

    // при вызове из триггеров OnInsert и OnModify - не выводится код ошибки в ленту сообщений.
    // поэтому выводим через Message()  
    local procedure ShowErrorAsMessage(ErrorText: text)
    begin
        Message(ErrorText);
        Error(ErrorText);
    end;

    procedure GetDimCaptionClass(DimType: option CostPlace,CostCode; IsName: Boolean): Text
    var
        DimParam2: text;
        NameText: Label ' - Name';
    begin
        GetPurchSetupWithTestDim(0);
        if IsName then
            DimParam2 := NameText;
        case DimType of
            DimType::CostPlace:
                if PurchSetup."Cost Place Dimension" = '' then
                    exit(FieldCaption("Cost Place Code"))
                else
                    exit('1,5,' + PurchSetup."Cost Place Dimension" + ',,' + DimParam2);
            DimType::CostCode:
                if PurchSetup."Cost Code Dimension" = '' then
                    exit(FieldCaption("Cost Code Code"))
                else
                    exit('1,5,' + PurchSetup."Cost Code Dimension" + ',,' + DimParam2);
        end;
    end;

    procedure GetDimensionName(DimType: option CostPlace,CostCode; DimValueCode: code[20]): text
    var
        DimValue: Record "Dimension Value";
        DimCode: code[20];
    begin
        GetPurchSetupWithTestDim(0);
        if DimValueCode = '' then
            exit('');
        case DimType of
            DimType::CostPlace:
                DimCode := PurchSetup."Cost Place Dimension";
            DimType::CostCode:
                DimCode := PurchSetup."Cost Code Dimension";
        end;
        if DimCode = '' then
            exit;
        DimValue.SetRange("Dimension Code", DimCode);
        DimValue.SetRange(Code, DimValueCode);
        if DimValue.FindFirst() then
            exit(DimValue.Name);
    end;
}

