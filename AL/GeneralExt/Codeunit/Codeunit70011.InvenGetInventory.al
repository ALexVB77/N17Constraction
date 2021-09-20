codeunit 70011 "Inven.-Get Inventory"
{
    TableNo = "Item Document Line";
    trigger OnRun()
    var
        lrTempInvenLedgEntry: Record "Item Ledger Entry" temporary;
    begin
        ItemDocumentHeader.GET(Rec."Document Type", Rec."Document No.");
        ItemDocumentHeader.TESTFIELD(Status, ItemDocumentHeader.Status::Open);
        ItemDocumentHeader.TESTFIELD("Location Code");
        GetInventoryLines(lrTempInvenLedgEntry, ItemDocumentHeader);
        GetInventory.SetSource(lrTempInvenLedgEntry);
        GetInventory.SetItemDocumentHeader(ItemDocumentHeader);
        GetInventory.LOOKUPMODE := TRUE;
        IF GetInventory.RUNMODAL IN [ACTION::OK, ACTION::LookupOK] THEN
            GetInventory.CreateLines;
    end;

    procedure CreateItemDocumentLines(var pInventoryLine: Record "Item Ledger Entry")
    var
        ltTempInvBuffer: Record "Inventory Buffer" temporary;
    begin
        WITH pInventoryLine DO BEGIN
            SETFILTER("Remaining Quantity", '>0');
            // Fix - more ledger entries with same item and lot. Needs to track already used warehouse entries.
            TempInvBufferUsed.RESET;
            TempInvBufferUsed.DELETEALL;
            IF FINDSET THEN BEGIN
                ItemDocumentLine.LOCKTABLE;
                ItemDocumentLine.SETRANGE("Document Type", ItemDocumentHeader."Document Type");
                ItemDocumentLine.SETRANGE("Document No.", ItemDocumentHeader."No.");
                ItemDocumentLine."Document Type" := ItemDocumentHeader."Document Type";
                ItemDocumentLine."Document No." := ItemDocumentHeader."No.";

                REPEAT
                    ltTempInvBuffer.RESET;
                    ltTempInvBuffer.DELETEALL;
                    _GetBinContent(pInventoryLine, ltTempInvBuffer);
                    InventoryLine := pInventoryLine;
                    InventoryLine.InsertDocLineFromILE(ItemDocumentLine, ltTempInvBuffer);
                UNTIL NEXT = 0;
            END;
        END;
    end;

    procedure SetItemDocumentHeader(var ItemDocumentHeader2: Record "Item Document Header")
    begin
        ItemDocumentHeader.GET(ItemDocumentHeader2."Document Type", ItemDocumentHeader2."No.");
        ItemDocumentHeader.TESTFIELD("Document Type", ItemDocumentHeader."Document Type"::Shipment);
    end;

    procedure GetInventoryLines(var pTempItemLedgEntryLine: Record "Item Ledger Entry" temporary; ItemDocumentHeader: Record "Item Document Header")

    begin

        InventoryLine.RESET;
        InventoryLine.SETCURRENTKEY("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date",
                                    "Expiration Date", "Lot No.", "Serial No.");

        InventoryLine.SETRANGE(Open, TRUE);
        InventoryLine.SETRANGE("Location Code", ItemDocumentHeader."Location Code");
        InventoryLine.SETFILTER(InventoryLine."Remaining Quantity", '>0');

        IF InventoryLine.FINDSET THEN BEGIN
            REPEAT
                pTempItemLedgEntryLine := InventoryLine;
                pTempItemLedgEntryLine.INSERT;
            UNTIL InventoryLine.NEXT = 0;
        END;

    end;

    procedure _GetBinContent(prILE: Record "Item Ledger Entry"; var varInvBuffer: Record "Inventory Buffer" temporary)
    begin

    end;

    procedure _GetInitBinFromWHSE(prILE: Record "Item Ledger Entry"): Code[20]
    var

        lrSalesShipmentLine: Record "Sales Shipment Line";
        lrPurchaseReceiptLine: Record "Purch. Rcpt. Line";
        lrPurchaseInvoiceLine: Record "Purch. Inv. Line";
        lrPurchaseCrMemoLine: Record "Purch. Cr. Memo Line";
        lrPurchaseReturnShipmentLine: Record "Return Shipment Line";
        lrTransferShipmentLine: Record "Transfer Shipment Line";
        lrTransferReceiptLine: Record "Transfer Receipt Line";
        lrSalesinvoiceLine: Record "Sales Invoice Line";
        lrSalesCrMemoLine: Record "Sales Cr.Memo Line";
        lrSalesReturnReceiptLine: Record "Return Receipt Line";
        lrItemRecptLine: Record "Item Receipt Line";
        lrItemShipLine: Record "Item Shipment Line";
    begin

        CASE prILE."Document Type" OF
            prILE."Document Type"::"Sales Shipment":
                IF lrSalesShipmentLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrSalesShipmentLine."Bin Code");
            prILE."Document Type"::"Sales Invoice":
                IF lrSalesinvoiceLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrSalesinvoiceLine."Bin Code");
            prILE."Document Type"::"Sales Credit Memo":
                IF lrSalesCrMemoLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrSalesCrMemoLine."Bin Code");
            prILE."Document Type"::"Sales Return Receipt":
                IF lrSalesReturnReceiptLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrSalesReturnReceiptLine."Bin Code")
