tableextension 85741 "Transfer Line (Ext)" extends "Transfer Line"
{
    fields
    {
        field(50000; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(50002; "New Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            trigger OnValidate()
            begin
                ValidateShortcutNewDimCode(1, "New Shortcut Dimension 1 Code");
            end;
        }
        field(50003; "New Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            trigger OnValidate()
            begin
                ValidateShortcutNewDimCode(2, "New Shortcut Dimension 2 Code");
            end;
        }
        field(50481; "New Dimension Set Id"; Integer)
        {
            Caption = 'New Dimension Set Id';
            TableRelation = "Dimension Set Entry";
            Editable = false;
        }
    }
    var
        ILENo: integer;

    local procedure VerifyItemLineDim()
    begin
        if IsShippedNewDimChanged then
            ConfirmShippedDimChange;
    end;

    procedure IsShippedNewDimChanged() Result: Boolean
    begin
        Result := ("New Dimension Set ID" <> xRec."New Dimension Set ID") and (("Quantity Shipped" <> 0) or ("Qty. Shipped (Base)" <> 0));
    end;

    procedure ValidateShortcutNewDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        dimMgt: codeunit DimensionManagement;
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "New Dimension Set ID");
        VerifyItemLineDim;
    end;

    procedure SetILE(pILENo: integer)
    begin

        //NC 22512 > DP
        ILENo := pILENo;
        //NC 22512 < DP
    end;
}
