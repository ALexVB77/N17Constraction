page 70037 "Vendor Agreement Budget"
{
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    SourceTable = "Projects Budget Entry";
    DelayedInsert = true;
    PopulateAllFields = false;
    PageType = ListPart;
    Caption = 'Forecast List';


    layout
    {
        area(content)
        {
            group(Info)
            {
                ShowCaption = false;
                field(GetAmount1_; GetAmount1)
                {
                    Caption = 'Amount';
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Rest; vAgreement."Agreement Amount" - GetAmount1)
                {
                    Caption = 'Rest';
                    Editable = false;
                    ApplicationArea = All;
                }
            }
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field(Close; Rec.Close)
                {
                    Editable = CloseEditable;
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        US: Record "User Setup";
                    begin
                        US.Get(UserId);
                        if not US."Administrator PRJ" then Rec.Close := not Rec.Close;
                    end;
                }

                field(Date; Rec.Date)
                {
                    NotBlank = true;
                    Editable = DateEditable;
                    ApplicationArea = All;
                }

                field("Date Plan"; Rec."Date Plan")
                {
                    Editable = false;
                    ApplicationArea = All;
                }

                field("Building Turn"; Rec."Building Turn")
                {
                    Editable = false;
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        ProjectsLineDimension: record "Projects Line Dimension";
                        BuildingTurn: record "Building turn";
                    begin
                        BuildingTurn.SetRange(Code, Rec."Building Turn All");
                        if BuildingTurn.FindFirst() then
                            Rec."Shortcut Dimension 1 Code" := BuildingTurn."Turn Dimension Code";

                        if Rec."Shortcut Dimension 1 Code" <> '' then begin
                            if BuildingTurn.FindFirst() then begin
                                Rec.Validate("Project Turn Code", BuildingTurn.Code);

                                lrVersion.SetRange("Project Code", Buildingturn."Building project Code");
                                lrVersion.SetRange("Fixed Version", true);

                                if lrVersion.FindFirst() then begin
                                    Rec."Project Code" := lrVersion."Project Code";
                                    Rec."Version Code" := lrVersion."Version Code";

                                    if Rec."Shortcut Dimension 2 Code" <> '' then begin
                                        ProjectsLineDimension.SetRange("Project No.", lrVersion."Project Code");
                                        ProjectsLineDimension.SetRange("Project Version No.", lrVersion."Version Code");
                                        ProjectsLineDimension.SetRange("Dimension Code", 'CC');
                                        ProjectsLineDimension.SetRange("Dimension Value Code", Rec."Shortcut Dimension 2 Code");
                                        ProjectsLineDimension.SetRange("Detailed Line No.", 0);

                                        if ProjectsLineDimension.FindFirst() then
                                            Rec."Line No." := ProjectsLineDimension."Project Line No.";
                                    end;
                                end;

                            end else begin
                                Rec."Project Code" := '';
                                Rec."Version Code" := '';
                            end;
                        end;
                    end;
                }

                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                }

                field("Cost Code"; Rec."Cost Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                }

                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                }

                field("Without VAT"; Rec."Without VAT")
                {
                    NotBlank = true;
                    Editable = WithoutVATEditable;
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        lrProjectsBudgetEntry: Record "Projects Budget Entry";
                        lfCFCorrection: Page "Forecast List Analisys Correct";
                    begin
                        if Rec."Entry No." = 0 then
                            Rec."Entry No." := GetNextEntryNo;
                        Rec."Including VAT" := FALSE;

                        Delta := Rec.Amount;
                        if Delta > Round(vAgreement."Agreement Amount" - GetAmount(Rec."Agreement No."), 0.01) then begin
                            Message(TEXT001);
                            Rec.Validate("Without VAT", 0);
                        end;

                        CurrPage.SaveRecord();

                        if Rec."Without VAT" <> 0 then begin
                            if Rec."Building Turn" = '' then begin
                                Message(TEXT0004);
                                Rec."Without VAT" := 0;
                                exit;
                            END;

                            if Rec."Cost Code" = '' then begin
                                Message(TEXT0005);
                                Rec."Without VAT" := 0;
                                exit;
                            end;
                        end;

                        Commit();

                        if Rec."Without VAT" <> 0 then begin
                            Message(TEXT0008);
                            Clear(lfCFCorrection);
                            lrProjectsBudgetEntry.SetCurrentKey(Date);
                            lrProjectsBudgetEntry.SetRange("Project Code", Rec."Project Code");
                            lrProjectsBudgetEntry.SetRange("Project Turn Code", Rec."Project Turn Code");
                            lrProjectsBudgetEntry.SetRange("Cost Code", Rec."Cost Code");
                            lrProjectsBudgetEntry.SetFilter("Contragent No.", '%1|%2', '', Rec."Contragent No.");
                            lrProjectsBudgetEntry.SetRange("Agreement No.", '');
                            lrProjectsBudgetEntry.SetRange(NotVisible, false);
                            lrProjectsBudgetEntry.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
                            if lrProjectsBudgetEntry.FINDFIRST then;
                            lfCFCorrection.SetTableView(lrProjectsBudgetEntry);
                            lfCFCorrection.SetData(Rec);
                            if (Rec."Without VAT" - lfCFCorrection.GetSum) <> 0 then
                                lfCFCorrection.LookupMode := true
                            else
                                lfCFCorrection.LookupMode := false;
                            if lfCFCorrection.RunModal() = Action::LookupOK then begin
                                SetSum;
                                Rec."Transaction Type" := CurrTrType;
                            end else begin
                                ClearSum;
                                Rec.Validate(Rec."Without VAT", 0);
                                Message(TEXT0009);
                            end;
                        end;
                    end;
                }

                field("Without VAT (LCY)"; Rec."Without VAT (LCY)")
                {
                    ApplicationArea = All;
                }

                field(Curency; Rec.Curency)
                {
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    NotBlank = true;
                    Editable = DescriptionEditable;
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        lrPL: record "Purchase Line";
                        lrPH: record "Purchase Header";
                    begin
                        if Rec.Close then begin
                            lrPL.SetCurrentKey("Forecast Entry");
                            lrPL.SetRange("Forecast Entry", Rec."Entry No.");
                            if lrPL.FindFirst() then begin
                                lrPH.SetRange("Document Type", lrPL."Document Type");
                                lrPH.SetRange("No.", lrPL."Document No.");
                                if lrPH.FindFirst() then begin
                                    Page.Run(70000, lrPH);
                                end;
                            end;
                        end;
                    end;
                }

                field("Description 2"; Rec."Description 2")
                {
                    Editable = Description2Editable;
                    ApplicationArea = All;
                }

                field("Invoice No"; Rec.GetInvoiceNo)
                {
                    Caption = 'Invoice No';
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Invoice Date"; Rec.GetInvoiceDate)
                {
                    Caption = 'Invoice Date';
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Payment Doc. No."; Rec."Payment Doc. No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
            }
        }
    }


    actions
    {
        area(Processing)
        {
            action(UntieFromAgreement)
            {
                Caption = 'Untie from Agreement';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    if Rec.Close then exit;
                    if CheckCFIW then begin
                        if Confirm(TEXT0010) then begin
                            Rec.Validate("Contragent No.", '');
                            Rec.Validate("Agreement No.", '');
                            Rec.Modify();
                        end;
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        IF vAgreement.GET(Rec."Contragent No.", Rec."Agreement No.") THEN;
    end;

    trigger OnAfterGetRecord()
    var
        ProjectsLineDimension: record "Projects Line Dimension";
        BuildingTurn: record "Building turn";
        ProjectsStructureLines: record "Projects Structure Lines";
    begin
        if (Rec."Building Turn All" = '') and (Rec."Shortcut Dimension 1 Code" <> '') then begin
            BuildingTurn.SetRange("Turn Dimension Code", Rec."Shortcut Dimension 1 Code");
            if BuildingTurn.FindFirst() then
                Rec."Building Turn All" := BuildingTurn.Code;
        end;

        if Rec."Cost Code" = '' then begin
            if Rec."Line No." <> 0 then begin
                ProjectsStructureLines.SetRange("Project Code", Rec."Project Code");
                ProjectsStructureLines.SetRange(Version, Rec."Version Code");
                ProjectsStructureLines.SetRange("Line No.", Rec."Line No.");
                if ProjectsStructureLines.FindFirst() then
                    Rec."Cost Code" := ProjectsStructureLines.Code;
            end;
        end;
        if vAgreement.Get(Rec."Contragent No.", Rec."Agreement No.") then;

        Rec.Curency := vAgreement."Currency Code";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if vAgreement.Get(Rec."Contragent No.", Rec."Agreement No.") then;

        if Rec.Close then begin
            DateEditable := false;
            DescriptionEditable := false;
            Description2Editable := false;
            WithoutVATEditable := false;
        end else begin
            CloseEditable := true;
            DateEditable := true;
            DescriptionEditable := true;
            Description2Editable := true;

            if Rec."Without VAT" <> 0 then
                WithoutVATEditable := false
            else
                WithoutVATEditable := true;
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        ProjectsLineDimension: record "Projects Line Dimension";
        Buildingturn: record "Building turn";
        lrVendor: record Vendor;
        lrVendorAgree: record "Vendor Agreement";
    begin
        Rec.Curency := vAgreement."Currency Code";

        Rec."Work Version" := true;

        Rec."Including VAT" := false;
        Rec."Not Run OnInsert" := true;
        Rec."Contragent No." := gVendor;
        Rec."Agreement No." := gAgr;

        if lrVendor.GET(gVendor) then
            Rec."Contragent Name" := lrVendor.Name;

        if lrVendorAgree.GET(gVendor, gAgr) then
            Rec."External Agreement No." := lrVendorAgree."External Agreement No.";

        if gDim1 <> '' then
            Rec."Shortcut Dimension 1 Code" := gDim1;

        if gDim2 <> '' then
            Rec."Shortcut Dimension 2 Code" := gDim2;

        BuildingTurn.SetRange("Turn Dimension Code", Rec."Shortcut Dimension 1 Code");

        if Rec."Shortcut Dimension 1 Code" <> '' then begin
            if BuildingTurn.FindFirst() then begin
                Rec.Validate("Project Turn Code", BuildingTurn.Code);
                Rec.Validate("Building Turn", Buildingturn.Code);
                Rec."Project Code" := BuildingTurn."Building project Code";
                Rec."Version Code" := Rec.GetDefVersion1(Rec."Project Code");
            end;
        end;

        if DimV.Get('CC', Rec."Shortcut Dimension 2 Code") THEN
            Rec.Description := DimV.Name;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."Including VAT" := FALSE;
        Rec."Not Run OnInsert" := TRUE;

        IF Rec.Close THEN BEGIN
            US.Get(UserId);
            IF NOT US."Administrator PRJ" THEN
                Error(TEXT0014);
        END;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        IF Rec."Payment Doc. No." <> '' THEN
            Error(TEXT002);

        US.GET(USERID);

        IF NOT US."Administrator PRJ" THEN
            Error(TEXT002);
    end;

    var
        CloseEditable: Boolean;
        DateEditable: Boolean;
        DescriptionEditable: Boolean;
        Description2Editable: Boolean;
        WithoutVATEditable: Boolean;
        Agr: record "Vendor Agreement";
        gVendor: code[20];
        gAgr: code[20];
        gDim1: code[20];
        gDim2: code[20];
        lrVersion: record "Project Version";
        DimV: record "Dimension Value";
        CurrTrType: code[20];
        vAgreement: record "Vendor Agreement";
        Delta: decimal;
        US: record "User Setup";
        TEXT001: Label 'The amount of the Balance under the Agreement has been exceeded!';
        TEXT002: Label 'Can not delete entry';
        TEXT0004: Label 'You must specify the Project Code!';
        TEXT0005: Label 'You must ask a Budget Item!';
        TEXT0008: Label 'You must select the Cash Flow records from which you want to write off this amount.';
        TEXT0009: Label 'Canceled by the user.';
        TEXT0010: Label 'Unlink the payment from the supplier and the contract (transfer to level 1)?';
        TEXT0012: Label 'The operation is tied to the IW document \ Amount available for transfer to the 1st level';
        TEXT0013: Label 'The operation is tied to the IW document \ Amount available for transfer to the 1st level';
        TEXT0014: Label 'You are not allowed to copy the actual transactions.';


    local procedure GetNextEntryNo(): Integer
    var
        GLBudgetEntry: record "Projects Budget Entry";
    begin
        GLBudgetEntry.SETCURRENTKEY("Entry No.");
        IF GLBudgetEntry.FIND('+') THEN
            EXIT(GLBudgetEntry."Entry No." + 1)
        ELSE
            EXIT(1);
    end;

    procedure SetData(pVendor: code[20]; pAgr: code[20]; Dim1: code[20]; Dim2: code[20])
    begin
        gVendor := pVendor;
        gAgr := pAgr;
        gDim1 := Dim1;
        gDim2 := Dim2;
    end;

    procedure GetAmount(vAgrNo: code[20]) Ret: Decimal
    var
        VendorAgreementDetails: record "Projects Budget Entry";
    begin
        VendorAgreementDetails.SETRANGE("Contragent No.", Rec."Contragent No.");
        VendorAgreementDetails.SETRANGE("Agreement No.", vAgrNo);
        VendorAgreementDetails.SETFILTER("Entry No.", '<>%1', Rec."Entry No.");

        IF VendorAgreementDetails.FINDSET THEN BEGIN
            REPEAT
                Ret := Ret + VendorAgreementDetails."Without VAT";
            UNTIL VendorAgreementDetails.NEXT = 0;
        END;
    end;

    procedure GetAmount1() Ret: Decimal
    var
        VendorAgreementDetails: record "Projects Budget Entry";
    begin
        VendorAgreementDetails.COPY(Rec);
        IF VendorAgreementDetails.FINDSET THEN BEGIN
            REPEAT
                IF vAgreement."Currency Code" <> '' THEN
                    Ret := Ret + VendorAgreementDetails."Without VAT"
                ELSE
                    Ret := Ret + VendorAgreementDetails."Without VAT (LCY)"
            UNTIL VendorAgreementDetails.NEXT = 0;
        END;
    end;

    procedure ClearSum()
    var
        lrProjectsBudgetEntry: record "Projects Budget Entry";
    begin
        lrProjectsBudgetEntry.SETRANGE("Project Code", "Project Code");
        lrProjectsBudgetEntry.SETRANGE("Project Turn Code", "Project Turn Code");
        lrProjectsBudgetEntry.SETRANGE("Cost Code", "Cost Code");
        lrProjectsBudgetEntry.SETFILTER("Contragent No.", '%1|%2', '', "Contragent No.");
        lrProjectsBudgetEntry.SETRANGE("Agreement No.", '');
        lrProjectsBudgetEntry.SETFILTER("Without VAT", '<>%1', 0);
        lrProjectsBudgetEntry.SETFILTER("Entry No.", '<>%1', "Entry No.");
        IF lrProjectsBudgetEntry.FINDSET THEN BEGIN
            REPEAT
                lrProjectsBudgetEntry."Write Off Amount" := 0;
                lrProjectsBudgetEntry.MODIFY;
            UNTIL lrProjectsBudgetEntry.NEXT = 0;
        END;
    end;

    procedure CheckCFIW() Ret: Boolean
    var
        lrPL: record "Purchase Line";
        vAmount: decimal;
        lrProjectsBudgetEntry: record "Projects Budget Entry";
    begin
        vAmount := 0;
        Ret := TRUE;
        lrPL.SETCURRENTKEY("Forecast Entry");
        lrPL.SETRANGE("Forecast Entry", "Entry No.");
        IF lrPL.FINDSET THEN BEGIN
            REPEAT
                vAmount := vAmount + GetLineAmount(lrPL);

            UNTIL lrPL.NEXT = 0;

            IF vAmount <> 0 THEN BEGIN
                Ret := FALSE;
                IF "Without VAT" = vAmount THEN BEGIN
                    MESSAGE(STRSUBSTNO(TEXT0013, ("Without VAT" - vAmount)));
                END
                ELSE BEGIN
                    IF CONFIRM(STRSUBSTNO(TEXT0012, ("Without VAT" - vAmount))) THEN BEGIN
                        lrProjectsBudgetEntry.INIT;
                        lrProjectsBudgetEntry.TRANSFERFIELDS(Rec);
                        lrProjectsBudgetEntry.VALIDATE("Without VAT", ("Without VAT" - vAmount));
                        lrProjectsBudgetEntry."Entry No." := 0;
                        lrProjectsBudgetEntry.VALIDATE("Contragent No.", '');
                        lrProjectsBudgetEntry.VALIDATE("Agreement No.", '');
                        lrProjectsBudgetEntry.INSERT(TRUE);
                        VALIDATE("Without VAT", vAmount);
                        MODIFY;
                    END;
                END;
            END;
        END;
    end;

    procedure GetLineAmount(pPH: record "Purchase Line") Ret: Decimal
    var
        lrPL: record "Purchase Line";
        Amount: decimal;
        AmountWOVAT: decimal;
        AmountVAT: decimal;
        AmountWVAT: decimal;
        lrPH: record "Purchase Header";
    begin
        AmountWOVAT := 0;
        AmountVAT := 0;
        AmountWVAT := 0;

        lrPH.GET(pPH."Document Type", pPH."Document No.");
        lrPL.SETRANGE("Document Type", pPH."Document Type");
        lrPL.SETRANGE("Document No.", pPH."Document No.");
        lrPL.SETRANGE("Line No.", pPH."Line No.");

        IF lrPL.FIND('-') THEN BEGIN
            REPEAT
                Amount := lrPL."Line Amount";
                IF lrPH."Prices Including VAT" THEN BEGIN
                    IF lrPL."VAT %" <> 0 THEN BEGIN
                        AmountVAT := AmountVAT + ROUND(Amount - (Amount / ((100 + lrPL."VAT %") / 100)), 0.01);
                        AmountWOVAT := AmountWOVAT + (Amount - ROUND(Amount - (Amount / ((100 + lrPL."VAT %") / 100)), 0.01));
                        AmountWVAT := AmountWVAT + Amount;
                    END
                    ELSE BEGIN
                        AmountWOVAT := AmountWOVAT + Amount;
                        AmountWVAT := AmountWVAT + Amount;
                    END;
                END
                ELSE BEGIN
                    IF lrPL."VAT %" <> 0 THEN BEGIN
                        AmountVAT := AmountVAT + (ROUND(Amount * ((100 + lrPL."VAT %") / 100), 0.01) - Amount);
                        AmountWOVAT := AmountWOVAT + Amount;
                        AmountWVAT := AmountWVAT + (Amount + (ROUND(Amount * ((100 + lrPL."VAT %") / 100), 0.01) - Amount));
                    END
                    ELSE BEGIN
                        AmountWOVAT := AmountWOVAT + Amount;
                        AmountWVAT := AmountWVAT + Amount;
                    END;
                END;
            UNTIL lrPL.NEXT = 0;
        END;
        Ret := AmountWVAT;
    end;

    procedure SetSum()
    var
        lrProjectsBudgetEntry: record "Projects Budget Entry";
        MaxAmount: decimal;
    begin
        lrProjectsBudgetEntry.SETRANGE("Project Code", Rec."Project Code");
        lrProjectsBudgetEntry.SETRANGE("Project Turn Code", Rec."Project Turn Code");
        lrProjectsBudgetEntry.SETRANGE("Cost Code", Rec."Cost Code");
        lrProjectsBudgetEntry.SETFILTER("Contragent No.", '%1|%2', '', Rec."Contragent No.");
        lrProjectsBudgetEntry.SETRANGE("Agreement No.", '');
        lrProjectsBudgetEntry.SETFILTER("Without VAT", '<>%1', 0);
        lrProjectsBudgetEntry.SETFILTER("Entry No.", '<>%1', Rec."Entry No.");
        if lrProjectsBudgetEntry.FINDSET then begin
            repeat
                lrProjectsBudgetEntry.Validate("Without VAT", lrProjectsBudgetEntry."Without VAT" - lrProjectsBudgetEntry."Write Off Amount");
                if MaxAmount < lrProjectsBudgetEntry."Write Off Amount" then begin
                    MaxAmount := lrProjectsBudgetEntry."Write Off Amount";
                    CurrTrType := lrProjectsBudgetEntry."Transaction Type";
                end;

                lrProjectsBudgetEntry."Write Off Amount" := 0;
                if lrProjectsBudgetEntry."Without VAT" = 0 then
                    lrProjectsBudgetEntry.NotVisible := true;
                lrProjectsBudgetEntry.Modify();
            until lrProjectsBudgetEntry.Next() = 0;
        end;
    end;
}

