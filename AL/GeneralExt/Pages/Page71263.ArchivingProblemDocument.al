page 71263 "Archiving Document"
{
    Caption = 'Archiving Document';
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

            group(Control1)
            {
                ShowCaption = false;
                group(AloneStep)
                {
                    Caption = 'Do you want to add a document to the archive of problem documents?';

                    group(Control32)
                    {
                        InstructionalText = 'All linked Payment Invoices will be archived, and Posted Purchase Receipt and Purchase Invoices will be deleted as well!';
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
            action(Archive)
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
        }
    }

    var
        ArchReason: Text;
        ArchiveDoc: Boolean;

    procedure GetResult(var OutArchReason: text): Boolean
    begin
        if ArchiveDoc then
            OutArchReason := ArchReason;
        exit(ArchiveDoc);
    end;
}