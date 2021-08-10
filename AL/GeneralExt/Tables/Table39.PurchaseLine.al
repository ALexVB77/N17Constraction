tableextension 80039 "Purchase Line (Ext)" extends "Purchase Line"
{
    fields
    {
        field(50000; "Linked Dimension Value Code"; code[20])
        {
            Description = 'NC 51373 AB';
            Caption = 'Linked Dimension Value Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
        }
        field(50001; "Linked Dimension Filter"; code[20])
        {
            Description = 'NC 51373 AB';
            Caption = 'Linked Dimension Filter';
            FieldClass = FlowFilter;
            TableRelation = Dimension;
        }
        field(70000; "Full Description"; Text[250])
        {
            Description = 'NC 51373 AB';
            Caption = 'Description';

            trigger OnValidate()
            begin
                Description := COPYSTR("Full Description", 1, MaxStrLen(Description));
                "Description 2" := COPYSTR("Full Description", MaxStrLen(Description) + 1, MaxStrLen("Description 2"));
            end;
        }
        field(70001; "Not VAT"; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Without VAT';

            trigger OnValidate()
            begin
                IF xRec."Not VAT" <> "Not VAT" THEN
                    CheckProductionPrjDataModify(xRec."Dimension Set ID");
                IF "Not VAT" THEN BEGIN
                    PurchSetup.Get();
                    PurchSetup.TestField("Zero VAT Prod. Posting Group");
                    "Old VAT Prod. Posting Group" := "VAT Prod. Posting Group";
                    VALIDATE("VAT Prod. Posting Group", PurchSetup."Zero VAT Prod. Posting Group");
                END ELSE
                    VALIDATE("VAT Prod. Posting Group", "Old VAT Prod. Posting Group");
            end;
        }
        field(70002; "Old VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'Old VAT Prod. Posting Group';
            Description = 'NC 51373 AB';
        }
        field(70003; "Forecast Entry"; Integer)
        {
            Caption = 'Forecast Entry';
            Description = '50086';
        }
        field(70004; IW; Boolean)
        {
            Caption = 'IW';
            Description = '50085';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."IW Documents" where("Document Type" = field("Document Type"), "No." = field("Document No.")));
        }
        field(70006; "Buy-from Vendor Name"; Text[100])
        {
            CalcFormula = Lookup("Purchase Header"."Buy-from Vendor Name" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No.")));
            Caption = 'Buy-from Vendor Name';
            Description = 'NC 51378 AB';
            FieldClass = FlowField;
            Editable = false;
        }
        field(70007; "Vendor Invoice No."; Code[35])
        {
            CalcFormula = Lookup("Purchase Header"."Vendor Invoice No." WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No.")));
            Caption = 'Vendor Invoice No.';
            Description = 'NC 51378 AB';
            FieldClass = FlowField;
            Editable = false;
        }
        field(70008; "Document Date"; Date)
        {
            CalcFormula = Lookup("Purchase Header"."Document Date" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No.")));
            Caption = 'Document Date';
            Description = 'NC 51378 AB';
            FieldClass = FlowField;
            Editable = false;
        }
        field(70009; "External Agreement No."; Text[30])
        {
            CalcFormula = Lookup("Purchase Header"."External Agreement No." WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No.")));
            Caption = 'External Agreement No.';
            Description = 'NC 51378 AB';
            FieldClass = FlowField;
            Editable = false;
        }
        field(70010; "Status App"; Option)
        {
            CalcFormula = Lookup("Purchase Header"."Status App" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No.")));
            Caption = 'Approval Status';
            Description = 'NC 51378 AB';
            FieldClass = FlowField;
            OptionCaption = ' ,Reception,Сontroller,Checker,Approve,Payment,Request';
            OptionMembers = " ",Reception,Сontroller,Checker,Approve,Payment,Request;
            Editable = false;
        }

        // NC AB:
        // field(70011; Paid; Boolean) - убрано, вместо него функции SetPaymentInvPaidStatus и GetPaymentInvPaidStatus из заголовка

        field(70012; "Due Date"; Date)
        {
            CalcFormula = Lookup("Purchase Header"."Due Date" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No.")));
            Caption = 'Due Date';
            Description = 'NC 51378 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70013; "Paid Date Fact"; Date)
        {
            Caption = 'Paid Date (Fact)';
            Description = 'NC 51378 AB';
            Editable = false;
        }
        field(70016; "Cost Type"; Code[20])
        {
            Caption = 'Cost Type';
            Description = '50085';

            trigger OnValidate()
            var
                GLS: Record "General Ledger Setup";
                DimensionValue: Record "Dimension Value";
                DimensionManagement: Codeunit "Dimension Management (Ext)";
            begin
                if "Line No." <> 0 then begin
                    GLS.Get;
                    // NC AB >>
                    // DimensionManagement.valDimValue(GLS."Cost Type Dimension Code", "Cost Type", "Dimension Set ID");
                    GLS.TestField("Cost Type Dimension Code");
                    DimensionManagement.valDimValueWithUpdGlobalDim(GLS."Cost Type Dimension Code", "Cost Type", "Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                    // NC AB <<
                end;
            end;

            trigger OnLookup()
            var
                GLS: Record "General Ledger Setup";
                DimensionValue: Record "Dimension Value";
                DimensionManagement: Codeunit "Dimension Management (Ext)";
            begin
                GLS.Get;
                // NC AB >>
                GLS.TestField("Cost Type Dimension Code");
                // NC AB <<
                DimensionValue.SetRange("Dimension Code", GLS."Cost Type Dimension Code");
                if DimensionValue.FindFirst() then begin
                    if DimensionValue.Get(GLS."Cost Type Dimension Code", "Cost Type") then;
                    if Page.RUNMODAL(Page::"Dimension Value List", DimensionValue) = Action::LookupOK then begin
                        "Cost Type" := DimensionValue.Code;
                        // NC AB >>
                        // DimensionManagement.valDimValue(GLS."Cost Type Dimension Code", "Cost Type", "Dimension Set ID");
                        DimensionManagement.valDimValueWithUpdGlobalDim(GLS."Cost Type Dimension Code", "Cost Type", "Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                        // NC AB <<
                    end;
                end;
            end;
        }
        field(70017; "Process User"; Code[20])
        {
            Caption = 'Process User';
            Description = 'NC 51378 AB';
            TableRelation = "User Setup";
        }
        field(70018; "Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
            Description = 'NC 51378 AB';
            TableRelation = "Salesperson/Purchaser";
        }
    }
    var
        PurchSetup: Record "Purchases & Payables Setup";

    procedure CheckProductionPrjDataModify(xDimSetID: integer);
    var
        DimValue: record "Dimension Value";
        PurchSetup: Record "Purchases & Payables Setup";
        DimSetEntry: Record "Dimension Set Entry";
    begin
        IF "Forecast Entry" = 0 THEN
            EXIT;
        IF xDimSetID = 0 then
            exit;
        PurchSetup.GET;
        PurchSetup.TESTFIELD("Cost Code Dimension");
        if not DimSetEntry.Get(xDimSetID, PurchSetup."Cost Code Dimension") then
            exit;
        DimValue.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code");
        IF (DimValue."Cost Code Type" <> DimValue."Cost Code Type"::Production) or (not DimValue."Check CF Forecast") then
            exit;
        TESTFIELD("Forecast Entry", 0);
    end;

    procedure ValidateUtilitiesDimValueCode(var UtilitiesDimCode: code[20])
    var
        GLSetup: Record "General Ledger Setup";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
        LocText003: Label '%1 is not an available %2 for that dimension.';
    begin
        GLSetup.Get();
        GLSetup.TestField("Utilities Dimension Code");

        DimVal.SetRange("Dimension Code", GLSetup."Utilities Dimension Code");
        if UtilitiesDimCode <> '' then begin
            DimVal.SetRange(Code, UtilitiesDimCode);
            if not DimVal.FindFirst then begin
                DimVal.SetFilter(Code, StrSubstNo('%1*', UtilitiesDimCode));
                if DimVal.FindFirst then
                    UtilitiesDimCode := DimVal.Code
                else
                    Error(
                      LocText003,
                      UtilitiesDimCode, DimVal.FieldCaption(Code));
            end;
            DimVal.Get(GLSetup."Utilities Dimension Code", UtilitiesDimCode);
            if not DimMgt.CheckDim(DimVal."Dimension Code") then
                Error(DimMgt.GetDimErr);
            if not DimMgt.CheckDimValue(DimVal."Dimension Code", UtilitiesDimCode) then
                Error(DimMgt.GetDimErr);
        end;
        DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", DimVal."Dimension Code") then
            if TempDimSetEntry."Dimension Value Code" <> UtilitiesDimCode then
                TempDimSetEntry.Delete();
        if UtilitiesDimCode <> '' then begin
            TempDimSetEntry."Dimension Code" := DimVal."Dimension Code";
            TempDimSetEntry."Dimension Value Code" := DimVal.Code;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            if TempDimSetEntry.Insert() then;
        end;
        Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
    end;

}