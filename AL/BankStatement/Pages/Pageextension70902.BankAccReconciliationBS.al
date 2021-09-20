pageextension 70902 "Bank Acc. Reconciliation BS" extends "Bank Acc. Reconciliation"
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
        modify(ApplyBankLedgerEntries)
        {
            Visible = false;
        }
        addafter(General)
        {
            group(Control1)
            {
                ShowCaption = false;
                field("Statement Begin Saldo"; rec."Statement Begin Saldo")
                {
                    ApplicationArea = all;
                }
                field("Total Income Amount"; rec."Total Income Amount")
                {
                    ApplicationArea = all;
                }
                field("Total Outcome Amount"; rec."Total Outcome Amount")
                {
                    ApplicationArea = all;
                }
                field("Statement End Saldo"; rec."Statement End Saldo")
                {
                    ApplicationArea = all;
                }
                field("Total Bank Account Amount"; rec."Total Bank Account Amount")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        addbefore(SuggestLines)
        {
            action(CopyLine)
            {
                Caption = 'Copy line';
                Image = CopyDocument;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    CurrPage.StmtLine.Page.CopyReconLine();
                end;
            }
        }
    }
}