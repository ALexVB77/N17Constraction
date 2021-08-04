pageextension 80256 "Payment Journal (Ext)" extends "Payment Journal"
{
    actions
    {
        addlast("F&unctions")
        {
            separator(CustFunctionSep)
            {
            }
            action(GetLinesFromPayReg)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Get lines from Payments Reg.';
                Image = ReverseRegister;

                trigger OnAction()
                var
                    grCreatePaymentJournal: Report "Create Payment Journal";
                begin
                    grCreatePaymentJournal.SetParam("Journal Template Name", "Journal Batch Name");
                    grCreatePaymentJournal.RUNMODAL;
                    CurrPage.UPDATE(FALSE);
                end;
            }


        }
    }
}