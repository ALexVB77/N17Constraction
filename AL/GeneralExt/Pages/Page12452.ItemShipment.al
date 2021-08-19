pageextension 92452 "Item Shipment (Ext)" extends "Item Shipment"
{
    layout
    {
        addafter("Gen. Bus. Posting Group")
        {
            field("Vendor No."; Rec."Vendor No.")
            {
                ApplicationArea = all;
            }
            field("Agreement No."; Rec."Agreement No.")
            {
                ApplicationArea = all;
            }
        }
    }
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
