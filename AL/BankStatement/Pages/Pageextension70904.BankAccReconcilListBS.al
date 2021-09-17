pageextension 70904 "Bank Acc. Reconcil. List BS" extends "Bank Acc. Reconciliation List"
{
    layout
    {
        modify(BalanceLastStatement)
        {
            Visible = false;
        }
        modify(StatementEndingBalance)
        {
            Visible = false;
        }

        addlast(Control1)
        {
            field("Statement Begin Saldo"; Rec."Statement Begin Saldo")
            {
                ApplicationArea = All;
            }
            field("Total Income Amount"; Rec."Total Income Amount")
            {
                ApplicationArea = All;
            }
            field("Total Outcome Amount"; Rec."Total Outcome Amount")
            {
                ApplicationArea = All;
            }
            field("Statement End Saldo"; Rec."Statement End Saldo")
            {
                ApplicationArea = All;
            }
        }
    }
}