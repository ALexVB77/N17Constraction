page 71263 "Archiving Document"
{
    Caption = 'Archiving Document';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(Control17)
            {
                ShowCaption = false;
                Visible = true;
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
                        InstructionalText = 'To archive a document, you must specify the archiving reason:';
                        ShowCaption = false;
                    }
                    field(ArchReason; ArchReason)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;

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
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Archive';
                Enabled = ArchReason <> '';
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ArchiveDoc := true;
                    CurrPage.Close();
                end;

            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite, Invoicing;
                Caption = 'Close';
                Enabled = true;
                Image = Approve;
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
        PaymentInvoice.SetRange("Linked Purchase Order Act No.", PurchHeader."No.");
        PurchRcptHdr.SetCurrentKey("Order No.");
        PurchRcptHdr.SetRange("Order No.", PurchHeader."No.");
        ShowAlarm := (PurchHeader."Act Invoice No." <> '') or (not PaymentInvoice.IsEmpty) or (not PurchRcptHdr.IsEmpty);
    end;

    var
        PurchHeader: Record "Purchase Header";
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        ClientTypeManagement: Codeunit "Client Type Management";
        ArchReason: Text;
        ArchiveDoc, ShowAlarm, TopBannerVisible : Boolean;

    procedure SetParam(var ParamPurchHeader: Record "Purchase Header")
    begin
        PurchHeader := ParamPurchHeader;
    end;

    procedure GetResult(var OutArchReason: text): Boolean
    begin
        if ArchiveDoc then
            OutArchReason := ArchReason;
        exit(ArchiveDoc);
    end;
}