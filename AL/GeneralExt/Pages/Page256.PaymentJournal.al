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
            field("IW Document No."; "IW Document No.")
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
        PH: Record "Purchase Header";
        LocText001: Label 'No requests were found';
    begin

        if PH.get(ph."Document Type"::Order, Rec."IW Document No.") then begin
            PaymentRequestCard.SetTableView(PH);
            PaymentRequestCard.SetRecord(PH);
            PaymentRequestCard.Run();
        end else
            Message(LocText001);
    end;
}