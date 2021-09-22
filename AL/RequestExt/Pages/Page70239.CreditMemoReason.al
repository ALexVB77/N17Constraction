page 70239 "Credit-Memo Reason"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Credit-Memo Reason";
    Caption = 'Credit-Memo Reason';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Reason)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
