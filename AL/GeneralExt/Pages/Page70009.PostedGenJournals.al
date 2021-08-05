page 70009 "Posted Gen. Journals_"
{
    Caption = 'Posted Gen. Journals';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Gen. Journal Line Archive";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec."Posting Date")
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            /*action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }*/
        }
    }

    var
        Template: Code[20];
        Batch: Code[20];

    procedure SetParametrs(Templ: Code[20]; Bat: Code[20])
    var
    begin
        Template := Templ;
        Batch := Bat;
    end;
}