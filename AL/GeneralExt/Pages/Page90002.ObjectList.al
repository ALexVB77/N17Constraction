page 90002 "Object List"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Object List';
    Editable = false;
    PageType = List;
    SourceTable = Object;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
