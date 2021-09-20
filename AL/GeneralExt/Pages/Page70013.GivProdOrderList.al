page 70013 "Giv. Prod. Order List"
{

    ApplicationArea = All;
    Caption = 'Giv. Prod. Order List';
    PageType = List;
    SourceTable = "Giv. Prod. Order";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {

                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {

                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {

                    ApplicationArea = All;
                }
                field(Finished; Rec.Finished)
                {

                    ApplicationArea = All;
                }
            }
        }
    }

}
