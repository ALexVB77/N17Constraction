pageextension 92450 "Item Receipt (Ext)" extends "Item Receipt"
{
    actions
    {
        addafter("Copy Document...")
        {
            action("Copy Document")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Copy Document...';
                Image = CopyDocument;

                trigger OnAction()
                var
                    CopyItemDocument: Report "Copy Item Document (Ext)";
                begin
                    CopyItemDocument.SetItemDocHeader(Rec);
                    CopyItemDocument.RunModal;
                    Clear(CopyItemDocument);
                end;
            }
        }
        modify("Copy Document...")
        {
            Visible = False;
        }
    }
}