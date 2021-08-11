page 99907 EnterQty
{

    Caption = 'Enter Quantity';
    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(EnterQty; EnterQty)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter Quantity';
                    Caption = 'Enter Quantity';
                }
            }
        }
    }
    var
        EnterQty: Decimal;
        ScanHelper: Codeunit "Scanning Helper";
        g_DocumentNo: Code[250];
        g_EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        g_ItemNo: Code[20];
        g_UOM: Code[10];
        g_LocationCode: Code[10];

    trigger OnClosePage()
    var
        NoNulltxt: Label 'Enter not null quantity';
    begin

        IF EnterQty <> 0 THEN
            ScanHelper.SetManualyParam(g_DocumentNo, g_EntryType, g_ItemNo, g_UOM, EnterQty, g_LocationCode)
        ELSE
            ERROR(NoNulltxt);
    end;

    procedure SetParam("Document No.": Code[250]; "Entry Type": Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory; SelectedItem: Code[20]; SelectedUOM: Code[10]; LocationCode: Code[10])
    begin
        g_DocumentNo := "Document No.";
        g_EntryType := "Entry Type";
        g_ItemNo := SelectedItem;
        g_UOM := SelectedUOM;
        g_LocationCode := LocationCode;
    end;
}
