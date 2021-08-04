tableextension 85745 "Transfer Shipment Line (Ext)" extends "Transfer Shipment Line"
{
    fields
    {
        field(50000; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            Description = 'SWC1066 DP 27.06.17';
            TableRelation = "Gen. Business Posting Group";
        }
        field(50002; "New Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1,New ';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            Description = 'NCC002 ROMB, NC 51410 EP';
        }
        field(50003; "New Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2,New ';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            Description = 'NCC002 ROMB, NC 51410 EP';
        }
    }

    // NC 51410 > EP
    // Перетянуто из table "Transfer Line"
    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;
    // NC 51410 < EP
}