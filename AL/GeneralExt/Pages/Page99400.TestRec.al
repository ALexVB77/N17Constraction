page 99400 "Klaz Klaz"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Test rec";
    Caption = 'Klaz Klaz', Locked = true;

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
                Caption = 'TestTryFunc', Locked = true;

                trigger OnAction();
                var
                    cc: codeunit "Rocket Science";
                begin
                    //cc.TryToWriteTestRec();
                    //cc.InsertTry()
                    cc.ModifyTry();
                    CurrPage.Update();

                end;
            }
        }
    }
}
