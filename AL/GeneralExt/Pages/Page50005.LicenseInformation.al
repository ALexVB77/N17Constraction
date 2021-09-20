page 50005 "License Information"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'License Information';
    Editable = false;
    PageType = List;
    SourceTable = "License Information";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Text"; "Text")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}


