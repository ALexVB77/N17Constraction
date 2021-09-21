// Миграция данных
codeunit 70049 ImportManagement
{
    //Permissions = TableData "VAT Entry" = imd;

    trigger OnRun()
    begin

    end;

    var
        Window: Dialog;
        ProgressText: label '<Table ID: #1##########   SQL Dim Set ID: #2##########\>';


    local procedure AddTempDimSetEntry(DimCode: Code[20]; DimValueCode: Code[20]; TempDimSetEntry: Record "Dimension Set Entry" temporary)
    var
        Dimension: Record Dimension;
        DimValue: Record "Dimension Value";
        DimMapping: Record "Dimension Mapping";
    begin
        IF (DimCode = '') OR (DimValueCode = '') THEN
            exit;

        Dimension.GET(DimCode);
        if DimCode in ['CC', 'CP'] then begin
            DimMapping.SetRange("Dimension Code", DimCode);
            DimMapping.SetRange("Old Dimension Value Code", DimValueCode);
            if DimMapping.FindFirst() then begin
                DimValueCode := DimMapping."New Dimension Value Code";
                DimValue.Get(DimCode, DimValueCode);
            end else begin
                DimValue.Init;
                DimValue."Dimension Code" := DimCode;
                DimValue.Code := DimValueCode;
                DimValue.Unmapped := true;
                DimValue.Insert;
            end;
        end else
            DimValue.GET(DimCode, DimValueCode);

        TempDimSetEntry.INIT;
        TempDimSetEntry."Dimension Code" := DimCode;
        TempDimSetEntry."Dimension Value Code" := DimValueCode;
        TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
        TempDimSetEntry.INSERT(TRUE);
    end;

    procedure ImportDocumentDimension()
    var
        ImportDim: Record ImportDimPivot;
        ImportDimDoc: Record ImportDimDocPivot;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        ImportQuery: Query ImportDocumentDimension;
        DimMgt: Codeunit DimensionManagement;
        CurrTable, DimensionSetID : Integer;
    begin
        SELECTLATESTVERSION;

        Window.Open(ProgressText);

        ImportQuery.Open();
        while ImportQuery.Read() do begin
            if CurrTable <> ImportQuery.TableID THEN BEGIN
                CurrTable := ImportQuery.TableID;
                ImportDim.Get(CurrTable);
                Window.UPDATE(1, CurrTable);
            END;

            Window.UPDATE(2, ImportQuery.SQLDimSetID);

            ImportDimDoc.RESET;
            ImportDimDoc.SETCURRENTKEY(SQLDimSetID);
            ImportDimDoc.SETRANGE(SQLDimSetID, ImportQuery.SQLDimSetID);
            ImportDimDoc.SETRANGE(TableID, ImportQuery.TableID);
            ImportDimDoc.FINDFIRST;

            TempDimSetEntry.RESET;
            TempDimSetEntry.DELETEALL;

            AddTempDimSetEntry(ImportDim.Dim1Code, ImportDimDoc.Dim1ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim2Code, ImportDimDoc.Dim2ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim3Code, ImportDimDoc.Dim3ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim4Code, ImportDimDoc.Dim4ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim5Code, ImportDimDoc.Dim5ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim6Code, ImportDimDoc.Dim6ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim7Code, ImportDimDoc.Dim7ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim8Code, ImportDimDoc.Dim8ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim9Code, ImportDimDoc.Dim9ValueCode, TempDimSetEntry);
            AddTempDimSetEntry(ImportDim.Dim10Code, ImportDimDoc.Dim10ValueCode, TempDimSetEntry);

            DimensionSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
            ImportDimDoc.MODIFYALL(NAVDimSetID, DimensionSetID);
        end;
        ImportQuery.Close();

        Window.Close();
    end;


}