;
            prILE."Document Type"::"Purchase Receipt":
                IF lrPurchaseReceiptLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrPurchaseReceiptLine."Bin Code");
            prILE."Document Type"::"Purchase Invoice":
                IF lrPurchaseInvoiceLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrPurchaseInvoiceLine."Bin Code");
            prILE."Document Type"::"Purchase Credit Memo":
                IF lrPurchaseCrMemoLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrPurchaseCrMemoLine."Bin Code");
            prILE."Document Type"::"Purchase Return Shipment":
                IF lrPurchaseReturnShipmentLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrPurchaseReturnShipmentLine.
"Bin Code");
            prILE."Document Type"::"Transfer Shipment":
                IF lrTransferShipmentLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrTransferShipmentLine.
"Transfer-from Bin Code");
            prILE."Document Type"::"Transfer Receipt":
                IF lrTransferReceiptLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrTransferReceiptLine.
"Transfer-To Bin Code");
            prILE."Document Type"::"Item Receipt":
                IF lrItemRecptLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrItemRecptLine."Bin Code");
            prILE."Document Type"::"Item Shipment":
                IF lrItemShipLine.GET(prILE."Document No.", prILE."Document Line No.") THEN
                    EXIT(lrItemShipLine."Bin Code");
            //Service Shipment,Service Invoice,Service Credit Memo,Posted Assembly,Posted Disassembly
            ELSE
                EXIT('');
        END;
    end;

    procedure _CheckLocBinCombiantion(pcLocation: Code[20]; pcBin: Code[20]): Code[20]
    var
        lrBin: Record Bin;
    begin
        // <DEV.015 />
        IF lrBin.GET(pcLocation, pcBin) THEN EXIT(lrBin.Code) ELSE EXIT('');

    end;

    procedure AvailableBinQty(lrInvBuffer: Record "Inventory Buffer" temporary; QtyOnBin: Decimal; var varGlobalBufferUsedQty: Record "Inventory Buffer" temporary): Decimal

    begin

        varGlobalBufferUsedQty.RESET;
        varGlobalBufferUsedQty.SETRANGE("Item No.", lrInvBuffer."Item No.");
        varGlobalBufferUsedQty.SETRANGE("Variant Code", lrInvBuffer."Variant Code");
        varGlobalBufferUsedQty.SETRANGE("Location Code", lrInvBuffer."Location Code");
        varGlobalBufferUsedQty.SETRANGE("Bin Code", lrInvBuffer."Bin Code");
        varGlobalBufferUsedQty.SETRANGE("Lot No.", lrInvBuffer."Lot No.");
        varGlobalBufferUsedQty.SETRANGE("Serial No.", lrInvBuffer."Serial No.");
        //varGlobalBufferUsedQty.SETRANGE("CD No.", lrInvBuffer."CD No.");
        varGlobalBufferUsedQty.SETRANGE("Dimension Entry No.", 0);
        varGlobalBufferUsedQty.CALCSUMS(Quantity);
        QtyOnBin := QtyOnBin - varGlobalBufferUsedQty.Quantity;
        IF NOT varGlobalBufferUsedQty.FINDFIRST THEN BEGIN
            varGlobalBufferUsedQty.INIT;
            varGlobalBufferUsedQty."Item No." := lrInvBuffer."Item No.";
            varGlobalBufferUsedQty."Variant Code" := lrInvBuffer."Variant Code";
            varGlobalBufferUsedQty."Location Code" := lrInvBuffer."Location Code";
            varGlobalBufferUsedQty."Bin Code" := lrInvBuffer."Bin Code";
            varGlobalBufferUsedQty."Lot No." := lrInvBuffer."Lot No.";
            varGlobalBufferUsedQty."Serial No." := lrInvBuffer."Serial No.";
            //varGlobalBufferUsedQty."CD No." := lrInvBuffer."CD No.";
            varGlobalBufferUsedQty."Dimension Entry No." := 0;
            varGlobalBufferUsedQty.INSERT;
        END;
        varGlobalBufferUsedQty.RESET;
        EXIT(QtyOnBin);

    end;

    var

        ItemDocumentHeader: Record "Item Document Header";
        ItemDocumentLine: Record "Item Document Line";
        InventoryLine: Record "Item Ledger Entry";
        GetInventory: Page "Get Item Ledger Entry Lines";
        TempInvBufferUsed: Record "Inventory Buffer" temporary;

}