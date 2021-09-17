page 70251 Scanning
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
                    Caption = 'Proceed Document Number';
                    Editable = false;
                }
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Proceed Item No.';
                    Caption = 'Scanned Item';
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Quantity';
                    Caption = 'Quantity in Document';
                    Editable = false;
                }
                field(ScannedQuantity; ScannedQuantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Scanned Quantity';
                    Caption = 'Scanned Quantity';
                    Editable = false;
                }
                field(UnscannedQty; UnscannedQty)
                {
                    ApplicationArea = All;
                    ToolTip = 'Unscanned Quantity';
                    Caption = 'Unscanned Quantity';
                    Editable = false;
                    Visible = tmpVisible;
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action("Enter Quantity Manual")
            {
                ApplicationArea = All;
                Caption = 'Enter Quantity Manualy';
                trigger OnAction()
                var
                    EnterPage: Page ScanEnterQty;
                begin
                    ScanHelper.EditQuantityManualy;
                    GetWorkEntryParam;
                    CurrPage.UPDATE;
                end;
            }
            action("Enter Without Scanning")
            {
                ApplicationArea = All;
                Caption = 'Enter Item without scanning';
                trigger OnAction()
                begin
                    Clear(EnterQty);
                    SelectItem;
                    SelectUOM;
                    EnterQty.SetParam(g_DocumentNo, g_EntryType, g_ItemNo, UOM, '');
                    EnterQty.RUNMODAL;
                    GetWorkEntryParam;
                    CurrPage.UPDATE;
                end;
            }
            action(ScanHistory)
            {
                ApplicationArea = All;
                Caption = 'Scanning History';
                trigger OnAction()
                var
                    ScanHistory: Page ScanningHistory;
                    ScanEntry: Record "Item Scanning Entry";
                begin
                    ScanEntry.RESET;
                    ScanEntry.SETRANGE("Document No.", g_DocumentNo);
                    ScanHistory.SETTABLEVIEW(ScanEntry);
                    ScanHistory.RUNMODAL;
                end;
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
        tmpVisible: Boolean;

    trigger OnInit()
    begin
        GetWorkEntryParam();
    end;

    trigger OnOpenPage()
    begin
        ScanFilter := g_DocumentNo;
        DocumentNo := CONVERTSTR(ScanFilter, '|', ';');
        GetWorkEntryParam;
        tmpVisible := TRUE;
        IF g_EntryType = g_EntryType::TransOrderNew THEN
            tmpVisible := FALSE;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        GetWorkEntryParam();
    end;

    trigger OnClosePage()
    var
        LineCreatedTxt: Label 'Document Lines for %1 was created';
    begin
        IF ScanHelper.CreateDocLines(g_DocumentNo, g_EntryType) THEN
            MESSAGE(LineCreatedTxt, g_DocumentNo);
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
        IF g_ItemNo = '' THEN
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

        IF (g_EntryType = g_EntryType::TransOrderNew) OR (g_EntryType = g_EntryType::MatOrderNew) OR (g_EntryType = g_EntryType::WrOffNew) THEN BEGIN
            Quantity := ScannedQuantity;
            IF l_Item.GET(g_ItemNo) THEN
                ItemNo := l_Item."No." + ' ' + l_Item.Description;
        END;
    end;

    procedure SetParam("Document No.": Code[250]; v_EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory)
    begin
        g_DocumentNo := "Document No.";
        g_EntryType := v_EntryType;
    end;

    procedure SelectItem(): Boolean
    var
        PurchLines: Record "Purchase Line";
        SelectItemPage: Page ItemList1;
        TransferLines: Record "Transfer Line";
        SelectItemPage1: Page ItemList2;
        SelectItemPage2: Page ItemList3;
        WriteoffLines: Record "Item Document Line";
        SelectItemPage3: Page ItemList4;
        Item: Record Item;
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

        //For new Transfer order
        IF (g_EntryType = g_EntryType::TransOrderNew) OR (g_EntryType = g_EntryType::MatOrderNew) OR (g_EntryType = g_EntryType::WrOffNew) THEN BEGIN
            SelectItemPage3.LOOKUPMODE(TRUE);
            Item.SETRANGE(Blocked, FALSE);
            SelectItemPage3.SETTABLEVIEW(Item);
            IF SelectItemPage3.RUNMODAL = ACTION::LookupOK THEN BEGIN
                SelectItemPage3.GETRECORD(Item);
                g_ItemNo := Item."No.";
                CLEAR(SelectItemPage3);
                EXIT(TRUE);
            END ELSE BEGIN
                CLEAR(SelectItemPage3);
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