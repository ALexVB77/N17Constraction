page 71263 "Archiving Document"
{
    Caption = 'Archiving Document';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Purchase Header";

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                group(AloneStep)
                {
                    Caption = 'Do you want to add a document to the archive of problem documents?';

                    group(Control2)
                    {
                        InstructionalText = 'All linked Payment Invoices will be archived, and Posted Purchase Receipt and Purchase Invoices will be deleted as well!';
                        ShowCaption = false;
                        Visible = ShowAlarm;
                    }
                    group(Control3)
                    {
                        InstructionalText = 'To archive a document, you must specify the archiving reason.';
                        ShowCaption = false;
                    }
                    field(ArchReason; ArchReason)
                    {
                        ApplicationArea = All;
                        Caption = 'Archiving reason';

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionArchive)
            {
                ApplicationArea = All;
                Caption = 'Archive';
                Enabled = ArchReason <> '';
                Image = Archive;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ArchiveDoc := true;
                    CurrPage.Close();
                end;

            }
            action(ActionClose)
            {
                ApplicationArea = Basic, Suite, Invoicing;
                Caption = 'Close';
                Enabled = true;
                Image = Close;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        PaymentInvoice: Record "Purchase Header";
        PurchRcptHdr: Record "Purch. Rcpt. Header";
    begin
        PaymentInvoice.SetCurrentKey("Linked Purchase Order Act No.");
        PaymentInvoice.SetRange("Linked Purchase Order Act No.", "No.");
        PurchRcptHdr.SetCurrentKey("Order No.");
        PurchRcptHdr.SetRange("Order No.", Rec."No.");
        ShowAlarm := (Rec."Act Invoice No." <> '') or (not PaymentInvoice.IsEmpty) or (not PurchRcptHdr.IsEmpty);
    end;

    var
        ArchReason: Text;
        ArchiveDoc, ShowAlarm : Boolean;

    procedure GetResult(var OutArchReason: text): Boolean
    begin
        if ArchiveDoc then
            OutArchReason := ArchReason;
        exit(ArchiveDoc);
    end;
}