codeunit 70101 "Additional Management BS"
{
    // Event Subscribers >>

    // TABLES

    // t 81 >>
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetCustomerAccount', '', false, false)]
    local procedure OnAfterAccountNoOnValidateGetCustomerAccount(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer; CallingFieldNo: Integer);
    var
        compInfo: Record "Company Information";
    begin
        compInfo.get();
        GenJournalLine."Payer KPP" := compInfo."KPP Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetVendorAccount', '', false, false)]
    local procedure OnAfterAccountNoOnValidateGetVendorAccount(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor; CallingFieldNo: Integer);
    var
        compInfo: Record "Company Information";
    begin
        compInfo.get();
        GenJournalLine."Payer KPP" := compInfo."KPP Code";
    end;


    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnModifyOnBeforeTestCheckPrinted', '', false, false)]
    local procedure OnModifyOnBeforeTestCheckPrinted(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean);
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyT81(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    begin
        if (RunTrigger) then begin
            if (Rec."Data Exch. Entry No." <> 0) and (Rec."Export Status" <> Rec."Export Status"::Exported) then begin
                Rec.validate("Export Status", Rec."Export Status"::Exported);
                Rec.modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnExportPaymentFileOnBeforeRunExport', '', false, false)]
    local procedure OnExportPaymentFileOnBeforeRunExport(var GenJournalLine: Record "Gen. Journal Line")
    var
        gjl: record "Gen. Journal Line";
        locText001: label 'Exported lines must be filtered by one bank account';
    begin
        gjl.RESET();
        gjl.COPYFILTERS(GenJournalLine);
        gjl.FILTERGROUP(2);
        gjl.SETFILTER("Bal. Account No.", '<>%1', GenJournalLine."Bal. Account No.");
        gjl.FILTERGROUP(0);
        IF (NOT gjl.ISEMPTY()) THEN ERROR(locText001);

        gjl.FILTERGROUP(2);
        gjl.SETrange("Bal. Account No.");
        gjl.FILTERGROUP(0);
        if (gjl.findset()) then begin
            repeat
                gjl.TestField("Beneficiary Bank Code");
            until (gjl.next() = 0);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure OnAfterSetupNewLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalTemplate: Record "Gen. Journal Template"; GenJournalBatch: Record "Gen. Journal Batch"; LastGenJournalLine: Record "Gen. Journal Line"; Balance: Decimal; BottomLine: Boolean);
    begin
        //PAGE::"Payment Journal"
        GenJournalLine.setupNewLine2(PAGE::"Payment Journal");
    end;

    // t 81 <<

    // t 1237 >>
    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", 'OnAfterValidateEvent', 'Transformation Type', false, false)]
    local procedure onAfterValidateTransformationType(var Rec: Record "Transformation Rule")
    begin
        IF (Rec."Transformation Type" <> Rec."Transformation Type"::Custom) THEN CLEAR(Rec."Custom Transformation Type");
    end;


    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", 'OnTransformation', '', false, false)]
    local procedure OnTransformation(TransformationCode: Code[20]; InputText: Text; var OutputText: Text);
    var
        transformationRule: Record "Transformation Rule";
        noSerMgt: Codeunit NoSeriesManagement;
        ism: Codeunit "Isolated Storage Management BS";
        bankAcc: Record "Bank Account";
        prefix: Code[7];
        padCh: Code[10];
        tmpCode: code[20];
        l: Integer;
        TextLenghtError: Label 'Text length "%1" must be in range %2..%3';
    begin
        transformationRule.get(TransformationCode);

        IF (transformationRule."Custom Transformation Type" <> transformationRule."Custom Transformation Type"::" ") THEN BEGIN
            //OutputText := FORMAT(bankAccountCode);
            if (ism.getString('T1237.BankAccountCode', OutputText, false)) then;
        END;
        CASE (transformationRule."Custom Transformation Type") OF
            transformationRule."Custom Transformation Type"::" ":
                OutputText := InputText;
            transformationRule."Custom Transformation Type"::AddPrefix:
                BEGIN
                    bankAcc.GET(OutputText);

                    CLEAR(prefix);
                    IF (STRPOS(InputText, bankAcc.CheckDocPrefix) <> 1) THEN BEGIN
                        prefix := bankAcc.CheckDocPrefix;
                    END;
                    CLEAR(padCh);
                    bankAcc.TESTFIELD("Bank Payment Order No. Series");
                    tmpCode := noSerMgt.GetNextNo(bankAcc."Bank Payment Order No. Series", TODAY, FALSE);
                    IF (tmpCode <> '') THEN BEGIN
                        l := STRLEN(tmpCode) - STRLEN(prefix) - STRLEN(InputText);
                        IF (l > 0) THEN padCh := PADSTR('', l, '0');
                    END;
                    OutputText := prefix + padCh + InputText;
                END;
            transformationRule."Custom Transformation Type"::DelPrefix:
                BEGIN
                    bankAcc.GET(OutputText);

                    IF (bankAcc.CheckDocPrefix <> '') THEN BEGIN
                        IF (STRPOS(InputText, bankAcc.CheckDocPrefix) > 0) THEN BEGIN
                            InputText := COPYSTR(InputText, STRPOS(InputText, bankAcc.CheckDocPrefix) + STRLEN(bankAcc.CheckDocPrefix));
                            InputText := DELCHR(InputText, '<', '0');
                        END;
                    END;

                    OutputText := InputText;
                END;
            transformationRule."Custom Transformation Type"::CheckLength:
                BEGIN
                    OutputText := InputText;
                    IF (NOT (STRLEN(OutputText) IN [transformationRule."Min. Length" .. transformationRule."Max. Length"])) THEN ERROR(TextLenghtError, OutputText, transformationRule."Min. Length", transformationRule."Max. Length");
                END;
        END;
    end;

    // t 1237 <<

    // REPORTS
    // r 1497 >>
    [EventSubscriber(ObjectType::Report, Report::"Trans. Bank Rec. to Gen. Jnl.", 'OnBeforeGenJnlLineInsert', '', false, false)]
    local procedure OnBeforeGenJnlLineInsert(var GenJournalLine: Record "Gen. Journal Line"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    begin

        IF (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) THEN BEGIN
            GenJournalLine.VALIDATE("Document Date", BankAccReconciliationLine."Transaction Date");
            //GenJournalLine.VALIDATE("Customer Document Date", BankAccReconciliationLine."Transaction Date");
        END;
        IF (BankAccReconciliationLine."Payment Direction" = BankAccReconciliationLine."Payment Direction"::Incoming) THEN BEGIN
            GenJournalLine.VALIDATE(Amount, -ABS(GenJournalLine.Amount));
        END ELSE BEGIN
            GenJournalLine.VALIDATE(Amount, ABS(GenJournalLine.Amount));
        END;

        GenJournalLine."Export Status" := GenJournalLine."Export Status"::"Bank Statement Found";
        GenJournalLine."Statement No." := BankAccReconciliationLine."Statement No.";
        GenJournalLine."Statement Line No." := BankAccReconciliationLine."Statement Line No.";

        BankAccReconciliationLine."Line Status" := BankAccReconciliationLine."Line Status"::"Transferred to Gen. Journal";
        BankAccReconciliationLine.Modify();
    end;
    // r 1497 <<


    // CODEUNITS
    // cu 12 >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeBankAccLedgEntryInsert', '', false, false)]
    local procedure OnPostBankAccOnBeforeBankAccLedgEntryInsert(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; BankAccount: Record "Bank Account");
    begin
        BankAccountLedgerEntry."Payment Purpose" := GenJournalLine."Payment Purpose";
    end;
    // cu 12 <<

    // cu 1201 >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Data Exch.", 'OnAfterDataExchFieldFiltersSet', '', false, false)]
    local procedure OnAfterDataExchFieldFiltersSet(var DataExchFieldMapping: record "Data Exch. Field Mapping"; var DataExchField: Record "Data Exch. Field");
    begin
        IF (DataExchFieldMapping."Use Value From Header") THEN BEGIN
            DataExchField.SETRANGE("Line No.", 0);
        END
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Data Exch.", 'OnBeforeTransformText', '', false, false)]
    local procedure OnBeforeTransformText(var RecRefTemplate: RecordRef);
    var
        ism: Codeunit "Isolated Storage Management BS";
        fldRef: FieldRef;
    begin
        IF (RecRefTemplate.NUMBER = DATABASE::"Bank Acc. Reconciliation Line") THEN BEGIN
            fldRef := RecRefTemplate.FIELD(1);
            ism.setString('T1237.BankAccountCode', FORMAT(fldRef.VALUE));
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Data Exch.", 'OnBeforeFormatFieldValue', '', false, false)]
    local procedure OnBeforeFormatFieldValue(var TransformedValue: Text; DataExchField: Record "Data Exch. Field"; var DataExchFieldMapping: Record "Data Exch. Field Mapping"; FieldRef: FieldRef; DataExchColumnDef: Record "Data Exch. Column Def"; var IsHandled: Boolean);
    var
        dt: Date;
    begin
        case FieldRef.Type of
            FieldType::Date:
                begin
                    IsHandled := evaluate(dt, TransformedValue);
                    if (IsHandled) then begin
                        FieldRef.Value := dt;
                    end;
                end;
        end;
    end;

    // cu 1201 <<

    // cu 1210 >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Export Mgt", 'OnBeforeInsertDataExch', '', false, false)]
    local procedure OnBeforeInsertDataExch(var DataExch: Record "Data Exch."; BankAccountCode: Code[20]);
    begin
        DataExch."Bank Code" := BankAccountCode
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Export Mgt", 'OnProcessColumnMappingOnTransformText', '', false, false)]
    local procedure OnProcessColumnMappingOnTransformText(RecRef: RecordRef; var DataExchFieldMapping: Record "Data Exch. Field Mapping"; var ValueAsString: Text[250]);
    var
        transformationRule: Record "Transformation Rule";
        fldRef: FieldRef;
    begin
        IF (transformationRule.GET(DataExchFieldMapping."Transformation Rule")) THEN BEGIN
            IF (RecRef.NUMBER = DATABASE::"Payment Export Data") THEN BEGIN
                fldRef := RecRef.FIELD(30);
                transformationRule.setBankAccount(FORMAT(fldRef.VALUE));
            END;
            ValueAsString := transformationRule.TransformText(ValueAsString);
        END;
    end;
    // cu 1210 <<

    // cu 1248 >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Bank Acc. Rec Lines", 'OnAfterImportBankStatement', '', false, false)]
    local procedure OnAfterImportBankStatement(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; DataExch: Record "Data Exch.");
    var
        bankAccReconLine: record "Bank Acc. Reconciliation Line";
        genJnlLine: Record "Gen. Journal Line";
        Text008: Label 'There are several payment orders with %1 %2 dated %3.';

    begin
        BankAccReconLine.RESET;
        BankAccReconLine.SETRANGE("Statement Type", BankAccReconciliationLine."Statement Type");
        BankAccReconLine.SETRANGE("Bank Account No.", BankAccReconciliationLine."Bank Account No.");
        BankAccReconLine.SETRANGE("Statement No.", BankAccReconciliationLine."Statement No.");
        BankAccReconLine.SETRANGE("Data Exch. Entry No.", DataExch."Entry No.");
        BankAccReconLine.SETRANGE("Line Status", BankAccReconLine."Line Status"::"Contractor Confirmed");
        IF BankAccReconLine.FINDSET THEN
            REPEAT

                GenJnlLine.SETRANGE("Document No.", BankAccReconLine."Document No.");
                GenJnlLine.SETRANGE("Posting Date", BankAccReconLine."Transaction Date");
                GenJnlLine.SETRANGE(GenJnlLine."Bal. Account No.", BankAccReconLine."Bank Account No.");
                GenJnlLine.SETRANGE("Account No.", BankAccReconLine."Entity No.");
                GenJnlLine.SETRANGE(Amount, BankAccReconLine."Statement Amount");
                ////GenJnlLine.SETRANGE("Export Status",GenJnlLine."Export Status"::Exported);
                IF GenJnlLine.FINDFIRST THEN
                    IF GenJnlLine.NEXT = 0 THEN BEGIN
                        GenJnlLine."Statement No." := BankAccReconLine."Statement No.";
                        GenJnlLine."Statement Line No." := BankAccReconLine."Statement Line No.";
                        GenJnlLine."Export Status" := GenJnlLine."Export Status"::"Bank Statement Found";
                        GenJnlLine.MODIFY;
                        BankAccReconLine."Line Status" := BankAccReconLine."Line Status"::"Payment Order Found";
                        BankAccReconLine.MODIFY;
                    END ELSE
                        MESSAGE(
                          Text008,
                          GenJnlLine.FIELDCAPTION("Document No."),
                          BankAccReconLine."Document No.",
                          BankAccReconLine."Transaction Date");

            UNTIL BankAccReconLine.NEXT = 0;
    end;
    // cu 1248 <<

    // cu 1273 >>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Exp. Pre-Mapping Gen. Jnl.", 'OnBeforeInsertPaymentExoprtData', '', false, false)]
    local procedure OnBeforeInsertPaymentExoprtData(var PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup");
    var
        bankAccount: Record "Bank Account";
        companyInfo: Record "Company Information";
        vendorBankAccount: Record "Vendor Bank Account";
        vendor: Record Vendor;
        tps: Enum "Taxpayer Status Enum BS";


    begin
        with PaymentExportData do begin

            BankAccount.GET("Sender Bank Account Code");
            Vendor.GET(GenJournalLine."Account No.");
            "Sender Bank Name" := COPYSTR(BankAccount.Name, 1, MAXSTRLEN("Sender Bank Name"));
            "Sender Bank BIC" := BankAccount."Bank BIC";
            "Sender Bank City" := BankAccount.City;

            CompanyInfo.GET;
            "Sender VAT Reg. No." := CompanyInfo."VAT Registration No.";
            "Sender KPP" := GenJournalLine."Payer KPP";
            "Sender Transit No." := BankAccount."Bank Corresp. Account No.";
            IF VendorBankAccount.GET(GenJournalLine."Account No.", GenJournalLine."Beneficiary Bank Code") THEN BEGIN
                IF BankAccount."Country/Region Code" = VendorBankAccount."Country/Region Code" THEN BEGIN
                    Amount := GenJournalLine."Amount (LCY)";
                    "Currency Code" := GeneralLedgerSetup."LCY Code";
                END ELSE BEGIN
                    Amount := GenJournalLine.Amount;
                    "Currency Code" := GeneralLedgerSetup.GetCurrencyCode(GenJournalLine."Currency Code");
                END;

                "Recipient Bank Acc. No." :=
                  COPYSTR(VendorBankAccount.GetBankAccountNo, 1, MAXSTRLEN("Recipient Bank Acc. No."));
                "Recipient Reg. No." := VendorBankAccount."Bank Branch No.";
                "Recipient Acc. No." := VendorBankAccount."Bank Account No.";
                "Recipient Bank Country/Region" := VendorBankAccount."Country/Region Code";

                "Recipient Bank Name" := VendorBankAccount.Name;

                "Recipient Bank Address" := VendorBankAccount.Address;
                "Recipient Bank City" := VendorBankAccount."Post Code" + VendorBankAccount.City;
                "Recipient Bank BIC" := VendorBankAccount."SWIFT Code";


                "Recipient Bank BIC" := VendorBankAccount.BIC;
                "Recipient VAT Reg. No." := Vendor."VAT Registration No.";
                "Recipient Transit No." := VendorBankAccount."Bank Corresp. Account No.";
                "Recipient KPP" := Vendor."KPP Code";

            END ELSE
                IF GenJournalLine."Creditor No." <> '' THEN BEGIN
                    Amount := GenJournalLine."Amount (LCY)";
                    "Currency Code" := GeneralLedgerSetup."LCY Code";
                END;
            "Payment Method" := GenJournalLine."Payment Method";
            "Payment Variant" := GenJournalLine."Payment Type";
            "Payment Subsequence" := GenJournalLine."Payment Subsequence";
            "Payment Purpose" := GenJournalLine."Payment Purpose";
            "Payment Code" := GenJournalLine."Payment Code";
            "Creation Date" := TODAY;
            "Creation Time" := FORMAT(TIME);
            "Starting Date" := GenJournalLine."Posting Date";
            "Ending Date" := GenJournalLine."Posting Date";

            KBK := GenJournalLine.KBK;
            OKATO := GenJournalLine.OKATO;
            "Payment Reason Code" := GenJournalLine."Payment Reason Code";
            "Reason Document No." := GenJournalLine."Reason Document No.";
            "Reason Document Date" := GenJournalLine."Reason Document Date";
            "Tax Payment Type" := GenJournalLine."Tax Payment Type";
            "Tax Period" := GenJournalLine."Tax Period";
            "Taxpayer Status" := Enum::"Taxpayer Status Enum BS".FromInteger(tps.Ordinals.Get(tps.Names.IndexOf(format(GenJournalLine."Taxpayer Status"))));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Exp. Pre-Mapping Gen. Jnl.", 'OnCustPreparePaymentExportDataJnl', '', false, false)]
    local procedure OnCustPreparePaymentExportDataJnl(var GenJnlLine: Record "Gen. Journal Line"; DataExchEntryNo: integer; LineNo: integer; var isHandled: boolean)
    var
        bankAccount: Record "Bank Account";
        companyInfo: Record "Company Information";
        customerBankAccount: Record "customer Bank Account";
        customer: Record customer;
        tps: Enum "Taxpayer Status Enum BS";
        generalLedgerSetup: Record "General Ledger Setup";
        paymentExportData: Record "Payment Export Data";
        bankExportImportSetup: Record "Bank Export/Import Setup";
        paymentMethod: Record "Payment Method";
    begin
        IF GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer THEN BEGIN
            isHandled := true;
            GeneralLedgerSetup.GET;
            GenJnlLine.TESTFIELD("Account Type", GenJnlLine."Account Type"::Customer);
            Customer.GET(GenJnlLine."Account No.");

            WITH PaymentExportData DO BEGIN
                BankAccount.GET(GenJnlLine."Bal. Account No.");
                BankAccount.GetBankExportImportSetup(BankExportImportSetup);
                SetPreserveNonLatinCharacters(BankExportImportSetup."Preserve Non-Latin Characters");

                INIT;
                "Data Exch Entry No." := DataExchEntryNo;
                "Sender Bank Account Code" := GenJnlLine."Bal. Account No.";
                BankAccount.GET("Sender Bank Account Code");
                "Sender Bank Account No." := COPYSTR(BankAccount.GetBankAccountNo, 1, MAXSTRLEN("Sender Bank Account No."));

                "Sender Bank Name" := BankAccount.Name;
                "Sender Bank BIC" := BankAccount."Bank BIC";
                "Sender Bank City" := BankAccount.City;


                CompanyInfo.GET;
                "Sender VAT Reg. No." := CompanyInfo."VAT Registration No.";

                "Sender KPP" := GenJnlLine."Payer KPP";

                "Sender Transit No." := BankAccount."Bank Corresp. Account No.";


                IF CustomerBankAccount.GET(GenJnlLine."Account No.", GenJnlLine."Beneficiary Bank Code") THEN BEGIN
                    IF BankAccount."Country/Region Code" = CustomerBankAccount."Country/Region Code" THEN BEGIN
                        Amount := GenJnlLine."Amount (LCY)";
                        "Currency Code" := GeneralLedgerSetup."LCY Code";
                    END ELSE BEGIN
                        Amount := GenJnlLine.Amount;
                        "Currency Code" := GeneralLedgerSetup.GetCurrencyCode(GenJnlLine."Currency Code");
                    END;

                    "Recipient Bank Acc. No." :=
                      COPYSTR(CustomerBankAccount.GetBankAccountNo, 1, MAXSTRLEN("Recipient Bank Acc. No."));
                    "Recipient Reg. No." := CustomerBankAccount."Bank Branch No.";
                    "Recipient Acc. No." := CustomerBankAccount."Bank Account No.";
                    "Recipient Bank Country/Region" := CustomerBankAccount."Country/Region Code";
                    "Recipient Bank Name" := CustomerBankAccount.Name;
                    "Recipient Bank Address" := CustomerBankAccount.Address;
                    "Recipient Bank City" := CustomerBankAccount."Post Code" + CustomerBankAccount.City;

                    "Recipient Bank BIC" := CustomerBankAccount.BIC;
                    "Recipient VAT Reg. No." := Customer."VAT Registration No.";
                    "Recipient Transit No." := CustomerBankAccount."Bank Corresp. Account No.";
                    "Recipient KPP" := Customer."KPP Code";

                END ELSE
                    IF GenJnlLine."Creditor No." <> '' THEN BEGIN
                        Amount := GenJnlLine."Amount (LCY)";
                        "Currency Code" := GeneralLedgerSetup."LCY Code";
                    END;

                "Payment Method" := GenJnlLine."Payment Method";
                "Payment Variant" := GenJnlLine."Payment Type";
                "Payment Subsequence" := GenJnlLine."Payment Subsequence";
                "Payment Purpose" := GenJnlLine."Payment Purpose";
                "Payment Code" := GenJnlLine."Payment Code";
                "Creation Date" := TODAY;
                "Creation Time" := FORMAT(TIME);
                "Starting Date" := GenJnlLine."Posting Date";
                "Ending Date" := GenJnlLine."Posting Date";

                KBK := GenJnlLine.KBK;
                OKATO := GenJnlLine.OKATO;
                "Payment Reason Code" := GenJnlLine."Payment Reason Code";
                "Reason Document No." := GenJnlLine."Reason Document No.";
                "Reason Document Date" := GenJnlLine."Reason Document Date";
                "Tax Payment Type" := GenJnlLine."Tax Payment Type";
                "Tax Period" := GenJnlLine."Tax Period";
                "Taxpayer Status" := Enum::"Taxpayer Status Enum BS".FromInteger(tps.Ordinals.Get(tps.Names.IndexOf(format(GenJnlLine."Taxpayer Status"))));

                "Recipient Name" := Customer.Name;
                "Recipient Address" := Customer.Address;
                "Recipient City" := Customer."Post Code" + ' ' + Customer.City;
                "Transfer Date" := GenJnlLine."Posting Date";
                "Message to Recipient 1" := GenJnlLine."Message to Recipient";

                "Document No." := GenJnlLine."Document No.";
                "Applies-to Ext. Doc. No." := GenJnlLine."Applies-to Ext. Doc. No.";
                "Short Advice" := GenJnlLine."Applies-to Ext. Doc. No.";
                "Line No." := LineNo;
                "Payment Reference" := GenJnlLine."Payment Reference";
                IF PaymentMethod.GET(GenJnlLine."Payment Method Code") THEN
                    "Data Exch. Line Def Code" := PaymentMethod."Pmt. Export Line Definition";
                "Recipient Creditor No." := GenJnlLine."Creditor No.";
                INSERT(TRUE);
            end;
        end;
    end;
    // cu 1273 <<

    // Event Subscribers <<

    // functions >>

    // cu 50113 >>
    procedure manualAssignPaymentJournalLine(var r: record "Bank Acc. Reconciliation Line")
    var
        paymentJournal: page "Payment Journal";
        gjl: record "Gen. Journal Line";
        setLink: Boolean;
        genJnlBatch: Record "Gen. Journal Batch";
        AssignToGJL: label 'Do you want to assign bank acc. reconciliation line to gen. journal line %1 %2 %3?';
        AlreadyAssigned: label 'Gen. journal line allready assigned to bank acc. reconciliation line %1 %2. Do you want to reassign it?';
        WrongStatus: label 'Line status must be %1 or %2';
    begin
        with r do begin
            IF (NOT (R."Line Status" IN [R."Line Status"::"Contractor Confirmed", R."Line Status"::Imported])) THEN ERROR(WrongStatus, R."Line Status"::"Contractor Confirmed", R."Line Status"::Imported);
            //Rec.TESTFIELD("Line Status",Rec."Line Status"::"Contractor Confirmed");

            gjl.RESET();

            genJnlBatch.RESET();
            genJnlBatch.SETRANGE("Bal. Account Type", genJnlBatch."Bal. Account Type"::"Bank Account");
            genJnlBatch.SETRANGE("Bal. Account No.", R."Bank Account No.");
            genJnlBatch.SETFILTER("Payment Method Code", '<>''''');
            IF (genJnlBatch.FINDFIRST()) THEN BEGIN
                gjl.FILTERGROUP(2);
                gjl.SETRANGE("Journal Template Name", genJnlBatch."Journal Template Name");
                gjl.FILTERGROUP(0);
                //gjl.SETRANGE("Journal Batch Name",genJnlBatch.Name);
            END;

            gjl.SETRANGE("Document No.", R."Document No.");
            gjl.SETRANGE("Posting Date", R."Transaction Date");
            gjl.SETRANGE("Bal. Account No.", R."Bank Account No.");
            gjl.SETRANGE(Amount, R."Statement Amount");
            IF (gjl.FINDSET()) THEN BEGIN
                paymentJournal.SETRECORD(gjl);
            END;
            paymentJournal.SETTABLEVIEW(gjl);
            paymentJournal.LookupMode(true);
            IF (paymentJournal.RUNMODAL() = ACTION::LookupOK) THEN BEGIN
                paymentJournal.GETRECORD(gjl);
                IF (gjl.Amount = R."Statement Amount") THEN BEGIN
                    setLink := FALSE;
                    IF (CONFIRM(AssignToGJL, FALSE, gjl."Journal Template Name", gjl."Journal Batch Name", gjl."Line No.")) THEN BEGIN
                        setLink := TRUE;
                        IF (gjl."Statement No." <> '') THEN BEGIN
                            setLink := CONFIRM(AlreadyAssigned, FALSE, gjl."Statement No.", gjl."Statement Line No.");
                        END;
                        IF (setLink) THEN BEGIN
                            gjl."Statement No." := R."Statement No.";
                            gjl."Statement Line No." := R."Statement Line No.";
                            gjl."Export Status" := gjl."Export Status"::"Bank Statement Found";
                            gjl.MODIFY;
                            R."Line Status" := R."Line Status"::"Payment Order Found";
                            IF (R."Entity No." <> gjl."Account No.") THEN BEGIN
                                CASE (gjl."Account Type") OF
                                    gjl."Account Type"::Customer:
                                        R."Entity Type" := R."Entity Type"::Customer;
                                    gjl."Account Type"::"G/L Account":
                                        R."Entity Type" := R."Entity Type"::"G/L Account";
                                    gjl."Account Type"::Vendor:
                                        R."Entity Type" := R."Entity Type"::Vendor;
                                END;
                                R."Entity No." := gjl."Account No.";
                            END;
                            R.MODIFY();
                        END;
                    END;
                END;
            END;

        end;
    end;

    procedure clearAssignPaymentJournalLine(var r: record "Bank Acc. Reconciliation Line")
    var
        gjl: record "Gen. Journal Line";
        WrongStatus: label 'Line status must be %1';
    begin
        with r do begin
            IF (not ("Line Status" in ["Line Status"::"Payment Order Found"])) THEN ERROR(WrongStatus, "Line Status"::"Payment Order Found");
            gjl.RESET();
            gjl.SetRange("Bal. Account No.", "Bank Account No.");
            gjl.setrange("Statement No.", "Statement No.");
            gjl.setrange("Statement Line No.", "Statement Line No.");
            if (gjl.Findlast()) then begin
                gjl."Export Status" := gjl."Export Status"::Exported;
                gjl."Statement No." := '';
                gjl."Statement Line No." := 0;
                gjl.modify();

                "Line Status" := "Line Status"::"Contractor Confirmed";
                MODIFY;

            end;
        end;
    end;

    // cu 50113 <<


    // cu 50118 >>
    procedure copyReconLine(ReconciliationLineParam: Record "Bank Acc. Reconciliation Line")
    var
        reconciliationLine: record "Bank Acc. Reconciliation Line";
        newLineNo: integer;
    begin
        ReconciliationLine.SETRANGE("Bank Account No.", ReconciliationLineParam."Bank Account No.");
        ReconciliationLine.SETRANGE("Statement No.", ReconciliationLineParam."Statement No.");
        IF ReconciliationLine.FINDLAST() THEN BEGIN
            NewLineNo := ReconciliationLine."Statement Line No." + 10000;
            ReconciliationLine.INIT();
            ReconciliationLine.TRANSFERFIELDS(ReconciliationLineParam);
            ReconciliationLine."Statement Line No." := NewLineNo;
            ReconciliationLine.Difference := ReconciliationLine."Statement Amount";
            ReconciliationLine."Applied Amount" := 0;
            ReconciliationLine."Applied Entries" := 0;
            ReconciliationLine.INSERT(TRUE);
        end;
    end;


    // cu 50188 <<
    // functions <<
}