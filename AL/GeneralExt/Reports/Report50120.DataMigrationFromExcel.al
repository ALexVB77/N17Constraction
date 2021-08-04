report 50120 "Data Migration From Excel"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Data Migration From Excel';
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        ServerFileName: Text;
        FileManagement: Codeunit "File Management";
        SheetName: Text;
        Text001: Label 'Data Migration From Excel';
        ExcelExt: Label '*.xlsx';
        RowNo: Integer;
        CustomerPostingGroup: Record "Customer Posting Group";
        VondorPostingGroup: Record "Vendor Posting Group";
        InventoryPostingGroup: Record "Inventory Posting Group";
        FAPostingGroup: Record "FA Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        DimensionValue: Record "Dimension Value";
        DimensionMapping: Record "Dimension Mapping";
        LocationMapping: Record "Location Mapping";
        Text0001: Label 'Customer Posting Group';
        Text0002: Label 'Vendor Pposting Group';
        Text0003: Label 'Inventory Posting Group';
        Text0004: Label 'FA Posting Group';
        Text0005: Label 'General Business Posting Group';
        Text0006: Label 'General Product Posting Group';
        Text0007: Label 'VAT Product Posting Group';
        Text0008: Label 'VAT Business Posting Group';
        Text0009: Label 'General Posting Setup';
        Text0010: Label 'Dimension Mapping';
        Text0011: Label 'CC';
        Text0012: Label 'CP';
        Text0013: Label 'НП';
        Text0014: Label 'НУ-ВИД';
        Text0015: Label 'НУ-ОБЪЕКТ';
        Text0016: Label 'НУ-РАЗНИЦА';
        Text0017: Label 'ПРИБ_УБ_ПРОШ_ЛЕТ';
        Text0018: Label 'Locations';
        Text0019: Label 'ПРОЕКТ';
    begin
        ServerFileName := FileManagement.UploadFile(Text001, ExcelExt);
        if ServerFileName = '' then
            exit;
        SheetName := ExcelBuffer.SelectSheetsName(ServerFileName);
        if SheetName = '' then
            exit;
        ExcelBuffer.LockTable();
        ExcelBuffer.OpenBook(ServerFileName, SheetName);
        ExcelBuffer.ReadSheet();

        case GetValueAtCell(1, 1) of
            Text0001:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not CustomerPostingGroup.Get(GetValueAtCell(RowNo, 1)) then begin
                            CustomerPostingGroup.Init();
                            CustomerPostingGroup.Code := GetValueAtCell(RowNo, 1);
                            CustomerPostingGroup.Description := GetValueAtCell(RowNo, 2);
                            //CustomerPostingGroup."Apply Cust. Post. Group" := GetValueAtCell(RowNo, 3);
                            CustomerPostingGroup."Receivables Account" := GetValueAtCell(RowNo, 4);
                            CustomerPostingGroup."Prepayment Account" := GetValueAtCell(RowNo, 5);
                            CustomerPostingGroup."Debit Rounding Account" := GetValueAtCell(RowNo, 14);
                            CustomerPostingGroup."Credit Rounding Account" := GetValueAtCell(RowNo, 15);
                            //CustomerPostingGroup."Skip Posting" := GetValueAtCell(RowNo, 18);
                            CustomerPostingGroup.Insert(true);
                        end;
                end;
            Text0002:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not VondorPostingGroup.Get(GetValueAtCell(RowNo, 1)) then begin
                            VondorPostingGroup.Init();
                            VondorPostingGroup.Code := GetValueAtCell(RowNo, 1);
                            VondorPostingGroup.Description := GetValueAtCell(RowNo, 2);
                            VondorPostingGroup."Payables Account" := GetValueAtCell(RowNo, 3);
                            VondorPostingGroup."Prepayment Account" := GetValueAtCell(RowNo, 4);
                            VondorPostingGroup."Debit Curr. Appln. Rndg. Acc." := GetValueAtCell(RowNo, 5);
                            VondorPostingGroup."Credit Curr. Appln. Rndg. Acc." := GetValueAtCell(RowNo, 6);
                            VondorPostingGroup."Debit Rounding Account" := GetValueAtCell(RowNo, 7);
                            VondorPostingGroup."Credit Rounding Account" := GetValueAtCell(RowNo, 8);
                            VondorPostingGroup.Insert(true);
                        end;
                end;
            Text0003:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not InventoryPostingGroup.Get(GetValueAtCell(RowNo, 1)) then begin
                            InventoryPostingGroup.Init();
                            InventoryPostingGroup.Code := GetValueAtCell(RowNo, 1);
                            InventoryPostingGroup.Description := GetValueAtCell(RowNo, 2);
                            //InventoryPostingGroup."?" := GetValueAtCell(RowNo, 3);
                            //InventoryPostingGroup."Purch. Amt. Diff. Alloc. Type" := GetValueAtCell(RowNo, 4);
                            InventoryPostingGroup."Purch. PD Charge FCY (Item)" := GetValueAtCell(RowNo, 5);
                            InventoryPostingGroup."Purch. PD Charge Conv. (Item)" := GetValueAtCell(RowNo, 6);
                            InventoryPostingGroup."Sales PD Charge FCY (Item)" := GetValueAtCell(RowNo, 7);
                            InventoryPostingGroup."Sales PD Charge Conv. (Item)" := GetValueAtCell(RowNo, 8);
                            InventoryPostingGroup.Insert(true);
                        end;
                end;
            Text0004:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not FAPostingGroup.Get(GetValueAtCell(RowNo, 1)) then begin
                            FAPostingGroup.Init();
                            FAPostingGroup.Code := GetValueAtCell(RowNo, 1);
                            FAPostingGroup.Description := GetValueAtCell(RowNo, 2);
                            FAPostingGroup."Acquisition Cost Account" := GetValueAtCell(RowNo, 3);
                            FAPostingGroup."Accum. Depreciation Account" := GetValueAtCell(RowNo, 4);
                            FAPostingGroup."Write-Down Account" := GetValueAtCell(RowNo, 5);
                            FAPostingGroup."Write-Down Acc. on Disposal" := GetValueAtCell(RowNo, 6);
                            //FAPostingGroup."Disposal Expense Account" := GetValueAtCell(RowNo, 7);
                            FAPostingGroup."Acquisition Cost Bal. Acc." := GetValueAtCell(RowNo, 8);
                            FAPostingGroup."Sales Bal. Acc." := GetValueAtCell(RowNo, 9);
                            FAPostingGroup."Acq. Cost Acc. on Disposal" := GetValueAtCell(RowNo, 10);
                            FAPostingGroup."Accum. Depr. Acc. on Disposal" := GetValueAtCell(RowNo, 11);
                            FAPostingGroup."Gains Acc. on Disposal" := GetValueAtCell(RowNo, 12);
                            FAPostingGroup."Losses Acc. on Disposal" := GetValueAtCell(RowNo, 13);
                            FAPostingGroup."Depreciation Expense Acc." := GetValueAtCell(RowNo, 14);
                            FAPostingGroup."Disposal Expense Account" := GetValueAtCell(RowNo, 15);
                            FAPostingGroup.Insert(true);
                        end;
                end;
            Text0005:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not GenBusinessPostingGroup.Get(GetValueAtCell(RowNo, 1)) then begin
                            GenBusinessPostingGroup.Init();
                            GenBusinessPostingGroup.Code := GetValueAtCell(RowNo, 1);
                            GenBusinessPostingGroup.Description := GetValueAtCell(RowNo, 2);
                            GenBusinessPostingGroup.Insert(true);
                        end;
                end;
            Text0006:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not GenProductPostingGroup.Get(GetValueAtCell(RowNo, 1)) then begin
                            GenProductPostingGroup.Init();
                            GenProductPostingGroup.Code := GetValueAtCell(RowNo, 1);
                            GenProductPostingGroup.Description := GetValueAtCell(RowNo, 2);
                            GenProductPostingGroup."Def. VAT Prod. Posting Group" := GetValueAtCell(RowNo, 3);
                            GenProductPostingGroup."Auto Insert Default" := GetValueAtBool(RowNo, 4);
                            GenProductPostingGroup.Insert(true);
                        end;
                end;
            Text0007:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not VATProductPostingGroup.Get(GetValueAtCell(RowNo, 1)) then begin
                            VATProductPostingGroup.Init();
                            VATProductPostingGroup.Code := GetValueAtCell(RowNo, 1);
                            VATProductPostingGroup.Description := GetValueAtCell(RowNo, 2);
                            VATProductPostingGroup.Insert(true);
                        end;
                end;
            Text0008:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not VATBusinessPostingGroup.Get(GetValueAtCell(RowNo, 1)) then begin
                            VATBusinessPostingGroup.Init();
                            VATBusinessPostingGroup.Code := GetValueAtCell(RowNo, 1);
                            VATBusinessPostingGroup.Description := GetValueAtCell(RowNo, 2);
                            VATBusinessPostingGroup.Insert(true);
                        end;
                end;
            Text0009:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not GeneralPostingSetup.Get(GetValueAtCell(RowNo, 1), GetValueAtCell(RowNo, 2)) then begin
                            GeneralPostingSetup.Init();
                            GeneralPostingSetup."Gen. Bus. Posting Group" := GetValueAtCell(RowNo, 1);
                            GeneralPostingSetup."Gen. Prod. Posting Group" := GetValueAtCell(RowNo, 2);
                            GeneralPostingSetup."Sales Account" := GetValueAtCell(RowNo, 3);
                            GeneralPostingSetup."Sales Credit Memo Account" := GetValueAtCell(RowNo, 4);
                            GeneralPostingSetup."Sales Line Disc. Account" := GetValueAtCell(RowNo, 5);
                            GeneralPostingSetup."Sales Inv. Disc. Account" := GetValueAtCell(RowNo, 6);
                            GeneralPostingSetup."Purch. Account" := GetValueAtCell(RowNo, 13);
                            GeneralPostingSetup."Purch. Credit Memo Account" := GetValueAtCell(RowNo, 14);
                            GeneralPostingSetup."Purch. Line Disc. Account" := GetValueAtCell(RowNo, 15);
                            GeneralPostingSetup."COGS Account" := GetValueAtCell(RowNo, 22);
                            GeneralPostingSetup."Inventory Adjmt. Account" := GetValueAtCell(RowNo, 24);
                            GeneralPostingSetup."Direct Cost Applied Account" := GetValueAtCell(RowNo, 28);
                            GeneralPostingSetup."Overhead Applied Account" := GetValueAtCell(RowNo, 29);
                            GeneralPostingSetup."Purchase Variance Account" := GetValueAtCell(RowNo, 30);
                            GeneralPostingSetup.Insert(true);
                        end;
                end;
            Text0010:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not DimensionMapping.Get(Text0011, GetValueAtCell(RowNo, 2), GetValueAtCell(RowNo, 1)) then begin
                            DimensionMapping.Init();
                            DimensionMapping."Dimension Code" := Text0011;
                            DimensionMapping."Old Dimension Value Code" := GetValueAtCell(RowNo, 1);
                            DimensionMapping."New Dimension Value Code" := GetValueAtCell(RowNo, 2);
                            DimensionMapping.Insert(true);
                        end;
                end;
            Text0012:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not DimensionMapping.Get(Text0012, GetValueAtCell(RowNo, 2), GetValueAtCell(RowNo, 1)) then begin
                            DimensionMapping.Init();
                            DimensionMapping."Dimension Code" := Text0012;
                            DimensionMapping."Old Dimension Value Code" := GetValueAtCell(RowNo, 1);
                            DimensionMapping."New Dimension Value Code" := GetValueAtCell(RowNo, 2);
                            DimensionMapping.Description := GetValueAtCell(RowNo, 3);
                            DimensionMapping.Insert(true);
                        end;
                end;
            Text0018:
                begin
                    for RowNo := 3 to GetLastRow do
                        if not LocationMapping.Get(GetValueAtCell(RowNo, 3)) then begin
                            LocationMapping.Init();
                            LocationMapping."New Location Code" := GetValueAtCell(RowNo, 3);
                            LocationMapping."Old Location Code" := GetValueAtCell(RowNo, 1);
                            LocationMapping.Insert(true);
                        end;
                end;
            Text0019:
                begin
                    for RowNo := 2 to GetLastRow do
                        if not DimensionValue.Get(GetValueAtCell(RowNo, 1)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := Text0019;
                            DimensionValue.Code := GetValueAtCell(RowNo, 1);
                            DimensionValue.Name := GetValueAtCell(RowNo, 2);
                            DimensionValue.Insert(true);
                        end;
                end;
        end;

        case SheetName of
            Text0012:
                begin
                    for RowNo := 2 to GetLastRow do
                        if not DimensionValue.Get(Text0012, GetValueAtCell(RowNo, 1)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := Text0012;
                            DimensionValue.Code := GetValueAtCell(RowNo, 1);
                            DimensionValue.Name := GetValueAtCell(RowNo, 2);
                            //DimensionValue."Project is Finished" := GetValueAtBool(RowNo, 3);
                            DimensionValue."Check CF Forecast" := GetValueAtBool(RowNo, 5);
                            //DimensionValue."Post Without Forecast" := GetValueAtBool(RowNo, 6);
                            DimensionValue."Global Dimension No." := 1;
                            DimensionValue.Insert(true);
                        end;
                end;
            Text0011:
                begin
                    for RowNo := 2 to GetLastRow do
                        if not DimensionValue.Get(Text0011, GetValueAtCell(RowNo, 1)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := Text0011;
                            DimensionValue.Code := GetValueAtCell(RowNo, 1);
                            DimensionValue.Name := GetValueAtCell(RowNo, 2);
                            Evaluate(DimensionValue."Dimension Value Type", GetValueAtCell(RowNo, 3));
                            DimensionValue.Totaling := GetValueAtCell(RowNo, 4);
                            DimensionValue."Global Dimension No." := 2;
                            DimensionValue.Insert(true);
                        end;
                end;
            Text0013:
                begin
                    for RowNo := 2 to GetLastRow do
                        if not DimensionValue.Get(Text0013, GetValueAtCell(RowNo, 1)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := Text0013;
                            DimensionValue.Code := GetValueAtCell(RowNo, 1);
                            DimensionValue.Name := GetValueAtCell(RowNo, 2);
                            DimensionValue.Insert(true);
                        end;
                end;
            Text0014:
                begin
                    for RowNo := 2 to GetLastRow do
                        if not DimensionValue.Get(Text0014, GetValueAtCell(RowNo, 1)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := Text0014;
                            DimensionValue.Code := GetValueAtCell(RowNo, 1);
                            DimensionValue.Name := GetValueAtCell(RowNo, 2);
                            DimensionValue.Insert(true);
                        end;
                end;
            Text0015:
                begin
                    for RowNo := 2 to GetLastRow do
                        if not DimensionValue.Get(Text0015, GetValueAtCell(RowNo, 1)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := Text0015;
                            DimensionValue.Code := GetValueAtCell(RowNo, 1);
                            DimensionValue.Name := GetValueAtCell(RowNo, 2);
                            DimensionValue.Insert(true);
                        end;
                end;
            Text0016:
                begin
                    for RowNo := 2 to GetLastRow do
                        if not DimensionValue.Get(Text0016, GetValueAtCell(RowNo, 1)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := Text0016;
                            DimensionValue.Code := GetValueAtCell(RowNo, 1);
                            DimensionValue.Name := GetValueAtCell(RowNo, 2);
                            DimensionValue.Insert(true);
                        end;
                end;
            Text0017:
                begin
                    for RowNo := 2 to GetLastRow do
                        if not DimensionValue.Get(Text0017, GetValueAtCell(RowNo, 1)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := Text0017;
                            DimensionValue.Code := GetValueAtCell(RowNo, 1);
                            DimensionValue.Insert(true);
                        end;
                end;
        end;
    end;

    var
        ExcelBuffer: Record "Excel Buffer Mod" temporary;

    local procedure GetLastRow(): Integer

    begin
        if ExcelBuffer.FindLast() then
            exit(ExcelBuffer."Row No.");
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text

    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            exit(ExcelBuffer."Cell Value as Text");
    end;

    local procedure GetValueAtBool(RowNo: Integer; ColNo: Integer): Boolean

    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            if (ExcelBuffer."Cell Value as Text" = 'Да') then
                exit(true)
            else
                exit(false);
    end;
}