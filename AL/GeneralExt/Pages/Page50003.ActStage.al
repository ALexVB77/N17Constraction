page 50003 "Act Stage"
{
    SourceTable = "Act Stage";
    SourceTableView = SORTING(Ordering);
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Act Stage';

    layout
    {
        area(content)
        {
            repeater(Repeater12370003)
            {
                field("Stage Code"; Rec."Stage Code")
                {
                    ApplicationArea = All;
                }

                field("Stage Description"; Rec."Stage Description")
                {
                    ApplicationArea = All;
                }

                field(Ordering; Rec.Ordering)
                {
                    ApplicationArea = All;
                }

                field(Default; Rec.Default)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                }

            }
        }
    }


    actions
    {
        area(navigation)
        {
        }
    }







}

