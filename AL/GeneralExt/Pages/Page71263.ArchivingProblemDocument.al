page 71263 "Archiving Problem Document'"
{
    Caption = 'Archiving Problem Document';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Purchase Header";
    //SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(AloneStep)
            {
                Caption = 'Do you want to add a document to the archive of problem documents?';
                InstructionalText = 'All linked Payment Invoices will be archived, and Posted Purchase Receipt and Purchase Invoices will be deleted as well!';
                field(ArchReason; ArchReason)
                {
                    ApplicationArea = All;
                    Caption = 'Archiving reason';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Archive)
            {
                ApplicationArea = All;
                Caption = 'Archive';
                Enabled = ArchReason <> '';
                Image = Archive;
                InFooterBar = true;

                trigger OnAction()
                begin

                    // записать причину архивирования!

                    ArchiveDoc := true;
                    CurrPage.Close();
                end;

            }
        }
    }

    var
        ArchReason: Text[80];
        ArchiveDoc: Boolean;

    procedure RunArchiving(): Boolean
    begin
        exit(ArchiveDoc);
    end;

}