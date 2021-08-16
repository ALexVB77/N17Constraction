pageextension 81173 "Document Attachments (Ext)" extends "Document Attachment Details"
{
    layout
    {
        addafter("Attached Date")
        {
            field("Attachment Link"; Rec."Attachment Link")
            {
                ApplicationArea = All;

                trigger OnAssistEdit()
                begin
                    if "Attachment Link" <> '' then
                        Hyperlink("Attachment Link");
                end;
            }
        }
    }

    actions
    {
        modify(Preview)
        {
            Visible = false;
        }
        addafter(Preview)
        {
            action(PreviewNew)
            {
                ApplicationArea = All;
                Caption = 'Preview';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Get a preview of the attachment.';

                trigger OnAction()
                begin
                    if "Attachment Link" <> '' then
                        Hyperlink("Attachment Link")
                    else
                        if "File Name" <> '' then
                            Export(true);
                end;
            }
        }
    }
}