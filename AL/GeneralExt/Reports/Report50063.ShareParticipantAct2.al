report 50063 "Share Participant Act 2"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Share Participant Act 2';
    ProcessingOnly = true;
    WordLayout = '/Layouts/FinancialObligationsCertificateTemplate.docx';

    dataset
    {
        dataitem(Employee; Employee)
        {
            column(ReportTitle; ReportTitle)
            {

            }
            column(JobTitleGenitive; "Job Title Genitive")
            {

            }
            column(FullNameGenitive; "Full Name Genitive")
            {

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
                }
            }
        }
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

    trigger OnPreReport()
    begin
        CompInf.Get;
        SourceCodeSetup.Get;

        CustLedgEntry.Reset();
        ;
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
                //Buff."Dimension Entry No." := CustLedgEntry."Entry No.";

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
        if CompleteAgr then begin
            ReportTitle := FullFulfillmentTitle
        end else begin
            ReportTitle := PartialFulfillmentTitle;
        end;

        Employee.Get(SubstAccountantNo);
        Employee.TestField("Full Name Genitive");
        Employee.TestField("Job Title");
        Employee.TestField("Job Title Genitive");
    end;


}