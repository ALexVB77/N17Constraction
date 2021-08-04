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
    }
}