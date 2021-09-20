page 70214 "Reject Approval"
{
    Caption = 'Reject Approval';
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
                    Caption = 'Do you want to reject document approval?';
                    label(Split2)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Caption = '';
                    }
                    label(InfoReason)
                    {
                        ApplicationArea = All;
                        Caption = 'For rejection, you must specify the reason for sending the document back for revision:';
                    }
                    field(ArchReason; RejectReason)
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
                Caption = 'Reject';
                Enabled = RejectReason <> '';
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    RejectApprove := true;
                    CurrPage.Close();
                end;

            }
            action(ActionFinish)
            {
                ApplicationArea = All;
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
    begin
        MainPageVisible := true;
    end;

    var
        RejectReason: Text;
        RejectApprove, MainPageVisible : Boolean;

    procedure GetResult(var OutRejectReason: text): Boolean
    begin
        if RejectApprove then
            OutRejectReason := RejectReason;
        exit(RejectApprove);
    end;

}