page 99400 "Test Rec"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Test rec";
    Caption = 'Test Rec';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }

                field(Name; Rec.Name)
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
            action(TestTryFunc)
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    cc: codeunit "Rocket Science";
                begin
                    cc.TryToWriteTestRec();
                    CurrPage.Update();

                end;
            }
        }
    }
}
