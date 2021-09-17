pageextension 70903 "Bank Acc. Reconcil. Lines BS" extends "Bank Acc. Reconciliation Lines"
{
    layout
    {
        addbefore("Transaction Date")
        {
            field("Document Type"; Rec."Document Type")
            {
                ApplicationArea = all;
            }
            field("Entity Type"; rec."Entity Type")
            {
                applicationarea = all;
            }
            field("Entity No."; Rec."Entity No.")
            {
                ApplicationArea = all;
            }
        }
        addafter("Statement Amount")
        {
            field("Line Status"; Rec."Line Status")
            {
                ApplicationArea = all;
            }
            field("Payment Direction"; Rec."Payment Direction")
            {
                ApplicationArea = all;
            }
            field("Sender Account No."; Rec."Sender Account No.")
            {
                ApplicationArea = all;
            }
            field("Sender VAT Reg. No."; Rec."Sender VAT Reg. No.")
            {
                ApplicationArea = all;
            }
            field("Sender BIC"; Rec."Sender BIC")
            {
                ApplicationArea = all;
            }
            field("Sender Party Name"; Rec."Sender Party Name")
            {
                ApplicationArea = all;
            }
            field("Recipient Account No."; Rec."Recipient Account No.")
            {
                ApplicationArea = all;
            }
            field("Recipient VAT Reg. No."; Rec."Recipient VAT Reg. No.")
            {
                ApplicationArea = all;
            }
            field("Recipient BIC"; Rec."Recipient BIC")
            {
                ApplicationArea = all;
            }
            field("Recipient Name"; Rec."Recipient Name")
            {
                ApplicationArea = all;
            }
        }
        addafter("Related-Party Name")
        {
            field("Posted Amount"; rec."Posted Amount")
            {
                ApplicationArea = All;
            }
            field("Unposted Amount"; rec."Unposted Amount")
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    gjl: Record "Gen. Journal Line";
                    payJnl: Page "Payment Journal";
                begin

                    gjl.RESET();
                    gjl.SETRANGE("Account Type", "Entity Type");
                    gjl.SETRANGE("Account No.", "Entity No.");
                    gjl.SETRANGE("Document No.", "Document No.");
                    gjl.SETRANGE("Posting Date", "Transaction Date");
                    IF (gjl.FINDSET()) THEN BEGIN
                        gjl.SETRANGE("Journal Template Name", gjl."Journal Template Name");
                        gjl.SETRANGE("Journal Batch Name", gjl."Journal Batch Name");
                        gjl.FINDSET();
                        payJnl.SETTABLEVIEW(gjl);
                        payJnl.SETRECORD(gjl);
                        payJnl.RUNMODAL();
                    END;
                end;
            }
        }
    }

    actions
    {
        addafter(ApplyEntries)
        {
            action("Assign Payment Journal")
            {
                ApplicationArea = All;
                Image = SuggestReconciliationLines;
                trigger OnAction()
                var
                    adtMgt: codeunit "Additional Management BS";
                begin
                    adtmgt.manualAssignPaymentJournalLine(rec);
                end;
            }
            action("Clear Payment Journal Assignment")
            {
                ApplicationArea = all;
                Image = CancelAllLines;
                trigger OnAction()
                var
                    adtMgt: codeunit "Additional Management BS";
                begin
                    adtMgt.clearAssignPaymentJournalLine(Rec);
                end;
            }
        }
    }

    procedure CopyReconLine()
    var
        adtMgt: codeunit "Additional Management BS";
        label001: label 'Do you want to create copy of current line?';
    begin
        if (confirm(label001)) then adtMgt.copyReconLine(rec);

    end;
}