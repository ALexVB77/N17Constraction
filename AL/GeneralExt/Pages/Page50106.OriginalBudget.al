page 50106 "Original Budget"
{
    PageType = List;
    // ApplicationArea = All;
    // UsageCategory = Administration;
    SourceTable = "Original Budget";

    layout
    {
        area(Content)
        {
            repeater(rep1)
            {
                field("Cost Code"; Rec."Cost Code")
                {
                    ApplicationArea = All;

                }
                field("Cost Place"; Rec."Cost Place")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(ActionName)
    //         {
    //             ApplicationArea = All;

    //             trigger OnAction()
    //             begin

    //             end;
    //         }
    //     }
    // }

    // var
    //     myInt: Integer;
}