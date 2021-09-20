codeunit 70007 "Gen. Jnl.-Post Batch (Ext)"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterProcessLines', '', false, false)]
    local procedure OnAfterProcessLines(var TempGenJournalLine: Record "Gen. Journal Line")
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Cust: Record Customer;
        CustAgr: Record "Customer Agreement";
        CustPmtNotifEmail: Report "Cust. Payment Notif. Email";
    begin

        SalesSetup.GET;
        if TempGenJournalLine.FindSet() then
            repeat
                if TempGenJournalLine."Notify Customer" and SalesSetup."Inform Cust. Payment" then
                    if (TempGenJournalLine."Account Type" = TempGenJournalLine."Account Type"::Customer) and
                       (Cust.get(TempGenJournalLine."Account No.")) and (Cust."E-Mail" <> '') and
                       (CustAgr.Get(TempGenJournalLine."Account No.", TempGenJournalLine."Agreement No.")) then begin
                        CustAgr.SetRecFilter();
                        Clear(CustPmtNotifEmail);
                        CustPmtNotifEmail.SendMail(CustAgr, -TempGenJournalLine.Amount);
                    end;
            until TempGenJournalLine.Next() = 0;
    end;

}
