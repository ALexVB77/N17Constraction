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
        SkipEntry: Boolean;
        VersionID: Guid;
        CostPlace, CostCode : code[20];
    begin
        if GLEntry."G/L Account No." = '' then
            exit;

        // if IsNullGuid(GenJournalLine."IFRS Mapping Version ID") then
        //     exit;
        GLAccount.Get(GLEntry."G/L Account No.");
        SkipEntry := GLAccount."Non-transmit";
        if (not SkipEntry) and (GLEntry."Journal Batch Name" <> '') then
            if JnlBatchName.Get(GenJournalLine."Journal Template Name", GLEntry."Journal Batch Name") then
                SkipEntry := JnlBatchName."Non-transmit";
        if SkipEntry then begin
            GLEntry."IFRS Transfer Status" := GLEntry."IFRS Transfer Status"::"Non-Transmit";
            exit;
        end;
        if GLEntry."Dimension Set ID" <> 0 then begin
            //DimSetEntry
        end;


        //MappingVerLine.SetRange("Version ID", GenJournalLine."IFRS Mapping Version ID");

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