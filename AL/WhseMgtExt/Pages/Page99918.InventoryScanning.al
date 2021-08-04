page 99918 InventoryScanning
{

    Caption = 'Inventory Scanning';
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
                    ToolTip = 'Scanning Barcode';
                    trigger OnValidate()
                    begin
                        ScanHelper.SetInventoryParam(g_DocumentNo, g_EntryType, g_LocationCode);
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
                    Caption = 'Proceed Document No';
                    Editable = false;
                }
                field(g_LocationCode; g_LocationCode)
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    trigger OnDrillDown()
                    var
                        JnlLines: Record "Item Journal Line";
                        Location: Record Location;
                        LocationList: Page "Location List";
                        i: Integer;
                        t_Location: record Location temporary;
                        LocFilter: Text;
                    begin

                        i := 0;
                        t_Location.DELETEALL;
                        JnlLines.RESET;
                        JnlLines.SETRANGE("Document No.", g_DocumentNo);
                        IF JnlLines.FINDSET THEN
                            REPEAT
                                t_Location.RESET;
                                t_Location.SETRANGE(Code, JnlLines."Location Code");
                                IF NOT t_Location.FINDFIRST THEN BEGIN
                                    t_Location.INIT;
                                    t_Location.Code := JnlLines."Location Code";
                                    t_Location.INSERT;
                                END;
                            UNTIL JnlLines.NEXT = 0;
                        t_Location.RESET;
                        t_Location.FINDSET;
                        REPEAT
                            IF i = 0 THEN BEGIN
                                LocFilter := t_Location.Code;
                                i := 1;
                            END
                            ELSE
                                LocFilter += '|' + t_Location.Code;
                        UNTIL t_Location.NEXT = 0;
                        LocationList.LOOKUPMODE(TRUE);
                        Location.SETFILTER(Code, LocFilter);
                        LocationList.SETTABLEVIEW(Location);
                        IF LocationList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            LocationList.GETRECORD(Location);
                            g_LocationCode := Location.Code;
                            CLEAR(LocationList);
                        END;
                        ScanHelper.SetInventoryParam(g_DocumentNo, g_EntryType, g_LocationCode);
                        GetWorkEntryParam;
                    end;
                }
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Scanned Item No';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Calculated Quantity';
                    Editable = false;
                }
                field(ScannedQuantity; ScannedQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Scanned Quantity';
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
        EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
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
        ScanFilter: Code[250];
        UnscannedQty: Text;
        EnterQty: Page EnterQty;
        tmpVisible: boolean;
        g_LocationCode: Code[20];

    trigger OnOpenPage()
    begin
        ScanFilter := g_DocumentNo;
        DocumentNo := CONVERTSTR(ScanFilter, '|', ';');
        GetWorkEntryParam;
        tmpVisible := TRUE;
        IF g_EntryType = g_EntryType::TransOrderNew THEN
            tmpVisible := FALSE;
    end;

    trigger OnClosePage()
    var
        DocCreateTxt: label 'Document Lines for %1 was created';
    begin

        IF ScanHelper.CreateDocLines(g_DocumentNo, g_EntryType) THEN
            MESSAGE(DocCreateTxt, g_DocumentNo);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        GetWorkEntryParam;
    end;

    procedure SetParam("Document No.": Code[250]; "Entry Type": Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory)
    begin
        g_DocumentNo := "Document No.";
        g_EntryType := "Entry Type";
    end;

    procedure GetWorkEntryParam()
    var
        ScanEntry: Record "Item Scanning Entry";
        ScanBuffer: Record "Scanning Buffer";
        l_Item: Record Item;
        l_JnlLines: Record "Item Journal Line";
    begin
        ScannedQuantity := '0';
        Quantity := '0';
        UnscannedQty := '0';
        //g_ItemNo := ScanHelper.SetWorkEntryParam;
        IF l_Item.GET(g_ItemNo) THEN BEGIN
            UOM := l_Item."Base Unit of Measure";
            ItemNo := l_Item."No." + l_Item.Description;
        END;
        ScanEntry.RESET;
        ScanEntry.SETFILTER("Document No.", ScanFilter);
        ScanEntry.SETRANGE("Item No.", g_ItemNo);
        ScanEntry.SETRANGE("Location Code", g_LocationCode);
        IF ScanEntry.FINDSET THEN BEGIN
            ScanEntry.CALCSUMS("Quantity(Base)");
            ScannedQuantity := FORMAT(ScanEntry."Quantity(Base)") + ' ' + UOM;
        END;
        l_JnlLines.RESET;
        l_JnlLines.SETRANGE("Document No.", g_DocumentNo);
        l_JnlLines.SETRANGE("Location Code", g_LocationCode);
        l_JnlLines.SETRANGE("Item No.", g_ItemNo);
        IF l_JnlLines.FINDFIRST THEN
            Quantity := FORMAT(l_JnlLines."Qty. (Calculated)");
    end;

    procedure SelectItem(): Boolean
    var
        SelectItemPage3: Page ItemList4;
        Item: Record Item;
    begin
        IF g_EntryType = g_EntryType::Inventory THEN BEGIN
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

    procedure SetInventoryParam("Document No.": Code[250]; "Entry Type": Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory; LocationCode: Code[20])
    begin
        g_DocumentNo := "Document No.";
        g_EntryType := "Entry Type";
        g_LocationCode := LocationCode;
    end;

}

