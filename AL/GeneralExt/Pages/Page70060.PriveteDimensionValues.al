page 70060 "Privete Dimension Values"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Privete Dimension Value";
    Caption = 'Privete Dimension Values';

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field("Public Value"; "Public Value")
                {
                    ApplicationArea = All;
                }
                field("Privete Value"; "Privete Value")
                {
                    ApplicationArea = All;
                }
                field("Privete Value Name"; "Privete Value Name")
                {
                    ApplicationArea = All;
                }
            }

        }
    }


}