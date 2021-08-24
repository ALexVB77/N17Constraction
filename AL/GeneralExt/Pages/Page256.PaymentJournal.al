pageextension 80256 "Payment Journal (Ext)" extends "Payment Journal"
{
    layout
    {
        addlast(Control1)
        {
            field("Notify Customer"; Rec."Notify Customer")
            {
                ApplicationArea = All;
            }
        }
    }
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