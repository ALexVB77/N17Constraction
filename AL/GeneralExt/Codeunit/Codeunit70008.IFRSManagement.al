codeunit 70008 "IFRS Management"
{
    Permissions = TableData "G/L Entry" = rm;

    trigger OnRun()
    begin
    end;

    procedure ProcessGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        GLAccount: Record "G/L Account";
        JnlBatchName: Record "Gen. Journal Batch";
        MappingVerLine: Record "IFRS Stat. Acc. Map. Vers.Line";
        DimSetEntry: Record "Dimension Set Entry";
        IFRSPeriod: Record "IFRS Accounting Period";
        SkipEntry: Boolean;
        VersionID: Guid;
        CostPlaceDim, CostCodeDim, CostPlaceValue, CostCodeValue : code[20];
    begin
        if GLEntry."G/L Account No." = '' then
            exit;

        GenJournalLine.GetIFRSMappingValues(VersionID, CostPlaceDim, CostCodeDim);
        if IsNullGuid(VersionID) then
            exit;

        GLAccount.Get(GLEntry."G/L Account No.");
        SkipEntry := GLAccount."Non-transmit";
        if (not SkipEntry) and (GLEntry."Journal Batch Name" <> '') then
            if JnlBatchName.Get(GenJournalLine."Journal Template Name", GLEntry."Journal Batch Name") then
                SkipEntry := JnlBatchName."Non-transmit";
        if SkipEntry then begin
            GLEntry."IFRS Transfer Status" := GLEntry."IFRS Transfer Status"::"Non-Transmit";
            exit;
        end;

        if (CostPlaceDim <> '') and (GLEntry."Dimension Set ID" <> 0) then
            if DimSetEntry.Get(GLEntry."Dimension Set ID", CostPlaceDim) then
                CostPlaceValue := DimSetEntry."Dimension Value Code";
        if (CostCodeDim <> '') and (GLEntry."Dimension Set ID" <> 0) then
            if DimSetEntry.Get(GLEntry."Dimension Set ID", CostCodeDim) then
                CostCodeValue := DimSetEntry."Dimension Value Code";
        if MappingVerLine.Get(VersionID, GLEntry."G/L Account No.", CostPlaceValue, CostCodeValue) then
            GLEntry."IFRS Account No." := MappingVerLine."IFRS Account No.";

        if GLEntry."IFRS Account No." <> '' then begin
            GLEntry."IFRS Transfer Status" := GLEntry."IFRS Transfer Status"::Ready;
            GLEntry."IFRS Version ID" := VersionID;
            GLEntry."IFRS Transfer Date" := Today;

            GLEntry."IFRS Period" := GLEntry."Posting Date";
            IFRSPeriod.SetRange("Starting Date", 0D, GLEntry."IFRS Period");
            if IFRSPeriod.FindLast() then
                if IFRSPeriod."Period Closed" then begin
                    IFRSPeriod.SetRange("Starting Date", GLEntry."IFRS Period" + 1, 99991231D);
                    if IFRSPeriod.FindFirst() then
                        GLEntry."IFRS Period" := IFRSPeriod."Starting Date";
                end;
        end else
            GLEntry."IFRS Transfer Status" := GLEntry."IFRS Transfer Status"::"No Rule";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeFinishPosting', '', false, false)]
    local procedure OnBeforeFinishPosting(var GenJournalLine: Record "Gen. Journal Line"; var TempGLEntryBuf: Record "G/L Entry" temporary)
    begin
        GenJournalLine.SetIFRSMappingValues();
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGlobalGLEntry', '', false, false)]
    local procedure OnBeforeInsertGlobalGLEntry(var GlobalGLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register")
    begin
        ProcessGLEntry(GlobalGLEntry, GenJournalLine);
    end;

}