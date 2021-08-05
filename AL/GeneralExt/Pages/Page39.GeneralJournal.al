pageextension 80039 "General Journal (Ext)" extends "General Journal"
{
    actions
    {
        addlast("F&unctions")
        {
            action("Import from Excel")
            {
                Caption = 'Import from Excel';
                Image = Excel;

                trigger OnAction()
                var
                    ImportGenJournalLines: Report "Import General Journal Lines";
                begin
                    Clear(ImportGenJournalLines);
                    ImportGenJournalLines.RunModal();
                end;
            }

        }
        addafter(IncomingDocument)
        {
            action("Copy lines from journal archive")
            {
                Caption = 'Copy lines from journal archive';
                trigger OnAction()
                var
                    Archive: Page "Posted Gen. Journals_";
                begin

                    CLEAR(Archive);
                    Archive.SetParametrs(Rec."Journal Template Name", Rec."Journal Batch Name");
                    Archive.LOOKUPMODE(TRUE);
                    Archive.RUNMODAL;
                end;

            }
        }
    }

}