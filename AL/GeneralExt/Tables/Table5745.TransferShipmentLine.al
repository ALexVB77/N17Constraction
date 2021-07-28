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