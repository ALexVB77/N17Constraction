codeunit 70004 "Dimension Management (Ext)"
{
    procedure valDimValue(DimCode: Code[20]; DimValCode: Code[20]; var DimSetID: Integer)
    var
        DimensionManagement: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";
    begin
        // NC AB: проверка из CU408.ValidateShortcutDimValues
        if DimValCode <> '' then begin
            DimVal.Get(DimCode, DimValCode);
            if not DimensionManagement.CheckDim(DimVal."Dimension Code") then
                Error(DimensionManagement.GetDimErr);
            if not DimensionManagement.CheckDimValue(DimVal."Dimension Code", DimValCode) then
                Error(DimensionManagement.GetDimErr);
        end;

        DimensionManagement.GetDimensionSet(TempDimSetEntry, DimSetID);
        IF TempDimSetEntry.GET(TempDimSetEntry."Dimension Set ID", DimCode) THEN
            IF TempDimSetEntry."Dimension Value Code" <> DimValCode THEN
                TempDimSetEntry.DELETE;
        IF DimValCode <> '' THEN BEGIN
            TempDimSetEntry."Dimension Code" := DimCode;
            TempDimSetEntry."Dimension Value Code" := DimValCode;
            IF TempDimSetEntry.INSERT(TRUE) THEN;
        END;
        DimSetID := DimensionManagement.GetDimensionSetID(TempDimSetEntry);
    end;

    procedure valDimValueWithUpdGlobalDim(DimCode: Code[20]; DimValCode: Code[20]; var DimSetID: Integer; var GlobalDim1Code: code[20]; var GlobalDim2Code: code[20]): Boolean
    var
        DimensionManagement: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
        OldGlobalDim1Code: code[20];
        OldGlobalDim2Code: code[20];
    begin
        // NC AB: проверка из CU408.ValidateShortcutDimValues
        if DimValCode <> '' then begin
            DimVal.Get(DimCode, DimValCode);
            if not DimensionManagement.CheckDim(DimVal."Dimension Code") then
                Error(DimensionManagement.GetDimErr);
            if not DimensionManagement.CheckDimValue(DimVal."Dimension Code", DimValCode) then
                Error(DimensionManagement.GetDimErr);
        end;

        GLSetup.Get();
        OldGlobalDim1Code := GlobalDim1Code;
        OldGlobalDim2Code := GlobalDim2Code;

        DimensionManagement.GetDimensionSet(TempDimSetEntry, DimSetID);
        IF TempDimSetEntry.GET(TempDimSetEntry."Dimension Set ID", DimCode) THEN
            IF TempDimSetEntry."Dimension Value Code" <> DimValCode THEN BEGIN
                TempDimSetEntry.DELETE;
                if (GLSetup."Global Dimension 1 Code" <> '') and (GLSetup."Global Dimension 1 Code" = DimCode) then
                    GlobalDim1Code := '';
                if (GLSetup."Global Dimension 2 Code" <> '') and (GLSetup."Global Dimension 2 Code" = DimCode) then
                    GlobalDim2Code := '';
            END;
        IF DimValCode <> '' THEN BEGIN
            TempDimSetEntry."Dimension Code" := DimCode;
            TempDimSetEntry."Dimension Value Code" := DimValCode;
            IF TempDimSetEntry.INSERT(TRUE) THEN;
            if (GLSetup."Global Dimension 1 Code" <> '') and (GLSetup."Global Dimension 1 Code" = DimCode) then
                GlobalDim1Code := DimValCode;
            if (GLSetup."Global Dimension 2 Code" <> '') and (GLSetup."Global Dimension 2 Code" = DimCode) then
                GlobalDim2Code := DimValCode;
        END;
        DimSetID := DimensionManagement.GetDimensionSetID(TempDimSetEntry);

        exit((OldGlobalDim1Code <> GlobalDim1Code) or (OldGlobalDim2Code <> GlobalDim2Code));
    end;
}