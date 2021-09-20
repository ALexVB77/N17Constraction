page 70255 ScanEnterQty
{

    Caption = 'Enter Qty Mannually';
    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(g_DocNo; g_DocNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Document No.';
                    Caption = 'Document No.';
                    Editable = false;
                }
                field(g_NewQuantity; g_NewQuantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter Quantity';
                    Caption = 'Enter Quantity';
                }
                field(g_UOM; g_UOM)
                {
                    ApplicationArea = All;
                    ToolTip = 'Unit of Measure';
                    Caption = 'Unit of Measure';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SelectUOMPage: Page UOMList;
                        SelectUOMTable: Record "Item Unit of Measure";
                    begin

                        SelectUOMPage.LOOKUPMODE(TRUE);
                        SelectUOMTable.SETFILTER("Item No.", LookupItemNo);
                        SelectUOMPage.SETTABLEVIEW(SelectUOMTable);
                        IF SelectUOMPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            SelectUOMPage.GETRECORD(SelectUOMTable);
                            g_UOM := SelectUOMTable.Code;
                            CLEAR(SelectUOMPage);
                        END;
                        CurrPage.UPDATE;
                    end;
                }
                field(g_ItemNo; g_ItemNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Item Description';
                    Caption = 'Item Description';
                    Editable = false;
                }
                field(g_ScanQty; g_ScanQty)
                {
                    ApplicationArea = All;
                    ToolTip = 'Earlier Scanned Quantity';
                    Caption = 'Earlier Scanned Quantity';
                    Editable = false;
                }
                field(g_UnscanQty; g_UnscanQty)
                {
                    ApplicationArea = All;
                    ToolTip = 'Unscanned Quantity (Remain)';
                    Caption = 'Unscanned Quantity (Remain)';
                }
            }
        }
    }
    var
        Quantity: Decimal;
        ScanHelper: Codeunit "Scanning Helper";
        g_DocNo: Code[250];
        g_ScanQty: Text;
        g_ItemNo: Text;
        g_UnscanQty: Text;
        g_UOM: Code[10];
        g_NewQuantity: Decimal;
        LookupItemNo: Code[20];
        g_OpFilter: Text;
        g_DocumentNo: Code[250];
        g_EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        g_LocationCode: Code[10];

    trigger OnClosePage()
    begin
        IF g_NewQuantity <> 0 THEN
            ScanHelper.InsertQuantity(LookupItemNo, g_UOM, g_NewQuantity, g_DocumentNo, g_EntryType, g_OpFilter, g_LocationCode);
    end;

    procedure SetParam(DocNo: Code[250]; ItemNo: Code[20]; ScannedQty: Decimal; UnscannedQty: Decimal; UOM: Code[10]; "Document No.": Code[250]; "Entry Type": Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory; OpFilter: Text; LocationCode: Code[10])
    var
        l_Item: Record Item;
    begin

        g_UOM := UOM;
        g_DocNo := DocNo;
        g_ScanQty := FORMAT(ScannedQty) + ' ' + UOM;
        g_UnscanQty := FORMAT(UnscannedQty) + ' ' + UOM;
        l_Item.GET(ItemNo);
        g_ItemNo := ItemNo + ' ' + l_Item.Description;
        LookupItemNo := ItemNo;
        g_OpFilter := OpFilter;
        g_DocumentNo := "Document No.";
        g_EntryType := "Entry Type";
        g_LocationCode := LocationCode;
    end;
}


