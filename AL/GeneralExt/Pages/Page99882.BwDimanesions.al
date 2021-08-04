page 99882 "BW Dimensions"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BW Dimension";
    Caption = 'BW Dimesions';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;

                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;

                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;

                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;

                }

            }
        }
    }

}
