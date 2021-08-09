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
                ApplicationArea = Basic, Suite;
                trigger OnAction()
                var
                    Archive: Page "Posted Gen. Journals_";
                    ArchivedLine: Record "Gen. Journal Line Archive";
                begin

                    CLEAR(Archive);
                    Archive.SetParametrs(Rec."Journal Template Name", Rec."Journal Batch Name");
                    Archive.LOOKUPMODE(TRUE);
                    if Archive.RUNMODAL = Action::LookupOK then begin
                        Archive.SetSelectionFilter(ArchivedLine);
                        Archive.SetSelectedLines(ArchivedLine);
                        Archive.CopyLines();

                    end;
                end;

            }
        }
    }

}