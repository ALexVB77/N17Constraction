pageextension 94902 "Vendor Agreement Card (Ext)" extends "Vendor Agreement Card"
{
    layout
    {
        modify("No.")
        {
            StyleExpr = LineColor;

            trigger OnAssistEdit()
            begin
                if Rec.AssistEdit(xRec) then
                    CurrPage.Update();
            end;
        }
        modify(Description)
        {
            StyleExpr = LineColor;
        }

        addafter("Tax Authority No.")
        {
            field("Vat Agent Posting Group"; Rec."Vat Agent Posting Group")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("VAT Agent")
        {
            part(BreakdownByLetter; "Vendor Agreement Details")
            {
                Caption = 'Breakdown by Letter';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Agreement No." = field("No."), "Vendor No." = field("Vendor No.");
                UpdatePropagation = Both;
            }
            part(PaymentSchedule; "Vendor Agreement Budget")
            {
                Caption = 'Payment Schedule';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Agreement No." = FIELD("No."), "Contragent No." = FIELD("Vendor No.");
                SubPageView = sorting(Date);
                UpdatePropagation = Both;
            }
        }
        addafter(Priority)
        {
            field("Exist Comment"; Rec."Exists Comment")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Exist Attachment"; Rec."Exists Attachment")
            {
                ApplicationArea = Basic, Suite;
            }
            field("COST PLACE"; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("COST CODE"; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Project Dimension Code"; Rec."Project Dimension Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Do not check CashFlow"; Rec."Don't Check CashFlow")
            {
                ApplicationArea = Basic, Suite;
            }
            group(Amounts)
            {
                ShowCaption = false;

                field("Agreement Amount"; Rec."Agreement Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Without VAT"; Rec."Amount Without VAT")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(PaidWithVATREstateTest; PaidWithVATREstateTest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Paid, with VAT';
                }
                field(Remain; Rec."Agreement Amount" - PaidWithVATREstateTest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Remain, with VAT';
                }
            }
            group("Purchase Limit Control")
            {
                Caption = 'Purchase Limit Control';
                Visible = PLCVisible;

                field("Check Limit Starting Date"; Rec."Check Limit Starting Date")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Check Limit Ending Date"; Rec."Check Limit Ending Date")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Check Limit Amount (LCY)"; Rec."Check Limit Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Purch. Original Amt. (LCY)"; Rec."Purch. Original Amt. (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                }

                field(CtrlDeviation; Rec."Check Limit Amount (LCY)" - Rec."Purch. Original Amt. (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Deviation';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
        }
        addbefore(Control1905767507)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(14901),
                              "No." = FIELD("No."),
                              "PK Key 2" = FIELD("Vendor No.");
            }
        }

        modify("Vendor Posting Group")
        {
            Editable = HasntOpenLedgerEntries;
        }

    }
    actions
    {
        addlast("A&greement")
        {
            action(ChangeLog)
            {
                ApplicationArea = All;
                Caption = 'Change Log';
                Image = ChangeLog;

                trigger OnAction()
                var
                    ChangeLogEntry: Record "Change Log Entry";
                begin
                    ChangeLogEntry.Reset();
                    ChangeLogEntry.SetCurrentKey("Table No.", "Primary Key Field 1 Value", "Primary Key Field 2 Value");
                    ChangeLogEntry.SetRange("Table No.", Database::"Vendor Agreement");
                    ChangeLogEntry.SetRange("Primary Key Field 1 Value", Rec."Vendor No.");
                    ChangeLogEntry.SetRange("Primary Key Field 2 Value", Rec."No.");
                    Page.RunModal(Page::"Change Log Entries", ChangeLogEntry);
                end;
            }

            action(ExportToExcel)
            {
                ApplicationArea = All;
                Caption = 'Export to Excel';
                Image = Excel;

                trigger OnAction()
                var
                    ExportSubform: Report ExportSubform;
                begin
                    Clear(ExportSubform);
                    ExportSubform.UseRequestPage(false);
                    ExportSubform.SetDocNo(Rec."No.", Rec."Vendor No.");
                    ExportSubform.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if (CompanyName = Monkey.ConstCompany('NCC Real Estate')) then begin
            PaidWithVATREstateTestVisiable := true;
            PaidWithVATVisiable := false;
        end else begin
            PaidWithVATVisiable := true;
            PaidWithVATREstateTestVisiable := false;
        end;

        CompanyInfo.Get();
        PLCVisible := CompanyInfo."Use RedFlags in Agreements";
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        myInt: Integer;
        Text001: Label 'FRAME';
    begin
        if CompanyInfo."Use RedFlags in Agreements" then
            if not (Rec."Agreement Group" in ['', Text001]) and (Rec."Agreement Amount" = 0) then
                Error(Text003);
    end;

    trigger OnAfterGetRecord()
    begin
        LineColor := Rec.GetLineColor();

        OnFormat();
    end;

    trigger OnAfterGetCurrRecord()
    var
        PaidWithVAT: Decimal;
        continue: Boolean;
        gle: Record "G/L Entry";
        vle: Record "Vendor Ledger Entry";
        SourceCodeSetup: Record "Source Code Setup";
        DetVendLE: Record "Detailed Vendor Ledg. Entry";
        dvleTMP: Record "Detailed Vendor Ledg. Entry" temporary;
        VendAgrConstrTest: Record "Vendor Agreement";
        Monkey: Codeunit "Code Monkey Translation";
    begin

        PaidWithVAT := 0;
        PaidWithVATConstrTest := 0;
        PaidWithVATSumTest := 0;
        PaidWithVATREstateTest := 0;
        IF (COMPANYNAME = Monkey.ConstCompany('NCC Real Estate')) THEN BEGIN
            DetVendLE.SETCURRENTKEY("Vendor No.", "Initial Document Type", "Document Type", "Entry Type", "Posting Date",
                "Currency Code", "Agreement No.", "Prepmt. Diff. in TA");
            DetVendLE.SETRANGE("Vendor No.", Rec."Vendor No.");
            DetVendLE.SETRANGE("Agreement No.", Rec."No.");
            DetVendLE.SETFILTER("Document Type", '%1|%2', DetVendLE."Document Type"::Payment,
                                                        DetVendLE."Document Type"::Refund);
            DetVendLE.SETFILTER("Entry Type",
            // SWC DD 10.08.17 >>
            '<>%1&<>%2&<>%3', DetVendLE."Entry Type"::Application, DetVendLE."Entry Type"::"Appln. Rounding",
                            DetVendLE."Entry Type"::"Correction of Remaining Amount");
            // SWC DD 10.08.17 <<
            DetVendLE.SETFILTER("Posting Date", '%1..', 20150806D);
            DetVendLE.CALCSUMS("Amount (LCY)");
            PaidWithVAT := DetVendLE."Amount (LCY)";

            VendAgrConstrTest.RESET;
            VendAgrConstrTest.CHANGECOMPANY(Monkey.ConstCompany('NCC Construction'));
            VendAgrConstrTest.SETRANGE("No.", Rec."Original No.");
            IF VendAgrConstrTest.FINDFIRST THEN BEGIN
                VendAgrConstrTest.CALCFIELDS("Paid With VAT");
                IF Rec."Original No." <> '' THEN BEGIN
                    PaidWithVATConstrTest := VendAgrConstrTest."Paid With VAT";
                    PaidWithVATSumTest := PaidWithVAT + VendAgrConstrTest."Paid With VAT";
                END ELSE BEGIN
                    PaidWithVATConstrTest := 0;
                    PaidWithVATSumTest := PaidWithVAT;
                END;
            END;

            // SWC1061 DD 26.06.17 >>
            IF Rec."Original Company" = 'VL' THEN BEGIN
                VendAgrConstrTest.RESET;
                VendAgrConstrTest.CHANGECOMPANY(Monkey.ConstCompany('NCC Village'));
                VendAgrConstrTest.SETRANGE("No.", COPYSTR(Rec."No.", 4));
                IF VendAgrConstrTest.FINDFIRST THEN BEGIN
                    VendAgrConstrTest.CALCFIELDS("Paid With VAT");
                    PaidWithVATConstrTest := VendAgrConstrTest."Paid With VAT";
                    PaidWithVATSumTest := PaidWithVAT + VendAgrConstrTest."Paid With VAT";
                END;
            END;
            // SWC1061 DD 26.06.17 <<

            PaidWithVAT := 0;
            DetVendLE.SETRANGE("Vendor No.", Rec."Vendor No.");
            DetVendLE.SETRANGE("Agreement No.", Rec."No.");
            DetVendLE.SETFILTER("Document Type", '%1|%2|%3', DetVendLE."Document Type"::" ",
                                                            DetVendLE."Document Type"::Payment,
                                                            DetVendLE."Document Type"::Refund);

            DetVendLE.SETFILTER("Entry Type",
            // SWC DD 10.08.17 >>
            '<>%1&<>%2&<>%3', DetVendLE."Entry Type"::Application, DetVendLE."Entry Type"::"Appln. Rounding",
                            DetVendLE."Entry Type"::"Correction of Remaining Amount");
            // SWC DD 10.08.17 <<
            //SWC750 KAE 160216 >>
            DetVendLE.SETRANGE("Posting Date");

            IF DetVendLE.FINDFIRST THEN
                REPEAT
                    //SWC877 KAE 080816 >>
                    continue := FALSE;
                    IF (DetVendLE."Document Type" = DetVendLE."Document Type"::" ") THEN BEGIN
                        vle.RESET;
                        vle.GET(DetVendLE."Vendor Ledger Entry No.");
                        continue := vle."Include in Paid With VAT";
                    END ELSE BEGIN
                        continue := TRUE;
                    END;
                    //SWC945 KAE 28111 >>
                    IF continue THEN
                        continue := NOT DublicateOperationExists(DetVendLE, dvleTMP); //SWC945 KAE 28111 <<

                    // SWC995 DD 17.03.17 >>
                    SourceCodeSetup.GET();
                    IF (DetVendLE."Document Type" IN [DetVendLE."Document Type"::" ", DetVendLE."Document Type"::Payment])
                    AND (DetVendLE."Entry Type" = DetVendLE."Entry Type"::"Initial Entry")
                    AND (DetVendLE."Source Code" = SourceCodeSetup."Vendor Prepayments")
                    THEN
                        continue := FALSE;
                    // SWC995 DD 17.03.17 <<

                    //SWC802 KAE 160516 >>
                    IF continue THEN
                    //SWC877 KAE 080816 <<
                    BEGIN
                        //SWC802 KAE 160516 <<
                        gle.RESET;
                        gle.SETRANGE("Transaction No.", DetVendLE."Transaction No.");
                        gle.SETRANGE("Document No.", DetVendLE."Document No.");
                        //gle.SETRANGE(Amount,DetVendLE."Amount (LCY)");
                        IF gle.FINDFIRST THEN
                            // CHECK CODE  AN >>
                            // IF (gle."Orig. CV Ledg. Entry No." = 0) AND (gle."Orig. VAT Entry No." = 0) THEN
                            // CHECK CODE  AN <<
                            // SWC1061 DD 26.06.17 >>
                            IF COPYSTR(DetVendLE."Document No.", 1, 3) <> 'VL-' THEN
                                // SWC1061 DD 26.06.17 <<
                                PaidWithVAT += DetVendLE."Amount (LCY)";
                    END; //SWC802 KAE 160516 <<
                UNTIL DetVendLE.NEXT = 0;

            PaidWithVATREstateTest := PaidWithVAT + PaidWithVATConstrTest;

            //SWC750 KAE 150216 <<
        END;
    end;

    var
        PaidWithVATREstateTest: Decimal;
        PaidWithVATConstrTest: Decimal;
        PaidWithVATSumTest: Decimal;
        PaidWithVATVisiable: Boolean;
        PaidWithVATREstateTestVisiable: Boolean;
        Monkey: Codeunit "Code Monkey Translation";
        CompanyInfo: Record "Company Information";
        PLCVisible: Boolean;
        LineColor: Text;
        Text003: Label 'Set Agreememt Amount';
        HasntOpenLedgerEntries: Boolean;

    local procedure OnFormat()
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgerEntry.SETRANGE("Vendor No.", Rec."Vendor No.");
        VendLedgerEntry.SETRANGE("Agreement No.", Rec."No.");
        VendLedgerEntry.SETRANGE(Open, TRUE);
        HasntOpenLedgerEntries := VendLedgerEntry.ISEMPTY;
    end;


    local procedure DublicateOperationExists(var dvle: Record "Detailed Vendor Ledg. Entry"; var dvleTMP: Record "Detailed Vendor Ledg. Entry" temporary): Boolean
    var
        vle: Record "Vendor Ledger Entry";
    begin

        vle.GET(dvle."Vendor Ledger Entry No.");
        IF vle.Reversed THEN EXIT(TRUE);

        dvleTMP.RESET;
        dvleTMP.SETRANGE("Document No.", dvle."Document No.");
        dvleTMP.SETRANGE("Agreement No.", dvle."Agreement No.");
        dvleTMP.SETRANGE(Amount, dvle.Amount);
        IF dvleTMP.ISEMPTY THEN
        //IF NOT dvleTMP.GET(dvle."Entry No.") THEN
        BEGIN
            dvleTMP := dvle;
            IF dvleTMP.INSERT THEN;
            EXIT(FALSE);
        END ELSE BEGIN
            EXIT(TRUE);
        END;
    end;
}
