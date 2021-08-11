page 71263 "Archiving Document"
{
    Caption = 'Archiving Document';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(MainPage)
            {
                ShowCaption = false;
                Visible = MainPageVisible;
                group(AloneStep)
                {
                    Caption = 'Do you want to add a document to the archive of problem documents?';
                    label(Alarm)
                    {
                        ApplicationArea = All;
                        Caption = 'All linked Payment Invoices will be archived, and Posted Purchase Receipt and Purchase Invoices will be deleted as well!';
                        Visible = ShowAlarm;
                    }
                    label(InfoReason)
                    {
                        ApplicationArea = All;
                        Caption = 'To archive a document, you must specify the archiving reason:';
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

    trigger OnOpenPage()
    var
        PaymentInvoice: Record "Purchase Header";
        PurchRcptHdr: Record "Purch. Rcpt. Header";
    begin
        MainPageVisible := true;

        PaymentInvoice.SetCurrentKey("Linked Purchase Order Act No.");
        PaymentInvoice.SetRange("Linked Purchase Order Act No.", PurchHeader."No.");
        PurchRcptHdr.SetCurrentKey("Order No.");
        PurchRcptHdr.SetRange("Order No.", PurchHeader."No.");
        ShowAlarm := (PurchHeader."Act Invoice No." <> '') or (not PaymentInvoice.IsEmpty) or (not PurchRcptHdr.IsEmpty);
    end;

    var
        PurchHeader: Record "Purchase Header";
        ArchReason: Text;
        ArchiveDoc, ShowAlarm, MainPageVisible : Boolean;

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