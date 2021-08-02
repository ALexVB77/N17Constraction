report 70200 "Import Vendor Invoice"
{
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Import Vendor Invoice';
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(FileName; FileName)
                    {
                        ApplicationArea = All;
                        Caption = 'File Name';

                        trigger OnAssistEdit()
                        begin
                            ServerFileName := FileManagement.UploadFile(Text031, FileName);
                            FileName := FileManagement.GetFileName(ServerFileName);
                            SheetName := '';
                        end;
                    }
                    field(GVendNo; GVendNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor No.';
                        TableRelation = Vendor;

                        trigger OnValidate()
                        begin
                            LoadParams(GVendNo);
                        end;
                    }
                    field(DocNoCell; DocNoCell)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No. Cell';
                    }
                    field(DocDateCell; DocDateCell)
                    {
                        ApplicationArea = All;
                        Caption = 'Document Date Cell';
                    }
                    field(VATRegCell; VATRegCell)
                    {
                        ApplicationArea = All;
                        Caption = 'VAT Registration No. Cell';
                    }
                    field(RowStart; RowStart)
                    {
                        ApplicationArea = All;
                        Caption = 'Table Start Row';
                    }
                    field(ItemVendNoCol; ItemVendNoCol)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Item No Column';
                    }
                    field(ItemDescCol; ItemDescCol)
                    {
                        ApplicationArea = All;
                        Caption = 'Item Description Column';
                    }
                    field(ItemQtyCol; ItemQtyCol)
                    {
                        ApplicationArea = All;
                        Caption = 'Quantity Column';
                    }
                    field(ItemUoMCol; ItemUoMCol)
                    {
                        ApplicationArea = All;
                        Caption = 'Unit of Measure Column';
                    }
                    field(VATPerCol; VATPerCol)
                    {
                        ApplicationArea = All;
                        Caption = 'VAT Percent Column';
                    }
                    field(PriceCol; PriceCol)
                    {
                        ApplicationArea = All;
                        Caption = 'Price Column';
                    }
                    field(AmountCol; AmountCol)
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Column';
                    }
                    field(TaxCol; TaxCol)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax Amount Column';
                    }
                }
            }
        }
        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            FileMgt: Codeunit "File Management";
        begin
            SaveParams(GVendNo);
            if CloseAction = ACTION::OK then begin
                SheetName := ExcelBuf.SelectSheetsName(ServerFileName);
                if SheetName = '' then
                    exit(false);
            end;
        end;
    }

    trigger OnPreReport()
    begin

        IF FileName = '' THEN
            ERROR(Err_fname);
        if SheetName = '' then
            error(Err_sname);

        if not (ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            error(ClientTypeErr);

        // NC AB: move to OnCloseParamPage
        // SaveParams(GVendNo);

        ExcelBuf.RESET;
        ExcelBuf.DELETEALL;

        ExcelBuf.OpenBook(ServerFileName, SheetName);
        ExcelBuf.ReadSheet;

        VendHead.INIT;
        ExcelBuf.RESET;
        ExcelBuf.SETRANGE(xlRowID, LocMgt.DigitalPartCode(DocNoCell));
        ExcelBuf.SETRANGE(xlColID, COPYSTR(DocNoCell, 1, STRPOS(DocNoCell, LocMgt.DigitalPartCode(DocNoCell)) - 1));
        IF NOT ExcelBuf.FINDFIRST THEN
            ERROR(Err_noData, DocNoCell);
        VendHead."No." := ExcelBuf."Cell Value as Text";
        ExcelBuf.SETRANGE(xlRowID, LocMgt.DigitalPartCode(DocDateCell));
        ExcelBuf.SETRANGE(xlColID, COPYSTR(DocDateCell, 1, STRPOS(DocDateCell, LocMgt.DigitalPartCode(DocDateCell)) - 1));
        IF NOT ExcelBuf.FINDFIRST THEN;
        //  error(Err_noData,DocDateCell);
        VendHead.Date := ExcelBuf."Cell Value as Text";

        IF VATRegCell <> '' THEN BEGIN
            ExcelBuf.SETRANGE(xlRowID, LocMgt.DigitalPartCode(VATRegCell));
            ExcelBuf.SETRANGE(xlColID, COPYSTR(VATRegCell, 1, STRPOS(VATRegCell, LocMgt.DigitalPartCode(VATRegCell)) - 1));
            IF NOT ExcelBuf.FINDFIRST THEN
                ERROR(Err_noData, VATRegCell);
            IF STRPOS(ExcelBuf."Cell Value as Text", '/') <> 0 THEN
                ExcelBuf."Cell Value as Text" := COPYSTR(ExcelBuf."Cell Value as Text", 1, STRPOS(ExcelBuf."Cell Value as Text", '/') - 1);
            VendHead."Vend VAT Reg No." := ExcelBuf."Cell Value as Text";
        END;
        Vendor.RESET;
        Vendor.SETRANGE("VAT Registration No.", VendHead."Vend VAT Reg No.");
        IF Vendor.FINDFIRST THEN
            VendHead."Vendor No." := Vendor."No.";
        IF VendHead."Vend VAT Reg No." = '' THEN
            VendHead."Vendor No." := GVendNo;
        IF VendHeadCheck.GET(VendHead."No.", VendHead."Vendor No.") THEN BEGIN
            IF VendHeadCheck."Act No." <> '' THEN
                ERROR(Err_ActCreated, VendHead."No.", VendHeadCheck."Act No.");
            IF CONFIRM(STRSUBSTNO(Text002, VendHead."No.", VendHead."Vendor No."), FALSE) THEN BEGIN
                VendHeadCheck.DELETE(TRUE);
            END;
        END;

        VendHead.INSERT;

        ExcelBuf.RESET;
        IF ExcelBuf.FINDLAST THEN
            MaxRow := ExcelBuf."Row No.";
        FOR i := RowStart TO MaxRow DO BEGIN
            _VendItemNo := '';
            _VendItemDesc := '';
            _ItemQty := 0;
            _ItemUoM := '';
            _VATPer := '';
            _Amount := 0;
            _Tax := 0;
            _Price := 0;
            ExcelBuf.SETRANGE("Row No.", i);
            ExcelBuf.SETRANGE(xlColID, ItemVendNoCol);
            IF ExcelBuf.FINDFIRST THEN
                _VendItemNo := COPYSTR(ExcelBuf."Cell Value as Text", 1, MAXSTRLEN(_VendItemNo));

            ExcelBuf.SETRANGE(xlColID, ItemDescCol);
            IF ExcelBuf.FINDFIRST THEN
                _VendItemDesc := ExcelBuf."Cell Value as Text";

            ExcelBuf.SETRANGE(xlColID, ItemQtyCol);
            IF ExcelBuf.FINDFIRST THEN
                IF EVALUATE(_ItemQty, ExcelBuf."Cell Value as Text") THEN;

            ExcelBuf.SETRANGE(xlColID, ItemUoMCol);
            IF ExcelBuf.FINDFIRST THEN
                _ItemUoM := ExcelBuf."Cell Value as Text";

            ExcelBuf.SETRANGE(xlColID, VATPerCol);
            IF ExcelBuf.FINDFIRST THEN
                _VATPer := ExcelBuf."Cell Value as Text";

            ExcelBuf.SETRANGE(xlColID, AmountCol);
            IF ExcelBuf.FINDFIRST THEN
                IF EVALUATE(_Amount, ExcelBuf."Cell Value as Text") THEN;

            ExcelBuf.SETRANGE(xlColID, TaxCol);
            IF ExcelBuf.FINDFIRST THEN
                IF EVALUATE(_Tax, ExcelBuf."Cell Value as Text") THEN;

            ExcelBuf.SETRANGE(xlColID, PriceCol);
            IF ExcelBuf.FINDFIRST THEN
                IF EVALUATE(_Price, ExcelBuf."Cell Value as Text") THEN;

            IF (_VendItemNo <> '') AND (_ItemQty <> 0) AND (_Price <> 0) THEN BEGIN
                VendLine.INIT;
                VendLine."Document No." := VendHead."No.";
                VendLine."Vendor No." := VendHead."Vendor No.";
                VendLine."Line No." := (i - RowStart + 1) * 10000;
                VendLine.Description := _VendItemDesc;
                VendLine."Item No." := '';
                Item.RESET;
                Item.SETRANGE("Vendor Item No.", _VendItemNo);
                Item.SETRANGE("Vendor No.", VendHead."Vendor No.");
                IF Item.FINDFIRST THEN
                    VendLine."Item No." := Item."No.";
                VendLine.Quantity := _ItemQty;
                VendLine."Unit of Measure" := _ItemUoM;
                VendLine."Unit Price" := _Price;
                VendLine."VAT %" := _VATPer;
                VendLine.Amount := _Amount;
                VendLine."Amount inc. VAT" := 0;
                VendLine."Vendor Item No." := _VendItemNo;
                IF VendLine."Item No." = '' THEN
                    VendLine."Item Action" := VendLine."Item Action"::CreateItem;
                VendLine.INSERT;
            END;

        END;
        MESSAGE(Text001, VendHead."No.");
    end;

    var
        VendMap: Record "Vendor Excel Mapping";
        VendHead, VendHeadCheck : Record "Vendor Excel Header";
        VendLine: Record "Vendor Excel Line";
        Item: Record Item;
        Vendor: Record Vendor;
        ExcelBuf: Record "Excel Buffer" temporary;
        LocMgt: Codeunit "Localisation Management";
        FileManagement: Codeunit "File Management";
        ClientTypeMgt: Codeunit "Client Type Management";

        RowStart: Integer;
        GVendNo: code[20];
        VATRegCell, DocNoCell, DocDateCell : code[20];
        ItemDescCol, ItemQtyCol, ItemUoMCol, VATPerCol, AmountCol, TaxCol, PriceCol, ItemVendNoCol : code[20];
        FileName, SheetName, ServerFileName : text;
        RowNo, MaxRow : integer;
        i: Integer;
        _VendItemNo: text[20];
        _VendItemDesc: Text[250];
        _ItemQty: Integer;
        _ItemUoM, _VATPer : text[50];
        _Amount, _Tax, _Price : decimal;
        Err_fname: Label 'Please select a file to download!';
        Err_sname: label 'The Excel sheet must be specified!';
        Err_noData: Label 'Cell %1 has no data!';
        Err_ActCreated: Label 'Act %2 has already been created for document %1.';
        Text001: Label 'Loaded document %1.';
        Text002: Label 'Document %1 for %2 already exists! Recreate?';
        Text031: Label 'Import from File';
        ClientTypeErr: Label 'Unknown client type!';

    local procedure SaveParams(VendNo: Code[20])
    begin
        IF NOT VendMap.GET(VendNo) THEN BEGIN
            VendMap.INIT;
            VendMap."Vendor No." := VendNo;
            VendMap.INSERT;
        END;
        VendMap.RowStart := FORMAT(RowStart);
        VendMap."VAT Reg Cell" := VATRegCell;
        VendMap."Document No Cell" := DocNoCell;
        VendMap."Document Date Cell" := DocDateCell;
        VendMap."ItemDescription Cell" := ItemDescCol;
        VendMap."ItemQuantity Cell" := ItemQtyCol;
        VendMap."ItemUoM Cell" := ItemUoMCol;
        VendMap."VAT Percent Cell" := VATPerCol;
        VendMap."Amount Cell" := AmountCol;
        VendMap."Tax Cell" := TaxCol;
        VendMap."Price Cell" := PriceCol;
        VendMap."ItemVendNo Cell" := ItemVendNoCol;
        VendMap.MODIFY;
        COMMIT;
    end;

    local procedure LoadParams(VendNo: Code[20])
    begin
        InitParams;
        IF VendMap.GET(VendNo) THEN BEGIN
            IF EVALUATE(RowStart, VendMap.RowStart) THEN;
            VATRegCell := VendMap."VAT Reg Cell";
            DocNoCell := VendMap."Document No Cell";
            DocDateCell := VendMap."Document Date Cell";
            ItemDescCol := VendMap."ItemDescription Cell";
            ItemQtyCol := VendMap."ItemQuantity Cell";
            ItemUoMCol := VendMap."ItemUoM Cell";
            VATPerCol := VendMap."VAT Percent Cell";
            AmountCol := VendMap."Amount Cell";
            TaxCol := VendMap."Tax Cell";
            PriceCol := VendMap."Price Cell";
            ItemVendNoCol := VendMap."ItemVendNo Cell";
        END;
    end;

    local procedure InitParams()
    begin
        RowStart := 0;
        VATRegCell := '';
        DocNoCell := '';
        DocDateCell := '';
        ItemDescCol := '';
        ItemQtyCol := '';
        ItemUoMCol := '';
        VATPerCol := '';
        AmountCol := '';
        TaxCol := '';
        PriceCol := '';
        ItemVendNoCol := '';
    end;

}