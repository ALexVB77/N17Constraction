page 99901 Scanning
{

    Caption = 'Scanning';
    PageType = Card;


    layout
    {
        area(content)
        {
            group(General)
            {
                field(Barcode; Barcode)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin

                        ScanHelper.SetParam(ScanFilter, g_EntryType);
                        IF Barcode <> '' THEN BEGIN
                            IF ScanHelper.SearchBarcode(Barcode) THEN BEGIN
                                ScanHelper.CreateScanningEntry(TRUE);
                                GetWorkEntryParam;
                            END
                            ELSE
                                ScanHelper.CreateBarcode(Barcode, '');
                            GetWorkEntryParam;
                        END;
                    end;

                }
                field(DocumentNo; DocumentNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Document Number';
                    Editable = false;
                }
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Proceed Item No.';
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Quantity';
                    Editable = false;
                }
                field(ScannedQuantity; ScannedQuantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Scanned Quantity';
                    Editable = false;
                }
                field(UnscannedQty; UnscannedQty)
                {
                    ApplicationArea = All;
                    ToolTip = 'Unscanned Quantity';
                    Editable = false;
                }
            }
        }

    }

    var
        "Document No.": Code[250];
        "Entry Type": Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        Barcodes: Record "Item Identifier";

        ScanEntry: Record "Item Scanning Entry";
        ScanHelper: Codeunit "Scanning Helper";
        g_DocumentNo: Code[250];
        g_EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        Barcode: Code[15];
        DocumentNo: Text;
        ItemNo: Text;
        Quantity: Text;
        ScannedQuantity: Text;
        g_ItemNo: Code[20];
        UOM: Code[10];
        ScanFilter: Text;
        UnscannedQty: Text;
        EnterQty: Page EnterQty;

    trigger OnInit()
    begin
        GetWorkEntryParam();
    end;

    trigger OnOpenPage()
    begin
        ScanFilter := g_DocumentNo;
        DocumentNo := CONVERTSTR(ScanFilter, '|', ';');
        GetWorkEntryParam;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        GetWorkEntryParam();
    end;

    procedure GetWorkEntryParam()
    var
        PurchaseLine: Record "Purchase Line";
        ScanEntry: Record "Item Scanning Entry";
        ScanBuffer: Record "Scanning Buffer";
        l_Item: Record Item;
        TransferLine: Record "Transfer Line";
        WriteoffLine: Record "Item Document Line";
    begin
        ScannedQuantity := '0';
        Quantity := '0';
        UnscannedQty := '0';
        g_ItemNo := ScanHelper.SetWorkEntryParam;
        IF l_Item.GET(g_ItemNo) THEN
            UOM := l_Item."Base Unit of Measure";
        ScanEntry.RESET;
        ScanEntry.SETFILTER("Document No.", ScanFilter);
        ScanEntry.SETRANGE("Item No.", g_ItemNo);
        IF ScanEntry.FINDSET THEN BEGIN
            ScanEntry.CALCSUMS("Quantity(Base)");
            ScannedQuantity := FORMAT(ScanEntry."Quantity(Base)") + ' ' + UOM;
        END;
        //For Purchase Order
        IF g_EntryType = g_EntryType::Posting THEN BEGIN
            PurchaseLine.RESET;
            PurchaseLine.SETFILTER("Document No.", ScanFilter);
            PurchaseLine.SETRANGE("No.", g_ItemNo);
            IF PurchaseLine.FINDSET THEN BEGIN
                ItemNo := PurchaseLine."No." + ' ' + PurchaseLine.Description;
                PurchaseLine.CALCSUMS("Quantity (Base)");
                Quantity := FORMAT(PurchaseLine."Quantity (Base)") + ' ' + UOM;
            END;
            ScanBuffer.RESET;
            ScanBuffer.SETFILTER(DocumentNo, ScanFilter);
            ScanBuffer.SETRANGE("Item No.", g_ItemNo);
            IF ScanBuffer.FINDSET THEN BEGIN
                ScanBuffer.CALCSUMS("Qty(Base)");
                UnscannedQty := FORMAT(ScanBuffer."Qty(Base)") + ' ' + UOM;
            END;
        END;
        //For Transfer Order
        IF g_EntryType = g_EntryType::TransOrder THEN BEGIN
            TransferLine.RESET;
            TransferLine.SETFILTER("Document No.", ScanFilter);
            TransferLine.SETRANGE("Item No.", g_ItemNo);
            IF TransferLine.FINDSET THEN BEGIN
                ItemNo := TransferLine."Item No." + ' ' + TransferLine.Description;
                TransferLine.CALCSUMS("Quantity (Base)");
                Quantity := FORMAT(TransferLine."Quantity (Base)") + ' ' + UOM;
            END;
            ScanBuffer.RESET;
            ScanBuffer.SETFILTER(DocumentNo, ScanFilter);
            ScanBuffer.SETRANGE("Item No.", g_ItemNo);
            IF ScanBuffer.FINDSET THEN BEGIN
                ScanBuffer.CALCSUMS("Qty(Base)");
                UnscannedQty := FORMAT(ScanBuffer."Qty(Base)") + ' ' + UOM;
            END;
        END;
        //For Write-off
        IF g_EntryType = g_EntryType::"Write-off" THEN BEGIN
            WriteoffLine.RESET;
            WriteoffLine.SETFILTER("Document No.", ScanFilter);
            WriteoffLine.SETRANGE("Item No.", g_ItemNo);
            IF WriteoffLine.FINDSET THEN BEGIN
                ItemNo := WriteoffLine."Item No." + ' ' + WriteoffLine.Description;
                WriteoffLine.CALCSUMS("Quantity (Base)");
                Quantity := FORMAT(WriteoffLine."Quantity (Base)") + ' ' + UOM;
            END;
            ScanBuffer.RESET;
            ScanBuffer.SETFILTER(DocumentNo, ScanFilter);
            ScanBuffer.SETRANGE("Item No.", g_ItemNo);
            IF ScanBuffer.FINDSET THEN BEGIN
                ScanBuffer.CALCSUMS("Qty(Base)");
                UnscannedQty := FORMAT(ScanBuffer."Qty(Base)") + ' ' + UOM;
            END;
        END;
    end;

    procedure SetParam("Document No.": Code[250]; "EntryType": Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory)
    begin
        g_DocumentNo := "Document No.";
        g_EntryType := "Entry Type";
    end;

    procedure SelectItem(): Boolean
    var
        PurchLines: Record "Purchase Line";
        SelectItemPage: Page ItemList1;
        TransferLines: Record "Transfer Line";
        SelectItemPage1: Page ItemList2;
        SelectItemPage2: Page ItemList3;
        WriteoffLines: Record "Item Document Line";
    begin

        //For Purchase Order
        IF g_EntryType = g_EntryType::Posting THEN BEGIN
            SelectItemPage.LOOKUPMODE(TRUE);
            PurchLines.SETFILTER("Document No.", g_DocumentNo);
            SelectItemPage.SETTABLEVIEW(PurchLines);
            IF SelectItemPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
                SelectItemPage.GETRECORD(PurchLines);
                g_ItemNo := PurchLines."No.";
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
            TransferLines.SETFILTER("Document No.", g_DocumentNo);
            SelectItemPage1.SETTABLEVIEW(TransferLines);
            IF SelectItemPage1.RUNMODAL = ACTION::LookupOK THEN BEGIN
                SelectItemPage1.GETRECORD(TransferLines);
                g_ItemNo := TransferLines."Item No.";
                CLEAR(SelectItemPage1);
                EXIT(TRUE);
            END ELSE BEGIN
                CLEAR(SelectItemPage1);
                EXIT(FALSE);
            END;
        END;
        //For Write-off
        IF g_EntryType = g_EntryType::TransOrder THEN BEGIN
            SelectItemPage2.LOOKUPMODE(TRUE);
            WriteoffLines.SETFILTER("Document No.", g_DocumentNo);
            SelectItemPage2.SETTABLEVIEW(WriteoffLines);
            IF SelectItemPage2.RUNMODAL = ACTION::LookupOK THEN BEGIN
                SelectItemPage2.GETRECORD(WriteoffLines);
                g_ItemNo := WriteoffLines."Item No.";
                CLEAR(SelectItemPage2);
                EXIT(TRUE);
            END ELSE BEGIN
                CLEAR(SelectItemPage2);
                EXIT(FALSE);
            END;
        END;
        //For MaterialOrder
        IF g_EntryType = g_EntryType::MatOrder THEN BEGIN
            SelectItemPage1.LOOKUPMODE(TRUE);
            TransferLines.SETFILTER("Document No.", g_DocumentNo);
            SelectItemPage1.SETTABLEVIEW(TransferLines);
            IF SelectItemPage1.RUNMODAL = ACTION::LookupOK THEN BEGIN
                SelectItemPage1.GETRECORD(TransferLines);
                g_ItemNo := TransferLines."Item No.";
                CLEAR(SelectItemPage1);
                EXIT(TRUE);
            END ELSE BEGIN
                CLEAR(SelectItemPage1);
                EXIT(FALSE);
            END;
        END;
    end;

    procedure SelectUOM(): Boolean
    var
        SelectUOMPage: Page UOMList;
        SelectUOMTable: Record "Item Unit of Measure";
    begin
        SelectUOMPage.LOOKUPMODE(TRUE);
        SelectUOMTable.SETFILTER("Item No.", g_ItemNo);
        SelectUOMPage.SETTABLEVIEW(SelectUOMTable);
        IF SelectUOMPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
            SelectUOMPage.GETRECORD(SelectUOMTable);
            UOM := SelectUOMTable.Code;
            CLEAR(SelectUOMPage);
            EXIT(TRUE);
        END ELSE BEGIN
            CLEAR(SelectUOMPage);
            EXIT(FALSE);
        END;
    end;

}