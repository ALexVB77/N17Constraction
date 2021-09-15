codeunit 70008 "IFRS Management"
{
    Permissions = TableData "G/L Entry" = rm;

    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        MappingParamsFound, CheckTransactionConsist : Boolean;
        MappingVersionID: Guid;
        CostPlaceDim, CostCodeDim : code[20];
        CheckConsistBuffer: Record "Entry No. Amount Buffer";

    local procedure GetIFRSMappingParams()
    var
        MappingVer: Record "IFRS Stat. Acc. Map. Vers.";
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        if MappingParamsFound then
            exit;

        GLSetup.Get();
        if '' in [GLSetup."IFRS Stat. Acc. Map. Code", GLSetup."IFRS Stat. Acc. Map. Vers.Code"] then
            exit;

        MappingVer.Get(GLSetup."IFRS Stat. Acc. Map. Code", GLSetup."IFRS Stat. Acc. Map. Vers.Code");
        MappingVersionID := MappingVer."Version ID";

        CheckTransactionConsist := GLSetup."Check IFRS Trans. Consistent";

        PurchSetup.Get();
        CostPlaceDim := PurchSetup."Cost Place Dimension";
        CostCodeDim := PurchSetup."Cost Code Dimension";

        MappingParamsFound := true;
    end;


    procedure FillIFRSData(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    var
        GLAccount: Record "G/L Account";
        JnlBatchName: Record "Gen. Journal Batch";
        MappingVerLine: Record "IFRS Stat. Acc. Map. Vers.Line";
        DimSetEntry: Record "Dimension Set Entry";
        IFRSPeriod: Record "IFRS Accounting Period";
        SkipEntry: Boolean;
        CostPlaceValue, CostCodeValue : code[20];
    begin
        if GLEntry."G/L Account No." = '' then
            exit;

        GetIFRSMappingParams();

        if IsNullGuid(MappingVersionID) then
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

        MappingVerLine.SetRange("Version ID", MappingVersionID);
        MappingVerLine.SetRange("Stat. Acc. Account No.", GLEntry."G/L Account No.");
        MappingVerLine.SetFilter("Cost Place Code", '%1|%2', CostPlaceValue, '');
        MappingVerLine.SetFilter("Cost Code Code", '%1|%2', CostCodeValue, '');
        if MappingVerLine.FindFirst() then
            GLEntry."IFRS Account No." := MappingVerLine."IFRS Account No.";

        if GLEntry."IFRS Account No." <> '' then begin
            GLEntry."IFRS Transfer Status" := GLEntry."IFRS Transfer Status"::Ready;
            GLEntry."IFRS Version ID" := MappingVersionID;
            GLEntry."IFRS Transfer Date" := Today;

            GLEntry."IFRS Period" := GLEntry."Posting Date";
            IFRSPeriod.SetRange("Starting Date", 0D, GLEntry."IFRS Period");
            if IFRSPeriod.FindLast() then
                if IFRSPeriod."Period Closed" then begin
                    IFRSPeriod.SetRange("Starting Date", GLEntry."IFRS Period" + 1, 99991231D);
                    if IFRSPeriod.FindFirst() then
                        GLEntry."IFRS Period" := IFRSPeriod."Starting Date";
                end;

            if CheckTransactionConsist then begin
                if not CheckConsistBuffer.Get('', GLEntry."Transaction No.") then begin
                    CheckConsistBuffer.Init();
                    CheckConsistBuffer."Business Unit Code" := '';
                    CheckConsistBuffer."Entry No." := GLEntry."Transaction No.";
                    CheckConsistBuffer.Amount := GLEntry.Amount;
                    if CheckConsistBuffer.Amount <> 0 then
                        CheckConsistBuffer.Insert();
                end else begin
                    CheckConsistBuffer.Amount += GLEntry.Amount;
                    if CheckConsistBuffer.Amount <> 0 then
                        CheckConsistBuffer.Modify()
                    else
                        CheckConsistBuffer.Delete();
                end;
            end;
        end else
            GLEntry."IFRS Transfer Status" := GLEntry."IFRS Transfer Status"::"No Rule";
    end;

    procedure CheckIFRSTransactionConsistent(var GLReg: Record "G/L Register"; var GenJnlLine: Record "Gen. Journal Line"; GlobalGLEntry: Record "G/L Entry")
    var
        CheckTransConsist: Boolean;
        VersionID: Guid;
        CostPlaceDim, CostCodeDim : code[20];
    begin
        if not CheckTransConsist then
            exit;

        CheckConsistBuffer.Reset();
        if CheckConsistBuffer.IsEmpty then
            exit;

        GlobalGLEntry.SetCurrentKey("Transaction No.");
        CheckConsistBuffer.FindSet();
        repeat
            GlobalGLEntry.SetRange("Transaction No.", CheckConsistBuffer."Entry No.");
            GlobalGLEntry.ModifyAll("IFRS Trans. Inconsistent", true);
        until CheckConsistBuffer.Next() = 0;
        GlobalGLEntry.SetRange("Transaction No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGlobalGLEntry', '', false, false)]
    local procedure OnBeforeInsertGlobalGLEntry(var GlobalGLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register")
    begin
        GenJournalLine.FillIFRSData(GlobalGLEntry, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeUpdateGLReg', '', false, false)]
    local procedure OnBeforeUpdateGLReg(IsTransactionConsistent: Boolean; var IsGLRegInserted: Boolean; var GLReg: Record "G/L Register"; var IsHandled: Boolean; var GenJnlLine: Record "Gen. Journal Line"; GlobalGLEntry: Record "G/L Entry")
    begin
        if IsTransactionConsistent then
            GenJnlLine.CheckIFRSTransactionConsistent(GLReg, GenJnlLine, GlobalGLEntry);
    end;

}