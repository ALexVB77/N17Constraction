codeunit 99900 "Scanning Helper"
{
    var

        g_DocumentNo: Code[250];
        g_EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        Proceed: Boolean;
        ScanningPage: Page Scanning;
        EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        Barcodes: Record "Item Identifier";
        ScanEntry: Record "Item Scanning Entry";
        SelectItemPage: Page "ItemList1";
        SelectItemPage1: Page ItemList1;
        SelectItemPage2: Page ItemList1;
        SelectedItemNo: Code[20];
        CurrBarcode: Code[15];
        g_LineNo: Integer;
        g_ManualQuantity: Decimal;
        g_PurchLine: Record "Purchase Line";
        SelectedUOM: Code[10];
        UOMManagement: Codeunit "Unit of Measure Management";
        LastOpFilter: Text;
        HaveSplit: Boolean;
        InsertedQty: Decimal;
        FirstScanEntry: Label 'For edit quantity please scan item or insert operation without scanning';
        NoneChItem: Label 'Item Not Choosen';

    procedure SetParam("Document No.": Code[250]; "Entry Type": Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory);
    begin
        g_DocumentNo := "Document No.";
        g_EntryType := "Entry Type";
    end;


    procedure CreateBarcode(Barcode: Code[15]; ItemNo: Code[20])
    var
        l_Barcodes: Record "Item Identifier";
        CreateBarcode: Label 'Barcode not registered. Create barcode';
    begin
        IF DIALOG.CONFIRM(CreateBarcode, TRUE) THEN BEGIN
            IF SelectItem THEN BEGIN
                SelectUOM;
                l_Barcodes.INIT;
                l_Barcodes.Code := CurrBarcode;
                l_Barcodes."Item No." := SelectedItemNo;
                l_Barcodes."Unit of Measure Code" := SelectedUOM;
                IF l_Barcodes.INSERT THEN BEGIN
                    SearchBarcode(CurrBarcode);
                    CreateScanningEntry(TRUE);
                END;
            END ELSE
                ERROR(NoneChItem);
        END;
    end;


    procedure SearchBarcode(BCode: Code[15]): Boolean
    begin
        CurrBarcode := BCode;
        Barcodes.RESET;
        Barcodes.SETRANGE(Code, BCode);
        EXIT(Barcodes.FINDFIRST);
    end;

    procedure CreateScanningEntry(RealScanning: Boolean)
    var
        EntryNo: Integer;
        UOMManager: Codeunit "Unit of Measure Management";
        l_Item: Record Item;
        ManualQty: Integer;
        EnterQty: Page EnterQty;
        l_Qty: Decimal;
    begin

        ScanEntry.RESET;
        IF ScanEntry.FINDLAST THEN
            EntryNo := ScanEntry."Entry No." + 1
        ELSE
            EntryNo := 1;
        //ScanEntry.INIT;
        IF RealScanning THEN BEGIN
            SelectedItemNo := Barcodes."Item No.";
            l_Item.GET(Barcodes."Item No.");
            l_Item.GET(Barcodes."Item No.");
            InitEntry(EntryNo, g_EntryType, g_DocumentNo, 0, Barcodes.Code, l_Item."No.", l_Item."Base Unit of Measure", UOMManager.GetQtyPerUnitOfMeasure(l_Item, Barcodes."Unit of Measure Code"), RealScanning,
            UOMManager.GetQtyPerUnitOfMeasure(l_Item, Barcodes."Unit of Measure Code"), FALSE, 0);
        END ELSE BEGIN
            l_Item.GET(SelectedItemNo);
            l_Qty := InsertedQty * UOMManager.GetQtyPerUnitOfMeasure(l_Item, SelectedUOM);
            InitEntry(EntryNo, g_EntryType, g_DocumentNo, 0, Barcodes.Code, l_Item."No.", l_Item."Base Unit of Measure", l_Qty, FALSE,
            l_Qty * UOMManager.GetQtyPerUnitOfMeasure(l_Item, Barcodes."Unit of Measure Code"), TRUE, 0);
        END;
        //ScanEntry.INSERT;
        DistributionByDocs(ScanEntry);
    end;

    procedure SelectItem(): Boolean
    var
        PurchLines: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        WriteOffLine: Record "Item Document Line";
    begin

        //For Purchase Order
        IF g_EntryType = g_EntryType::Posting THEN BEGIN
            SelectItemPage.LOOKUPMODE(TRUE);
            PurchLines.SETFILTER("Document No.", g_DocumentNo);
            SelectItemPage.SETTABLEVIEW(PurchLines);
            IF SelectItemPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
                SelectItemPage.GETRECORD(PurchLines);
                SelectedItemNo := PurchLines."No.";
                CLEAR(SelectItemPage);
                EXIT(TRUE);
            END ELSE BEGIN
                CLEAR(SelectItemPage);
                EXIT(FALSE);
            END;
        END;
        //For Transfer Order
        IF g_EntryType = g_EntryType::TransOrder THEN BEGIN
            SelectItemPage1.LOOKUPMODE(TRUE);
            TransferLine.SETFILTER("Document No.", g_DocumentNo);
            SelectItemPage1.SETTABLEVIEW(TransferLine);
            IF SelectItemPage1.RUNMODAL = ACTION::LookupOK THEN BEGIN
                SelectItemPage1.GETRECORD(TransferLine);
                SelectedItemNo := TransferLine."Item No.";
                CLEAR(SelectItemPage1);
                EXIT(TRUE);
            END ELSE BEGIN
                CLEAR(SelectItemPage1);
                EXIT(FALSE);
            END;
        END;
        //FosSr Write-off
        IF g_EntryType = g_EntryType::"Write-off" THEN BEGIN
            SelectItemPage2.LOOKUPMODE(TRUE);
            WriteOffLine.SETFILTER("Document No.", g_DocumentNo);
            SelectItemPage2.SETTABLEVIEW(WriteOffLine);
            IF SelectItemPage2.RUNMODAL = ACTION::LookupOK THEN BEGIN
                SelectItemPage2.GETRECORD(WriteOffLine);
                SelectedItemNo := WriteOffLine."Item No.";
                CLEAR(SelectItemPage2);
                EXIT(TRUE);
            END ELSE BEGIN
                CLEAR(SelectItemPage2);
                EXIT(FALSE);
            END;
        END;
    end;

    procedure SetItemNo(ItemNo: Code[20])
    begin
        SelectedItemNo := ItemNo;
    end;

    procedure InsertQuantity(l_ItemNo: Code[20]; l_UOM: Code[10]; l_Qty: Decimal; l_DocNo: Code[250]; l_EntryType: Option ,Posting,"Write-off",Inventory; l_OpFilter: Text)
    var
        l_EntryNo: Integer;
        l_Item: Record Item;
        UOMManager: Codeunit "Unit of Measure Management";
    begin

        DeletePrevOps(l_OpFilter);
        LastOpFilter := '';
        ScanEntry.RESET;
        IF ScanEntry.FINDLAST THEN
            l_EntryNo := ScanEntry."Entry No." + 1
        ELSE
            l_EntryNo := 1;
        ScanEntry.INIT;
        ScanEntry."Entry No." := l_EntryNo;
        ScanEntry."Document No." := l_DocNo;
        ScanEntry."Entry Type" := l_EntryType;
        ScanEntry."Item No." := l_ItemNo;
        SelectedItemNo := l_ItemNo;
        l_Item.GET(l_ItemNo);
        ScanEntry."Unit of Measure" := l_Item."Base Unit of Measure";
        ScanEntry.Quantity := l_Qty * UOMManager.GetQtyPerUnitOfMeasure(l_Item, l_UOM);
        ScanEntry."Quantity(Base)" := l_Qty * UOMManager.GetQtyPerUnitOfMeasure(l_Item, l_UOM);
        ScanEntry.UserID := USERID;
        ScanEntry.ManualInsQty := TRUE;
        ScanEntry.INSERT;
        DistributionByDocs(ScanEntry);
    end;


    procedure SelectUOM(): Boolean
    var
        SelectUOMPage: Page UOMList;
        SelectUOMTable: Record "Item Unit of Measure";
    begin
        SelectUOMPage.LOOKUPMODE(TRUE);
        SelectUOMTable.SETFILTER("Item No.", SelectedItemNo);
        SelectUOMPage.SETTABLEVIEW(SelectUOMTable);
        IF SelectUOMPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
            SelectUOMPage.GETRECORD(SelectUOMTable);
            SelectedUOM := SelectUOMTable.Code;
            CLEAR(SelectUOMPage);
            EXIT(TRUE);
        END ELSE BEGIN
            CLEAR(SelectUOMPage);
            EXIT(FALSE);
        END;
    end;


    procedure PrepareScanningBuffer(DocFilter: Code[250]; p_EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory)
    var
        ScanBuffer: Record "Scanning Buffer";
        l_PurchaseLine: Record "Purchase Line";
        l_Item: Record Item;
        UOMManager: Codeunit "Unit of Measure Management";
        l_ScanEntry: Record "Item Scanning Entry";
        l_TransferLine: Record "Transfer Line";
        l_WriteOffLine: Record "Item Document Line";
    begin

        //For Purchase Order
        IF p_EntryType = p_EntryType::Posting THEN BEGIN
            l_PurchaseLine.RESET;
            l_PurchaseLine.SETFILTER("Document No.", DocFilter);
            IF l_PurchaseLine.FINDSET THEN
                REPEAT
                    ScanBuffer.INIT;
                    ScanBuffer.DocumentNo := l_PurchaseLine."Document No.";
                    ScanBuffer.DocumentLineNo := l_PurchaseLine."Line No.";
                    ScanBuffer."Item No." := l_PurchaseLine."No.";
                    ScanBuffer.Qty := l_PurchaseLine.Quantity;
                    l_ScanEntry.RESET;
                    l_ScanEntry.SETRANGE("Document No.", l_PurchaseLine."Document No.");
                    l_ScanEntry.SETRANGE("Document Line No.", l_PurchaseLine."Line No.");
                    IF l_ScanEntry.FINDSET THEN BEGIN
                        l_ScanEntry.CALCSUMS(Quantity);
                        ScanBuffer.Qty := ScanBuffer.Qty - l_ScanEntry.Quantity;
                    END;
                    IF l_Item.GET(l_PurchaseLine."No.") THEN
                        ScanBuffer."Qty(Base)" := ScanBuffer.Qty * UOMManager.GetQtyPerUnitOfMeasure(l_Item, l_PurchaseLine."Unit of Measure Code");
                    ScanBuffer.Uom := l_PurchaseLine."Unit of Measure Code";
                    ScanBuffer."Uom(Base)" := l_Item."Base Unit of Measure";
                    ScanBuffer.DocumentType := p_EntryType;
                    IF NOT ScanBuffer.INSERT THEN
                        ScanBuffer.MODIFY;
                UNTIL l_PurchaseLine.NEXT = 0;
        END;
        //For transfer Oprorder;
        IF p_EntryType = p_EntryType::TransOrder THEN BEGIN
            l_TransferLine.RESET;
            l_TransferLine.SETFILTER("Document No.", DocFilter);
            IF l_TransferLine.FINDSET THEN
                REPEAT
                    ScanBuffer.INIT;
                    ScanBuffer.DocumentNo := l_TransferLine."Document No.";
                    ScanBuffer.DocumentLineNo := l_TransferLine."Line No.";
                    ScanBuffer."Item No." := l_TransferLine."Item No.";
                    ScanBuffer.Qty := l_TransferLine.Quantity;
                    l_ScanEntry.RESET;
                    l_ScanEntry.SETRANGE("Document No.", l_TransferLine."Document No.");
                    l_ScanEntry.SETRANGE("Document Line No.", l_TransferLine."Line No.");
                    IF l_ScanEntry.FINDSET THEN BEGIN
                        l_ScanEntry.CALCSUMS(Quantity);
                        ScanBuffer.Qty := ScanBuffer.Qty - l_ScanEntry.Quantity;
                    END;
                    IF l_Item.GET(l_TransferLine."Item No.") THEN
                        ScanBuffer."Qty(Base)" := ScanBuffer.Qty * UOMManager.GetQtyPerUnitOfMeasure(l_Item, l_TransferLine."Unit of Measure Code");
                    ScanBuffer.Uom := l_TransferLine."Unit of Measure Code";
                    ScanBuffer."Uom(Base)" := l_Item."Base Unit of Measure";
                    ScanBuffer.DocumentType := p_EntryType;
                    IF NOT ScanBuffer.INSERT THEN
                        ScanBuffer.MODIFY;
                UNTIL l_TransferLine.NEXT = 0;
        END;
        //For Write-off
        IF p_EntryType = p_EntryType::"Write-off" THEN BEGIN
            l_WriteOffLine.RESET;
            l_WriteOffLine.SETFILTER("Document No.", DocFilter);
            IF l_WriteOffLine.FINDSET THEN
                REPEAT
                    ScanBuffer.INIT;
                    ScanBuffer.DocumentNo := l_WriteOffLine."Document No.";
                    ScanBuffer.DocumentLineNo := l_WriteOffLine."Line No.";
                    ScanBuffer."Item No." := l_WriteOffLine."Item No.";
                    ScanBuffer.Qty := l_WriteOffLine.Quantity;
                    l_ScanEntry.RESET;
                    l_ScanEntry.SETRANGE("Document No.", l_WriteOffLine."Document No.");
                    l_ScanEntry.SETRANGE("Document Line No.", l_WriteOffLine."Line No.");
                    IF l_ScanEntry.FINDSET THEN BEGIN
                        l_ScanEntry.CALCSUMS(Quantity);
                        ScanBuffer.Qty := ScanBuffer.Qty - l_ScanEntry.Quantity;
                    END;
                    IF l_Item.GET(l_WriteOffLine."Item No.") THEN
                        ScanBuffer."Qty(Base)" := ScanBuffer.Qty * UOMManager.GetQtyPerUnitOfMeasure(l_Item, l_WriteOffLine."Unit of Measure Code");
                    ScanBuffer.Uom := l_WriteOffLine."Unit of Measure Code";
                    ScanBuffer."Uom(Base)" := l_Item."Base Unit of Measure";
                    ScanBuffer.DocumentType := p_EntryType;
                    IF NOT ScanBuffer.INSERT THEN
                        ScanBuffer.MODIFY;
                UNTIL l_WriteOffLine.NEXT = 0;
        END;
    end;

    procedure DistributionByDocs(var ScanEntry: Record "Item Scanning Entry")
    var
        ScanBuffer: Record "Scanning Buffer";
        RemainsB: Decimal;
        l_ScanEntry: Record "Item Scanning Entry";
        REmainsOST: Decimal;
        ItemUOM: Record "Item Unit of Measure";
        ExcAmount: label 'The scanned number outweighs the number in the document lines.';
        NoFindItem: label 'Item is not finding in document lines';
    begin

        RemainsB := ScanEntry."Quantity(Base)";
        ScanBuffer.RESET;
        ScanBuffer.SETFILTER(DocumentNo, ScanEntry."Document No.");
        ScanBuffer.SETRANGE("Item No.", ScanEntry."Item No.");
        IF NOT ScanBuffer.FINDFIRST THEN BEGIN
            ScanEntry.DELETE;
            ERROR(NoFindItem);
        END;
        ScanBuffer.SETFILTER("Qty(Base)", '>0');
        IF ScanBuffer.FINDSET THEN
            WHILE RemainsB > 0 DO BEGIN
                IF ScanBuffer."Qty(Base)" >= RemainsB THEN BEGIN
                    ScanEntry."Document No." := ScanBuffer.DocumentNo;
                    ScanEntry."Document Line No." := ScanBuffer.DocumentLineNo;
                    IF ScanBuffer.Uom <> ScanEntry."Unit of Measure" THEN BEGIN
                        ItemUOM.GET(ScanEntry."Item No.", ScanBuffer.Uom);
                        ScanEntry."Unit of Measure" := ScanBuffer.Uom;
                        ScanEntry.Quantity := UOMManagement.CalcQtyFromBase(ScanEntry.Quantity, ItemUOM."Qty. per Unit of Measure");
                    END;
                    ScanEntry.MODIFY;
                    ScanBuffer.Qty -= ScanEntry.Quantity;
                    ScanBuffer."Qty(Base)" -= ScanEntry."Quantity(Base)";
                    ScanBuffer.MODIFY;
                    RemainsB := 0;
                END ELSE BEGIN
                    IF ScanBuffer."Qty(Base)" <> 0 THEN BEGIN
                        ScanEntry."Document No." := ScanBuffer.DocumentNo;
                        ScanEntry."Document Line No." := ScanBuffer.DocumentLineNo;
                        RemainsOST := RemainsB - ScanBuffer."Qty(Base)";
                        ScanEntry.Quantity := ScanBuffer.Qty;
                        ScanEntry."Quantity(Base)" := ScanBuffer."Qty(Base)";
                        ScanEntry.MODIFY;
                        ScanBuffer.Qty := 0;
                        ScanBuffer."Qty(Base)" := 0;
                        ScanBuffer.MODIFY;
                        l_ScanEntry.INIT;
                        l_ScanEntry."Entry No." := ScanEntry."Entry No." + 1;
                        l_ScanEntry."Document No." := g_DocumentNo;
                        l_ScanEntry."Entry Type" := ScanEntry."Entry Type";
                        l_ScanEntry.Quantity := RemainsOST;
                        l_ScanEntry."Item No." := ScanEntry."Item No.";
                        l_ScanEntry."Unit of Measure" := ScanEntry."Unit of Measure";
                        l_ScanEntry."Quantity(Base)" := RemainsOST;
                        l_ScanEntry.Barcode := ScanEntry.Barcode;
                        l_ScanEntry.UserID := USERID;
                        l_ScanEntry.RealScan := ScanEntry.RealScan;
                        l_ScanEntry.SplitWithEntry := ScanEntry."Entry No.";
                        l_ScanEntry.INSERT;
                        DistributionByDocs(l_ScanEntry);
                    END;
                    RemainsB := 0;
                END;
            END ELSE BEGIN
            ERROR(ExcAmount);
            ScanEntry.DELETE;
        END;
    end;

    procedure EDitQuantityManualy()
    var
        l_ScanQty: Decimal;
        l_UnscanQty: Decimal;
        l_EnterQtyPage: Page ScanEnterQty;
        l_ScanBuffer: Record "Scanning Buffer";
    begin

        IF SelectedItemNo = '' THEN
            ERROR(FirstScanEntry);
        LastOpFilter := '';
        HaveSplit := FALSE;
        ScanEntry.RESET;
        ScanEntry.FINDLAST;
        LastOpFilter := FORMAT(ScanEntry."Entry No.");
        IF ScanEntry.SplitWithEntry <> 0 THEN
            HaveSplit := TRUE;
        WHILE HaveSplit DO BEGIN
            FindSplited(ScanEntry);
        END;
        ScanEntry.RESET;
        ScanEntry.SETFILTER("Entry No.", LastOpFilter);
        IF ScanEntry.FINDSET THEN
            ScanEntry.CALCSUMS("Quantity(Base)");
        l_ScanBuffer.RESET;
        l_ScanBuffer.SETFILTER(DocumentNo, g_DocumentNo);
        l_ScanBuffer.SETRANGE("Item No.", ScanEntry."Item No.");
        IF l_ScanBuffer.FINDSET THEN
            l_ScanBuffer.CALCSUMS("Qty(Base)");
        l_EnterQtyPage.SetParam(g_DocumentNo, ScanEntry."Item No.", ScanEntry."Quantity(Base)", l_ScanBuffer."Qty(Base)", l_ScanBuffer."Uom(Base)", g_DocumentNo, g_EntryType, LastOpFilter);
        l_EnterQtyPage.RUNMODAL;
    end;

    procedure FindSplited(var v_ScanEntry: Record "Item Scanning Entry")
    var
        l_txt: Text;
    begin
        v_ScanEntry.GET(v_ScanEntry.SplitWithEntry);

        LastOpFilter := LastOpFilter + '|' + FORMAT(v_ScanEntry."Entry No.");
        IF v_ScanEntry.SplitWithEntry = 0 THEN
            HaveSplit := FALSE;
    end;

    procedure DeletePrevOps(EntryFilter: Text)
    var
        l_ScanEntry: Record "Item Scanning Entry";
        l_ScanBuffer: Record "Scanning Buffer";
    begin
        l_ScanEntry.RESET;
        l_ScanEntry.SETFILTER("Entry No.", EntryFilter);
        IF l_ScanEntry.FINDSET THEN
            REPEAT
                l_ScanBuffer.RESET;
                l_ScanBuffer.SETRANGE(DocumentNo, l_ScanEntry."Document No.");
                l_ScanBuffer.SETRANGE(DocumentLineNo, l_ScanEntry."Document Line No.");
                IF l_ScanBuffer.FINDFIRST THEN BEGIN
                    l_ScanBuffer.Qty += l_ScanEntry.Quantity;
                    l_ScanBuffer."Qty(Base)" += l_ScanEntry."Quantity(Base)";
                    l_ScanBuffer.MODIFY;
                END;
                l_ScanEntry.DELETE;
            UNTIL l_ScanEntry.NEXT = 0;
    end;

    procedure InitEntry(v_EntryNo: Integer; v_EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory; v_DocumentNo: Code[250]; v_DocLineNo: Integer; v_Barcode: Code[20]; v_ItemNo: Code[20]; v_UOM: Code[10]; v_Qty: Decimal; v_RealScan: Boolean; v_QtyBase: Decimal; v_ManIns: Boolean; v_SplitEntry: Integer)
    begin
        ScanEntry.INIT;
        ScanEntry."Entry No." := v_EntryNo;
        ScanEntry."Entry Type" := v_EntryType;
        ScanEntry."Document No." := v_DocumentNo;
        ScanEntry."Document Line No." := v_DocLineNo;
        ScanEntry.Barcode := v_Barcode;
        ScanEntry."Item No." := v_ItemNo;
        ScanEntry."Unit of Measure" := v_UOM;
        ScanEntry.Quantity := v_Qty;
        ScanEntry.RealScan := v_RealSCan;
        ScanEntry."Quantity(Base)" := v_QtyBase;
        ScanEntry.ManualInsQty := v_ManIns;
        ScanEntry.SplitWithEntry := v_SplitEntry;
        ScanEntry.UserID := USERID;
        ScanEntry.INSERT;
    end;

    procedure SetWorkEntryParam(): Code[20]
    begin
        exit(SelectedItemNo);
    end;

    procedure SetManualyParam(DocumentNo: Code[250]; EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory; l_SelectedItem: Code[20]; l_SelectedUOM: Code[10]; l_Qty: Decimal)
    begin
        g_DocumentNo := DocumentNo;
        g_EntryType := EntryType;
        SelectedItemNo := l_SelectedItem;
        SelectedUOM := l_SelectedUOM;
        InsertedQty := l_Qty;
        CreateScanningEntry(FALSE);
    end;
}
