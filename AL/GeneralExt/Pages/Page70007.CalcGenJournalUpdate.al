page 70007 "Calc. Gen. Journal Update"
{
    Caption = 'Calc. Gen. Journal Update';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Calculation Journal Line";


    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                //field(Name; NameSource)
                //{
                //ApplicationArea = All;

                //}
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Calculation)
            {
                Caption = 'Calculation';
                ApplicationArea = All;

                trigger OnAction()
                var
                begin

                end;
            }
        }
    }

    var

}