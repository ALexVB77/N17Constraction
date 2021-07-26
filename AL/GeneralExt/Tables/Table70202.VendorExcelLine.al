table 70202 "Vendor Excel Line"
{
    Caption = 'Vendor Excel Line';

    fields
    {
        field(1; "Document No."; Code[50])
        {
            Caption = 'Document No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(4; "Item No."; Code[20])
        {
            TableRelation = Item;
            Caption = 'Item No.';
        }
        field(5; Quantity; Decimal)
        {
            Caption = 'Quatity';
        }
        field(6; "Unit of Measure"; Code[20])
        {
            TableRelation = "Unit of Measure";
            Caption = 'Unit of Measure';
        }
        field(7; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(8; "VAT %"; Text[20])
        {
            Caption = 'VAT %';
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(10; "Amount inc. VAT"; Decimal)
        {
            Caption = 'Amount inc. VAT';
        }
        field(11; "Vendor Item No."; Text[20])
        {
            Caption = 'Vendor Item No.';
        }
        field(12; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(42; "Item Action"; Option)
        {
            Caption = 'Item Action';
            OptionMembers = Skip,CreateItem;
            OptionCaption = 'Skip,CreateItem';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Vendor No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;
        Text001: Label 'Create unit of measure %1 or choose from the list of existing ones!';

    procedure CreateItem()
    var
        Item: record Item;
        IUoM: record "Item Unit of Measure";
        VEHead: record "Vendor Excel Header";
    begin
        CheckUoM;
        Item.RESET;
        Item.SETRANGE("Vendor Item No.", "Vendor Item No.");
        Item.SETRANGE("Vendor No.", "Vendor No.");
        IF Item.FINDFIRST THEN BEGIN
            "Item No." := Item."No.";
            MODIFY;
            EXIT;
        END;
        Item.RESET;
        Item.INIT;
        Item."No." := '';
        Item.INSERT(TRUE);
        Item."Vendor Item No." := "Vendor Item No.";
        Item."Vendor No." := "Vendor No.";
        IUoM.INIT;
        IUoM."Item No." := Item."No.";
        IUoM.Code := "Unit of Measure";
        IUoM."Qty. per Unit of Measure" := 1;
        IUoM.INSERT;
        Item."Base Unit of Measure" := IUoM.Code;
        Item."Purch. Unit of Measure" := IUoM.Code;
        Item.Description := COPYSTR(Description, 1, MAXSTRLEN(Item.Description));
        Item."Description 2" := COPYSTR(Description, MAXSTRLEN(Item.Description) + 1,
                                        MAXSTRLEN(Item."Description 2"));
        //Item."Branch Code" := '0001.';
        Item.MODIFY(TRUE);
        "Item No." := Item."No.";
        "Item Action" := "Item Action"::Skip;
        MODIFY;
    end;

    procedure CheckUoM()
    var
        UoM: record "Unit of Measure";
    begin
        IF NOT UoM.GET("Unit of Measure") THEN
            ERROR(Text001, "Unit of Measure");
    end;

    procedure ShowDimensions() IsChanged: Boolean
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', "Document No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        IsChanged := OldDimSetID <> "Dimension Set ID";
    end;

}


