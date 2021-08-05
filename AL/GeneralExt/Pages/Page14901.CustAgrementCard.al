pageextension 94901 "Customer Agreement Card (Ext)" extends "Customer Agreement Card"
{
    layout
    {
        modify("Customer Posting Group")
        {
            Editable = HasntOpenLedgerEntries;
        }
    }


    actions
    {
        addlast("A&greement")
        {
            action(Attachments)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                Promoted = true;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal;
                end;
            }

        }

    }

    trigger OnAfterGetRecord()
    begin
        OnFormat();
    end;

    var
        HasntOpenLedgerEntries: Boolean;

    local procedure OnFormat()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SETRANGE("Customer No.", Rec."Customer No.");
        CustLedgerEntry.SETRANGE("Agreement No.", Rec."No.");
        CustLedgerEntry.SETRANGE(Open, TRUE);
        HasntOpenLedgerEntries := CustLedgerEntry.ISEMPTY;
    end;

}
