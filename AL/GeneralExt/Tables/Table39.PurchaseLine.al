tableextension 80039 "Purchase Line (Ext)" extends "Purchase Line"
{
    fields
    {
        field(70003; "Forecast Entry"; Integer)
        {
            Caption = 'Forecast Entry';
            Description = '50086';
        }
    }

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
}