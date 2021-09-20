page 70073 "Web Request Worker Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Web Request Worker Setup";
    Caption = 'Web Request Worker Setup';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;

                }
                field(CodeunitId; Rec.CodeunitId)
                {
                    ApplicationArea = All;

                }

                field(FailureCodeunitId; Rec.FailureCodeunitId)
                {
                    ApplicationArea = All;

                }

            }
        }
        area(Factboxes)
        {

        }
    }

}
