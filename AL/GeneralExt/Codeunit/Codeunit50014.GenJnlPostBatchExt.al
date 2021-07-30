codeunit 50014 "Gen. Jnl.-Post Batch (Ext)"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnProcessLinesOnAfterPostGenJnlLines', '', false, false)]
    local procedure OnProcessLinesOnAfterPostGenJnlLines(GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register"; var GLRegNo: Integer; PreviewMode: Boolean)
    begin

        // SWC803 DD 05.04.16 >>
        /*SalesSetup.GET;
        IF FINDSET THEN
            REPEAT
                IF NOT TracertManagement.TracertInUse AND "Notify Customer" AND SalesSetup."Inform Cust. Payment" THEN
                    IF ("Account Type" = "Account Type"::Customer) AND Cust.GET("Account No.") AND (Cust."E-Mail" <> '')
                  AND CustAgr.GET("Account No.", "Agreement No.") THEN BEGIN
                        CustAgr.SETRECFILTER;
                        CLEAR(PrintCustAgr);
                        PrintCustAgr.USEREQUESTFORM(FALSE);
                        PrintCustAgr.SETTABLEVIEW(CustAgr);
                        PrintCustAgr.SendEMail(Cust."E-Mail", "Posting Date", -Amount, "Payment Date");
                        PrintCustAgr.RUNMODAL;
                    END;
            UNTIL NEXT = 0;
        // SWC803 DD 05.04.16 <<*/
    end;


}