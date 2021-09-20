codeunit 50016 "VAT Settlement Mgt (Ext)"
{
    Permissions = TableData "VAT Entry" = imd;

    trigger OnRun()
    begin
    end;

    var
        VATDocEntryBuffer: Record "VAT Document Entry Buffer";
        DimMgt: Codeunit DimensionManagement;
        RecalculationDate: Date;

    procedure Generate(var TempVATDocBuf: Record "VAT Document Entry Buffer" temporary; Type: Option ,Purchase,Sale,"Fixed Asset","Future Expense")
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        VATEntry: Record "VAT Entry";
        Cust: Record Customer;
        Vend: Record Vendor;
        VATPostingSetup: Record "VAT Posting Setup";
        VATSettleMgt: Codeunit "VAT Settlement Management";
        Window: Dialog;
        VATCount: Integer;
        I: Integer;
        CVEntryNo: Integer;
        DimSetID: Integer;
        PostingDate: Date;
        CVEntryType: Option " ",Purchase,Sale;
    begin
        with TempVATDocBuf do begin
            VATDocEntryBuffer.CopyFilters(TempVATDocBuf);
            DeleteAll();
            Window.Open('@1@@@@@@@@@@@@@@@');

            VATEntry.Reset();
            case Type of
                Type::Purchase:
                    VATEntry.SetRange(Type, Type::Purchase);
                Type::Sale:
                    VATEntry.SetRange(Type, Type::Sale);
                Type::"Fixed Asset":
                    VATEntry.SetRange("VAT Settlement Type", VATEntry."VAT Settlement Type"::"by Act");
                Type::"Future Expense":
                    VATEntry.SetRange("VAT Settlement Type", VATEntry."VAT Settlement Type"::"Future Expenses");
            end;
            if Type in [Type::"Fixed Asset", Type::"Future Expense"] then
                VATEntry.SetRange("Object Type", VATEntry."Object Type"::"Fixed Asset")
            else
                VATEntry.SetFilter("Object Type", '<>%1', VATEntry."Object Type"::"Fixed Asset");
            VATEntry.SetRange(Reversed, false);
            VATEntry.SetRange("Unrealized VAT Entry No.", 0);
            VATEntry.SetFilter("Posting Date", GetFilter("Date Filter"));
            VATEntry.SetFilter("VAT Bus. Posting Group", GetFilter("VAT Bus. Posting Group Filter"));
            VATEntry.SetFilter("VAT Prod. Posting Group", GetFilter("VAT Prod. Posting Group Filter"));
            VATEntry.SetRange(Base, 0);
            VATEntry.SetFilter("Remaining Unrealized Amount", '<>%1', 0);
            VATEntry.SetRange("Manual VAT Settlement", true);
            I := 0;
            VATCount := VATEntry.Count();
            if VATEntry.FindSet then
                repeat
                    I += 1;
                    Window.Update(1, Round(I / VATCount * 10000, 1));
                    PostingDate := GetRangeMax("Date Filter");
                    if VATSettleMgt.CheckFixedAsset(VATEntry, PostingDate, Type) then
                        if VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") then
                            // IF VATPostingSetup."Manual VAT Settlement" THEN
                            if VATEntry.FindCVEntry(CVEntryType, CVEntryNo) then begin
                                case CVEntryType of
                                    CVEntryType::Purchase:
                                        begin
                                            VendLedgEntry.Get(CVEntryNo);
                                            VendLedgEntry.CalcFields("Amount (LCY)", "Remaining Amt. (LCY)");
                                            TransferFields(VendLedgEntry);
                                            "Amount (LCY)" := VendLedgEntry."Amount (LCY)";
                                            "Remaining Amt. (LCY)" := VendLedgEntry."Remaining Amt. (LCY)";
                                            "Table ID" := DATABASE::"Vendor Ledger Entry";
                                            Vend.Get(VendLedgEntry."Vendor No.");
                                            "CV Name" := Vend.Name;
                                            DimSetID := VendLedgEntry."Dimension Set ID";
                                        end;
                                    CVEntryType::Sale:
                                        begin
                                            CustLedgEntry.Get(CVEntryNo);
                                            CustLedgEntry.CalcFields("Amount (LCY)", "Remaining Amt. (LCY)");
                                            TransferFields(CustLedgEntry);
                                            "Amount (LCY)" := CustLedgEntry."Amount (LCY)";
                                            "Remaining Amt. (LCY)" := CustLedgEntry."Remaining Amt. (LCY)";
                                            "Table ID" := DATABASE::"Cust. Ledger Entry";
                                            Cust.Get(CustLedgEntry."Customer No.");
                                            "CV Name" := Cust.Name;
                                            DimSetID := CustLedgEntry."Dimension Set ID";
                                        end;
                                end;
                                "Entry Type" := CVEntryType;
                                "Document Date" := "Posting Date";
                                if PostingDate > "Posting Date" then
                                    "Posting Date" := PostingDate;
                                CreateAllocation(VATEntry."Entry No.");
                                RecalculateAllocation(VATEntry."Entry No.", "Posting Date");
                                MergeEntryDimSetIDWithVATAllocationDim(VATEntry."Entry No.", DimSetID);
                                CalcFields("VAT Amount To Allocate");
                                "Allocated VAT Amount" := "VAT Amount To Allocate";
                                if Insert then
                                    VATSettleMgt.FillCVEntryNo("Transaction No.", "Entry No.");
                            end;
                until VATEntry.Next = 0;
            Window.Close;
        end;
    end;

    procedure CreateAllocation(VATEntryNo: Integer)
    var
        VATAllocLine: Record "VAT Allocation Line";
    begin
        VATAllocLine.SetRange("VAT Entry No.", VATEntryNo);
        if VATAllocLine.IsEmpty then
            if not ApplyDefaultAllocation(VATEntryNo) then
                InsertInitEntry(VATEntryNo);
    end;

    procedure InsertInitEntry(VATEntryNo: Integer)
    var
        VATAllocLine: Record "VAT Allocation Line";
        VATEntry: Record "VAT Entry";
        Mode: Option Any,Depreciation,General;
    begin
        VATEntry.Get(VATEntryNo);
        with VATAllocLine do begin
            SetFilter("Posting Date Filter", VATDocEntryBuffer.GetFilter("Date Filter"));
            Init;
            "Line No." := 10000;
            Validate("VAT Entry No.", VATEntryNo);
            "Allocation %" := 100;
            Base := Base::Remaining;
            if VATEntry."Object Type" = VATEntry."Object Type"::"Fixed Asset" then begin
                "VAT Settlement Type" := VATEntry."VAT Settlement Type";
                if "VAT Settlement Type" = "VAT Settlement Type"::"Future Expenses" then begin
                    GetFPEMode(VATEntryNo, Mode);
                    if Mode <> Mode::General then
                        Base := Base::Depreciation;
                end;
            end;
            Validate(Base);
            Insert;
        end;
    end;

    procedure GetFPEMode(UnrealVATEntryNo: Integer; var Mode: Option Any,Depreciation,General)
    var
        VATEntry: Record "VAT Entry";
    begin
        with VATEntry do begin
            SetCurrentKey("Unrealized VAT Entry No.");
            SetRange("Unrealized VAT Entry No.", UnrealVATEntryNo);
            SetRange(Reversed, false);
            if FindLast then begin
                if "FA Ledger Entry No." = 0 then
                    Mode := Mode::General
                else
                    Mode := Mode::Depreciation;
            end else
                Mode := Mode::Any;
        end;
    end;

    procedure ApplyDefaultAllocation(VATEntryNo: Integer): Boolean
    var
        VATEntry: Record "VAT Entry";
        DefaultVATAlloc: Record "Default VAT Allocation Line";
    begin
        VATEntry.Get(VATEntryNo);
        DefaultVATAlloc.SetRange("VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        DefaultVATAlloc.SetRange("VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        if DefaultVATAlloc.IsEmpty then
            exit(false);

        InsertVATAlloc(DefaultVATAlloc, VATEntry);
        exit(true);
    end;

    procedure InsertVATAlloc(var DefaultVATAlloc: Record "Default VAT Allocation Line"; VATEntry: Record "VAT Entry")
    var
        VATAllocLine: Record "VAT Allocation Line";
        LineNo: Integer;
    begin
        with VATAllocLine do begin
            SetFilter("Posting Date Filter", VATDocEntryBuffer.GetFilter("Date Filter"));
            LineNo := 0;
            DefaultVATAlloc.FindSet;
            repeat
                LineNo := LineNo + 10000;
                Init;
                "Line No." := LineNo;
                Validate("VAT Entry No.", VATEntry."Entry No.");
                "CV Ledger Entry No." := VATEntry."CV Ledg. Entry No.";
                Type := DefaultVATAlloc.Type;
                "Account No." := DefaultVATAlloc."Account No.";
                if "Account No." = '' then
                    Validate(Type);
                if DefaultVATAlloc.Description <> '' then
                    Description := DefaultVATAlloc.Description;
                "Recurring Frequency" := DefaultVATAlloc."Recurring Frequency";
                "Shortcut Dimension 1 Code" := DefaultVATAlloc."Shortcut Dimension 1 Code";
                "Shortcut Dimension 2 Code" := DefaultVATAlloc."Shortcut Dimension 2 Code";
                "Dimension Set ID" := DefaultVATAlloc."Dimension Set ID";
                "Allocation %" := DefaultVATAlloc."Allocation %";
                Amount := DefaultVATAlloc.Amount;
                Validate(Base, DefaultVATAlloc.Base);
                if VATEntry."Object Type" = VATEntry."Object Type"::"Fixed Asset" then
                    "VAT Settlement Type" := VATEntry."VAT Settlement Type";
                Insert;

            until DefaultVATAlloc.Next = 0;
        end;
    end;

    procedure RecalculateAllocation(VATEntryNo: Integer; var PostingDate: Date)
    var
        VATAllocLine: Record "VAT Allocation Line";
        MinDateFormula: DateFormula;
        TotalAmount: Decimal;
        ControlTotal: Boolean;
        TotalAmountRnded: Decimal;
    begin
        VATAllocLine.SetFilter("Posting Date Filter", VATDocEntryBuffer.GetFilter("Date Filter"));
        VATAllocLine.SetRange("VAT Entry No.", VATEntryNo);
        if VATAllocLine.FindFirst then begin
            VATAllocLine.SetFilter(Base, '<>%1', VATAllocLine.Base);
            ControlTotal := VATAllocLine.IsEmpty;
            VATAllocLine.SetRange(Base);
        end;
        if VATAllocLine.FindSet(true) then
            repeat
                VATAllocLine.SetTotalCheck(false);
                VATAllocLine.Validate(Base);
                if ControlTotal then begin
                    if VATAllocLine."Allocation %" <> 0 then
                        TotalAmount := TotalAmount + VATAllocLine."VAT Amount" * VATAllocLine."Allocation %" / 100
                    else begin
                        if Abs(VATAllocLine.Amount) > Abs(VATAllocLine."VAT Amount") then
                            VATAllocLine.Amount := VATAllocLine."VAT Amount";
                        TotalAmount := TotalAmount + VATAllocLine.Amount;
                    end;
                    VATAllocLine.Amount := Round(TotalAmount) - TotalAmountRnded;
                    TotalAmountRnded := TotalAmountRnded + VATAllocLine.Amount;
                end;
                VATAllocLine.Modify();
                SetDateFormula(MinDateFormula, VATAllocLine."Recurring Frequency");
            until VATAllocLine.Next = 0;
        if Format(MinDateFormula) <> '' then
            GetLastRealVATEntryDate(PostingDate, VATEntryNo, MinDateFormula);
    end;

    procedure SetDateFormula(var MinDateFormula: DateFormula; DateFormula: DateFormula)
    var
        ClearDateFormula: DateFormula;
    begin
        Clear(ClearDateFormula);
        if DateFormula <> ClearDateFormula then begin
            if (MinDateFormula = ClearDateFormula) or
               (CalcDate(MinDateFormula, WorkDate) > CalcDate(DateFormula, WorkDate))
            then
                MinDateFormula := DateFormula;
        end;
    end;

    procedure GetLastRealVATEntryDate(var LastPostingDate: Date; UnrealVATEntryNo: Integer; DateFormula: DateFormula)
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetCurrentKey("Unrealized VAT Entry No.");
        VATEntry.SetRange("Unrealized VAT Entry No.", UnrealVATEntryNo);
        VATEntry.SetRange(Reversed, false);
        if VATEntry.FindLast then
            LastPostingDate := CalcDate(DateFormula, VATEntry."Posting Date");
    end;

    local procedure MergeEntryDimSetIDWithVATAllocationDim(VATEntryNo: Integer; DimSetID: Integer)
    var
        VATAllocationLine: Record "VAT Allocation Line";
    begin
        with VATAllocationLine do begin
            SetRange("VAT Entry No.", VATEntryNo);
            if FindSet(true) then
                repeat
                    "Dimension Set ID" := GetCombinedDimSetID(
                        "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code",
                        "Dimension Set ID", DimSetID, GetVATEntryDimSetID(VATEntryNo));
                    Modify(true);
                until Next = 0;
        end;
    end;

    local procedure GetCombinedDimSetID(var ShortcutDimensionCode1: Code[20]; var ShortcutDimensionCode2: Code[20]; DimSetID1: Integer; DimSetID2: Integer; DimSetID3: Integer): Integer
    var
        DimensionSetIDArr: array[10] of Integer;
    begin
        DimensionSetIDArr[1] := DimSetID1;
        DimensionSetIDArr[2] := DimSetID2;
        DimensionSetIDArr[3] := DimSetID3;
        exit(DimMgt.GetCombinedDimensionSetID(DimensionSetIDArr, ShortcutDimensionCode1, ShortcutDimensionCode2));
    end;

    local procedure GetVATEntryDimSetID(VATEntryNo: Integer): Integer
    var
        GLEntryVATEntryLink: Record "G/L Entry - VAT Entry Link";
        GLEntry: Record "G/L Entry";
    begin
        GLEntryVATEntryLink.SetRange("VAT Entry No.", VATEntryNo);
        if GLEntryVATEntryLink.FindFirst then begin
            GLEntry.Get(GLEntryVATEntryLink."G/L Entry No.");
            exit(GLEntry."Dimension Set ID");
        end;
        exit(0);
    end;
}