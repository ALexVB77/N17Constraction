page 70009 "Posted Gen. Journals_"
{
    Caption = 'Posted Gen. Journals';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Gen. Journal Line Archive";
    SaveValues = true;

    layout
    {
        area(Content)
        {

            field(CurrentJnlTemplateName; CurrentJnlTemplateName)
            {
                Caption = 'Current Journal Template Name';
                Enabled = false;
                ApplicationArea = All;
            }
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                Caption = 'Current Journal Batch Name';
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    GenJnlManagement.CheckName(CurrentJnlBatchName, GenJnlLine);

                    CurrPage.SaveRecord();
                    SetName;
                    CurrPage.Update(false);
                end;

                trigger OnLookup(var Text: Text): Boolean
                begin

                    if page.RunModal(Page::"Posted Gen. Journal Batches", GenJnlBatch) = Action::LookupOK then begin
                        CurrentJnlTemplateName := GenJnlBatch."Journal Template Name";
                        CurrentJnlBatchName := GenJnlBatch.Name;
                        SetName;
                    End;
                    CurrPage.Update(false);
                end;
            }

            repeater(GroupName)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;

                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;

                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        GetAccounts(AccName, BalAccName);
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        GetAccounts(AccName, BalAccName);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Business Unit Code"; Rec."Business Unit Code")
                {
                    ApplicationArea = All;
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = All;
                }
                field("Campaign No."; Rec."Campaign No.")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin

                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date");
                        if ChangeExchangeRate.RunModal = Action::OK then begin
                            Rec.validate("Currency Factor", ChangeExchangeRate.GetParameter);
                        end;
                        Clear(ChangeExchangeRate);
                    end;
                }
                field("Gen. Posting Type"; Rec."Gen. Posting Type")
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                }
                field("VAT Difference"; Rec."VAT Difference")
                {
                    ApplicationArea = All;
                }
                field("Bal. VAT Amount"; Rec."Bal. VAT Amount")
                {
                    ApplicationArea = All;
                }
                field("Bal. VAT Difference"; Rec."Bal. VAT Difference")
                {
                    ApplicationArea = All;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = All;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        GetAccounts(AccName, BalAccName);
                    end;
                }
                field("Bal. Gen. Posting Type"; Rec."Bal. Gen. Posting Type")
                {
                    ApplicationArea = All;
                }
                field("Bal. Gen. Bus. Posting Group"; Rec."Bal. Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Bal. Gen. Prod. Posting Group"; Rec."Bal. Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Bal. VAT Bus. Posting Group"; Rec."Bal. VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Bal. VAT Prod. Posting Group"; Rec."Bal. VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-to/Order Address Code"; Rec."Ship-to/Order Address Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = All;
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = All;
                }
                field("Applies-to ID"; Rec."Applies-to ID")
                {
                    ApplicationArea = All;
                }
                field("On Hold"; Rec."On Hold")
                {
                    ApplicationArea = All;
                }
                field("Bank Payment Type"; Rec."Bank Payment Type")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }


    actions
    {
        area(Processing)
        {
            /*action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }*/
        }
    }

    var
        Template: Code[20];
        Batch: Code[20];


        GenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        ChangeExchangeRate: Page "Change Exchange Rate";
        // NavigateForm	Form	Navigate	
        GenJnlManagement: Codeunit GenJnlManagement;
        DimMgt: Codeunit DimensionManagement;
        CurrentJnlTemplateName: Code[10];
        CurrentJnlBatchName: Code[10];
        AccName: Text[50];
        BalAccName: Text[50];
        ShortcutDimCode: Code[20];
        LineNo: Integer;
        GLSetup: Record "General Ledger Setup";
        SelectedLine: Record "Gen. Journal Line Archive";
        i: Integer;

    trigger OnOpenPage()
    begin


        if (Template = '') and (Batch = '') then begin
            GenJnlBatch.Reset();
            GenJnlBatch.FindSet();
            CurrentJnlTemplateName := GenJnlBatch."Journal Template Name";
            CurrentJnlBatchName := GenJnlBatch.Name;
        end else begin
            CurrentJnlTemplateName := Template;
            CurrentJnlBatchName := Batch;
        end;

        OpenJnl;
    end;


    procedure SetParametrs(Templ: Code[20]; Bat: Code[20])
    var
    begin
        Template := Templ;
        Batch := Bat;
    end;

    local procedure GetAccounts(var lAccName: Text[30]; var lBalAccName: Text[30]);
    var
        GLAcc: Record "G/L Account";
        Cust: Record Customer;
        Vend: Record Vendor;
        BankAcc: Record "Bank Account";
        FA: Record "Fixed Asset";

    begin
        lAccName := '';
        if GenJnlLine."Account No." <> '' then
            case GenJnlLine."Account Type" of
                GenJnlLine."Account Type"::"G/L Account":
                    if GLAcc.GET(GenJnlLine."Account No.") then
                        lAccName := GLAcc.Name;
                GenJnlLine."Account Type"::Customer:
                    if Cust.GET(GenJnlLine."Account No.") then
                        lAccName := Cust.Name;
                GenJnlLine."Account Type"::Vendor:
                    if Vend.GET(GenJnlLine."Account No.") then
                        lAccName := Vend.Name;
                GenJnlLine."Account Type"::"Bank Account":
                    if BankAcc.GET(GenJnlLine."Account No.") then
                        lAccName := BankAcc.Name;
                GenJnlLine."Account Type"::"Fixed Asset":
                    if FA.GET(GenJnlLine."Account No.") then
                        lAccName := FA.Description;
            end;

        lBalAccName := '';
        if GenJnlLine."Bal. Account No." <> '' then
            case GenJnlLine."Bal. Account Type" OF
                GenJnlLine."Bal. Account Type"::"G/L Account":
                    if GLAcc.GET(GenJnlLine."Bal. Account No.") then
                        lBalAccName := GLAcc.Name;
                GenJnlLine."Bal. Account Type"::Customer:
                    if Cust.GET(GenJnlLine."Bal. Account No.") then
                        lBalAccName := Cust.Name;
                GenJnlLine."Bal. Account Type"::Vendor:
                    if Vend.GET(GenJnlLine."Bal. Account No.") then
                        lBalAccName := Vend.Name;
                GenJnlLine."Bal. Account Type"::"Bank Account":
                    if BankAcc.GET(GenJnlLine."Bal. Account No.") then
                        lBalAccName := BankAcc.Name;
                GenJnlLine."Bal. Account Type"::"Fixed Asset":
                    if FA.GET(GenJnlLine."Bal. Account No.") then
                        lBalAccName := FA.Description;
            end;

    end;

    local procedure SetName()
    var

    begin

        Rec.FilterGroup := 2;
        Rec.SetRange("Journal Template Name", CurrentJnlTemplateName);
        Rec.SetRange("Journal Batch Name", CurrentJnlBatchName);
        rec.FilterGroup := 0;
        if Rec.FindSet() then;
    end;

    local procedure OpenJnl()
    var

    begin
        Rec.FilterGroup := 2;
        Rec.SetRange("Journal Template Name", CurrentJnlTemplateName);
        Rec.SetRange("Journal Batch Name", CurrentJnlBatchName);
        rec.FilterGroup := 0;
        if Rec.FindSet() then;
    end;

    procedure CopyLines()
    var
        DimSet: Record "Dimension Set Entry";
    begin
        //i := SelectedLine.count;
        GLSetup.get;
        GenJnlLine.reset;
        GenJnlLine.SetRange("Journal Template Name", Template);
        GenJnlLine.SetRange("Journal Batch Name", Batch);
        if GenJnlLine.FindLast() then
            LineNo := GenJnlLine."Line No."
        else
            LineNo := 0;

        if SelectedLine.FindFirst() then
            repeat
                LineNo += 10000;
                GenJnlLine.Init();
                GenJnlLine.TransferFields(SelectedLine, FALSE);
                GenJnlLine."Journal Template Name" := Template;
                GenJnlLine."Journal Batch Name" := Batch;
                GenJnlLine."Line No." := LineNo;
                DimSet.SetRange("Dimension Set ID", SelectedLine."Dimension Set ID");
                GenJnlLine."Dimension Set ID" := DimMgt.GetDimensionSetID(DimSet);
                //DimSet.GetDimensionSetID(DimSet);
                GenJnlLine.insert;
            until SelectedLine.next = 0;
    end;


    procedure SetSelectedLines(var GJLA: Record "Gen. Journal Line Archive")
    var

    begin
        selectedLine.Copy(GJLA);

        //i := SelectedLine.count;
    end;
}