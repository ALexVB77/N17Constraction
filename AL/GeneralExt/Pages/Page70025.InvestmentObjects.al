page 70025 "Investment Objects"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Investment Object";
    Caption = 'Investment Objects';
    CardPageId = "Investment Object Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Object No."; Rec."Object No.")
                {
                    ApplicationArea = All;

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                }
                field("Type"; Rec.Type)
                {
                    ApplicationArea = All;

                }

                field("Total Area (Project)"; Rec."Total Area (Project)")
                {
                    ApplicationArea = All;

                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
    }
}
