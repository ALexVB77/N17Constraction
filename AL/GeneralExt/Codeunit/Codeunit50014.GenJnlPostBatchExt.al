codeunit 50014 "Gen. Jnl.-Post Batch (Ext)"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnProcessLinesOnAfterPostGenJnlLines', '', false, false)]
    local procedure OnProcessLinesOnAfterPostGenJnlLines(GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register"; var GLRegNo: Integer; PreviewMode: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Cust: Record Customer;
        CustAgr: Record "Customer Agreement";
        PrintCustAgr: Report "Print Customer Agreement";
    begin

        /*        SalesSetup.GET;
        if GenJournalLine.FindSet() then
            repeat
                if GenJournalLine."Notify Customer" and SalesSetup."Inform Cust. Payment" then
                    if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and
                       (Cust.get(GenJournalLine."Account No.")) and (Cust."E-Mail" <> '') and
                       (CustAgr.Get(GenJournalLine."Account No.",GenJournalLine."Agreement No.")) then begin
                           CustAgr.SetRecFilter();
                           Clear(PrintCustAgr);
                           PrintCustAgr.UseRequestPage(false);
                           PrintCustAgr.SetTableView(CustAgr);
                           PrintCustAgr.SendEMail(Cust."E-Mail", GenJournalLine."Posting Date", -GenJournalLine.Amount, GenJournalLine."Payment Date");
                           PrintCustAgr.RunModal();
                       end;
            until GenJournalLine.Next() = 0;
            */
    end;


}