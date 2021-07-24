report 50063 "Share Participant Act 2"
{
    WordLayout = './Reports/Layouts/FinancialObligationsCertificateTemplate.docx';
    Caption = 'Share Participant Act 2';
    DefaultLayout = Word;
    PreviewMode = PrintLayout;
    UsageCategory = Administration;
    ApplicationArea = All;
    WordMergeDataItem = Header;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Header; Integer)
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;
            column(ReportTitle; ReportTitle)
            {

            }
            column(JobTitleGenitive; Employee."Job Title Genitive")
            {

            }
            column(JobTitle; Employee."Job Title")
            {

            }
            column(FullNameGenitive; Employee."Full Name Genitive")
            {

            }
            column(ShortName; GetShortName(SubstAccountantNo))
            {

            }
            column(ActDate; Format(ActDate))
            {

            }
            column(EmplName2; EmplName[2])
            {

            }
            column(EmplName3; EmplName[3])
            {

            }
            column(ExternalAgreementNo; Agreement."External Agreement No.")
            {

            }
            column(AgreementDate; Format(Agreement."Agreement Date"))
            {

            }
            column(AgreementAmount; Format(Agreement."Agreement Amount"))
            {

            }
            column(ActDate2; Format(ActDate))
            {

            }
            column(AmountOwed; AmountOwed)
            {

            }
            column(ActDate3; ActDate3)
            {

            }
            column(Status; Status)
            {

            }
            column(DebtStatus; DebtStatus)
            {

            }
            column(TotalPaymentAmount; TotalPaymentAmount)
            {

            }
            dataitem(Line; Integer)
            {
                DataItemTableView = sorting(Number);
                column(FAPostingDate; FAPostingDate)
                {

                }
                column(InsuranceNo; InsuranceNo)
                {

                }
                column(Amount; Amount)
                {

                }

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, Buff.Count);
                end;

                trigger OnAfterGetRecord()
                begin
                    Buff.Reset();
                    if Number = 1 then
                        Buff.FindFirst()
                    else
                        Buff.Next();

                    FAPostingDate := Format(Buff."FA Posting Date");
                    if not Buff."Use Duplication List" then
                        InsuranceNo := Format(Buff."Insurance No.")
                    else
                        InsuranceNo := Format(Buff."Insurance No.") + ' (возм.)';
                    Amount := Format(Buff.Amount);
                end;
            }
        }

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    ShowCaption = false;
                    field(ActDate; ActDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Act Date';
                    }
                    field(CustomerNo; CustomerNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        TableRelation = Customer."No.";

                        trigger OnValidate()
                        begin
                            if CustomerNo = '' then begin
                                EmplName[2] := '';
                                EmplName[3] := '';
                            end else begin
                                Customer.Get(CustomerNo);
                                EmplName[2] := Customer.Name;
                                EmplName[3] := EmplName[2];
                            end;
                        end;
                    }
                    group(Employee)
                    {
                        ShowCaption = false;
                        field(EmployeeName1; EmplName[2])
                        {
                            ApplicationArea = All;
                            Caption = 'By whom (fulfillment of obligations ..)?';
                        }
                        field(EmployeeName2; EmplName[3])
                        {
                            ApplicationArea = All;
                            Caption = 'Who (debt ..)?';
                        }
                    }
                    field(AgreementNo; AgreementNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Agreement No.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            Agreement.Reset();
                            Agreement.SetRange("Customer No.", CustomerNo);
                            if Page.RunModal(0, Agreement) = Action::LookupOK then
                                AgreementNo := Agreement."No.";
                        end;
                    }
                    field(SubstAccountantNo; SubstAccountantNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Ch. accountant / deputy';

                        trigger OnValidate()
                        begin
                            if SubstAccountantNo = '' then begin
                                EmplName[1] := '';
                            end else begin
                                Employee.Get(SubstAccountantNo);
                                EmplName[1] := StrSubstNo('%1 %2 %3', Employee."Last Name", Employee."First Name", Employee."Middle Name");
                            end;
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if SubstAccountantNo <> '' then begin
                                Employee.Get(SubstAccountantNo);
                            end;
                            if Page.RunModal(0, Employee) = Action::LookupOK then begin
                                SubstAccountantNo := Employee."No.";
                                EmplName[1] := StrSubstNo('%1 %2 %3', Employee."Last Name", Employee."First Name", Employee."Middle Name");
                            end;
                        end;
                    }
                    group(Employee2)
                    {
                        ShowCaption = false;
                        field(EmployeeName3; EmplName[1])
                        {
                            ApplicationArea = All;
                            Caption = 'Ch. accountant / deputy full name';
                            Editable = false;
                        }
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ActDate := WorkDate();
            if SubstAccountantNo = '' then begin
                CompInf.Get();
                CompInf.TestField("Accountant No.");
                AccountantNo := CompInf."Accountant No.";
                SubstAccountantNo := AccountantNo;
                Employee.Get(SubstAccountantNo);
                EmplName[1] := StrSubstNo('%1 %2 %3', Employee."Last Name", Employee."First Name", Employee."Middle Name");
            end;
        end;
    }

    var
        CompInf: Record "Company Information";
        SourceCodeSetup: Record "Source Code Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        CustomerNo: Code[20];
        AgreementNo: Code[20];
        Buff: Record "Invoice Post. Buffer" temporary;
        TotalPaymentAmount: Decimal;
        Customer: Record Customer;
        Agreement: Record "Customer Agreement";
        CompleteAgr: Boolean;
        PartialFulfillmentTitle: Label 'Certificate of partial fulfillment of financial obligations';
        FullFulfillmentTitle: Label 'Certificate of fulfillment of financial obligations';
        ReportTitle: Text;
        SubstAccountantNo: Code[20];
        ActDate: Date;
        EmplName: array[5] of Text;
        AmountOwed: Text;
        ActDate3: Text;
        MONTHTEXT: Label 'January,February,March,April,May,June,July,August,September,October,November,December';
        FAPostingDate: Text;
        InsuranceNo: Text;
        Amount: Text;
        Status: Text;
        DebtStatus: Text;
        AccountantNo: Code[20];
        FullStatus: Label 'full';
        PartialStatus: Label 'partial';
        DebtStatus1: Label 'is absent';
        DebtStatus2: Label 'is %1 RUB';
        Employee: Record Employee;

    trigger OnPreReport()
    begin
        CompInf.Get;
        SourceCodeSetup.Get;

        CustLedgEntry.Reset();
        CustLedgEntry.SetCurrentKey("Customer No.", "Posting Date");
        CustLedgEntry.SetRange("Customer No.", CustomerNo);
        CustLedgEntry.SetRange("Agreement No.", AgreementNo);
        CustLedgEntry.SetFilter("Document Type", '%1|%2', CustLedgEntry."Document Type"::Payment, CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.SetRange(Reversed, false);
        CustLedgEntry.SetFilter("Source Code", '<>%1', SourceCodeSetup."Customer Prepayments");

        if CustLedgEntry.FindFirst() then
            repeat
                CustLedgEntry.CalcFields("Amount (LCY)");
                Buff.Init();
                Buff."G/L Account" := Format(CustLedgEntry."Posting Date", 0, '<Year><Month,2><Day,2>');

                if CustLedgEntry."Document Type" = CustLedgEntry."Document Type"::Refund then
                    Buff."Use Duplication List" := true;

                Buff."FA Posting Date" := CustLedgEntry."Posting Date";
                Buff."Insurance No." := CustLedgEntry."Document No.";
                Buff.Amount := -CustLedgEntry."Amount (LCY)";
                Buff.Insert();
                TotalPaymentAmount += Buff.Amount;
            until CustLedgEntry.Next() = 0;

        Customer.Get(CustomerNo);
        Agreement.Get(CustomerNo, AgreementNo);
        CompleteAgr := Agreement."Agreement Amount" = TotalPaymentAmount;

        if not CompleteAgr then
            AmountOwed := Format(Agreement."Agreement Amount" - TotalPaymentAmount);

        if CompleteAgr then begin
            ReportTitle := FullFulfillmentTitle;
            Status := FullStatus;
            DebtStatus := DebtStatus1;
        end else begin
            ReportTitle := PartialFulfillmentTitle;
            Status := PartialStatus;
            DebtStatus := StrSubstNo(DebtStatus2, AmountOwed);
        end;

        Employee.Get(SubstAccountantNo);
        Employee.TestField("Full Name Genitive");
        Employee.TestField("Job Title");
        Employee.TestField("Job Title Genitive");

        ActDate3 := LowerCase(StrSubstNo(Format(ActDate, 0, '"<Day,2>" %1 <Year4> года'), SelectStr(Date2DMY(ActDate, 2), MONTHTEXT)));
    end;

    local procedure GetShortName(EmplCode: Code[20]) Result: Text
    begin
        Employee.Get(SubstAccountantNo);
        Result := Employee."Last Name" + ' ' + Employee.Initials;
    end;
}