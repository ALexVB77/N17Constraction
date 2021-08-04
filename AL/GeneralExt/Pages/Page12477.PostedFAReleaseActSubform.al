pageextension 92477 "Posted FA Release Act Sub. Ext" extends "Posted FA Release Act Subform"
{
    actions
    {
        modify("&Print")
        {
            Visible = false;
        }
        addafter("&Line")
        {
            group("Print")
            {
                Caption = 'Print';
                Image = Print;
                action("FA Posted Release Act FA-1")
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'FA Posted Release Act FA-1';
                    ToolTip = 'Prepare to print the FA Posted Release Act FA-1 document. A report request window for the document opens where you can specify what to include on the print-out.';
                    trigger OnAction()
                    var

                        PostedFADocHeader: Record "Posted FA Doc. Header";
                        PostedFADocLine: Record "Posted FA Doc. Line";
                        FAPostedReleaseActRep: Report "FA Posted Release Act FA-1";
                    begin
                        PostedFADocHeader.Get("Document Type", "Document No.");
                        PostedFADocHeader.SetRecFilter;
                        PostedFADocLine := Rec;
                        PostedFADocLine.SetRecFilter;
                        FAPostedReleaseActRep.SetTableView(PostedFADocHeader);
                        FAPostedReleaseActRep.SetTableView(PostedFADocLine);
                        FAPostedReleaseActRep.Run;
                    end;
                }
                action("FA Release Act FA-1a")
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'FA Posted Release Act FA-1A';
                    ToolTip = 'Prepare to print the FA Posted Release Act FA-1A document. A report request window for the document opens where you can specify what to include on the print-out.';
                    trigger OnAction()
                    var
                        FADocHeader: Record "FA Document Header";
                        FADocLine: Record "FA Document Line";
                        PostedFADocHeader: Record "Posted FA Doc. Header";
                        PostedFADocLine: Record "Posted FA Doc. Line";
                        FAPostedReleaseActRep: Report "FA Release Act FA-1a";
                    begin
                        FADocHeader.Reset();
                        FADocLine.Reset();

                        PostedFADocHeader.Get("Document Type", "Document No.");
                        PostedFADocHeader.SetRecFilter;
                        PostedFADocLine := Rec;
                        PostedFADocLine.SetRecFilter;
                        FAPostedReleaseActRep.SetTableView(PostedFADocHeader);
                        FAPostedReleaseActRep.SetTableView(PostedFADocLine);
                        // We have "SaveValues" property turned to true and need to reset prev. run parametrs
                        FAPostedReleaseActRep.SetTableView(FADocHeader);
                        FAPostedReleaseActRep.SetTableView(FADocLine);
                        FAPostedReleaseActRep.Run;
                    end;
                }
                action("FA Release Act FA-1b")
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'FA Posted Release Act FA-1B';

                    trigger OnAction()
                    var


                        PostedFADocHeader: Record "Posted FA Doc. Header";
                        PostedFADocLine: Record "Posted FA Doc. Line";
                        FAPostedReleaseActRep: Report "FA Release Act FA-1b";
                    begin
                        PostedFADocHeader.Get(rec."Document Type", rec."Document No.");
                        PostedFADocHeader.SetRecFilter;
                        FAPostedReleaseActRep.SetTableView(PostedFADocHeader);
                        FAPostedReleaseActRep.UseRequestPage(true);
                        FAPostedReleaseActRep.RunModal();
                    end;
                }
            }
        }
    }
}