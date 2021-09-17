page 70067 "BW Account"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BW Account";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';

                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';

                }

            }
        }

    }

}
