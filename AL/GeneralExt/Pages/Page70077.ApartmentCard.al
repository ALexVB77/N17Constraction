page 70077 "Apartment Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Apartments;
    Caption = 'Investment object card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
    }


}
