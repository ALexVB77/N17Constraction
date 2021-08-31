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
        addlast("F&unctions")///
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
            action(ViewRequest)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Request (Journal)';
                Image = View;

                trigger OnAction()
                begin
                    OpenPaymentRequestCard();
                end;
            }


        }
    }
    local procedure OpenPaymentRequestCard()
    var
        GenJnlLine: Record "Gen. Journal Line";
        PaymentRequestCard: Page "Payment Request Card";
        PaymentJournal: page "Payment Journal";
        MultiLine: Boolean;
        LocText001: Label 'No payment journal lines were created from document %1.';
    begin
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        GenJnlLine.SetRange("Line No.", Rec."Line No.");
        PaymentRequestCard.SetTableView(GenJnlLine);
        PaymentRequestCard.SetRecord(GenJnlLine);
        PaymentRequestCard.Run();
    end;
}