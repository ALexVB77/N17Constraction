page 70267 InventoryDataInsert
{

    Caption = 'Inventory of materials';
    PageType = Card;
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(JournalTemplate; JournalTemplate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Journal Template';
                    Caption = 'Journal Template Name';
                }
                field(JournalBatch; JournalBatch)
                {
                    ApplicationArea = All;
                    ToolTip = 'Journal Batch Name';
                    Caption = 'Journal Batch Name';
                    trigger OnDrillDown()
                    var
                        BatchList: Page "Item Journal Batches";
                        BatchTable: Record "Item Journal Batch";
                    begin
                        BatchList.LOOKUPMODE(TRUE);
                        BatchTable.SETRANGE("Journal Template Name", JournalTemplate);
                        BatchList.SETTABLEVIEW(BatchTable);
                        IF BatchList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            BatchList.GETRECORD(BatchTable);
                            JournalBatch := BatchTable.Name;
                            CLEAR(BatchList);
                        END;
                    end;
                }
                field(LocationCode; LocationCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code';
                    Caption = 'Inventory Location Code';
                    trigger OnDrillDown()
                    var
                        JnlLines: Record "Item Journal Line";
                        Location: Record Location;
                        LocationList: Page "Location List";
                        i: Integer;
                        t_Location: Record Location;
                    begin

                        IF JournalBatch = '' THEN ERROR(NoBatchTxt);
                        i := 0;
                        t_Location.DELETEALL;
                        JnlLines.RESET;
                        JnlLines.SETRANGE("Journal Template Name", JournalTemplate);
                        JnlLines.SETRANGE("Journal Batch Name", JournalBatch);
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
                        Commit();
                        IF LocationList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            LocationList.GETRECORD(Location);
                            LocationCode := Location.Code;
                            CLEAR(LocationList);
                        END;
                    end;
                }
            }
        }


    }
    var
        JournalBatch: Code[10];
        JournalTemplate: Code[10];
        g_EntryType: Option ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        ScanningPage: Page InventoryScanning;
        ItemJnlLine: Record "Item Journal Line";
        LocationCode: Code[20];
        LocFilter: Text[250];
        NoJnlTmplTxt: Label 'No find inventory journal template';
        NoBatchTxt: Label 'Please choose item journal batch value';

    trigger OnOpenPage()
    var
        ItemJnlTempl: Record "Item Journal Template";
    begin
        ItemJnlTempl.RESET;
        ItemJnlTempl.SETRANGE("Page ID", 392);
        IF ItemJnlTempl.FINDFIRST THEN
            JournalTemplate := ItemJnlTempl.Name
        ELSE
            ERROR(NoJnlTmplTxt);
        g_EntryType := g_EntryType::Inventory;
    end;

    trigger OnClosePage()
    var
        CreateJnlTxt: Label 'Please create inventory journal lines before start scanning';
    begin
        IF JournalBatch = '' THEN
            ERROR(NoBatchTxt);
        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", JournalTemplate);
        ItemJnlLine.SETRANGE("Journal Batch Name", JournalBatch);
        IF NOT ItemJnlLine.FINDFIRST THEN
            ERROR(CreateJnlTxt)
        ELSE BEGIN
            ScanningPage.SetInventoryParam(ItemJnlLine."Document No.", g_EntryType, LocationCode);
            ScanningPage.RUNMODAL;
        END;
    end;
}
