page 90001 "License Information"
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


