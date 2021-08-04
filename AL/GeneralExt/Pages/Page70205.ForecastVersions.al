page 70205 "Forecast Versions"
{
    Editable = false;
    SourceTable = "Forecast Version";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Repeater12370003)
            {
                field("Version Code"; Rec."Version Code")
                {
                    ApplicationArea = All;

                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                }

                field("Create User"; Rec."Create User")
                {
                    ApplicationArea = All;

                }

                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = All;

                }
            }
        }
    }
}

