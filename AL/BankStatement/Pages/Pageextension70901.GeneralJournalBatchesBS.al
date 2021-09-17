pageextension 70901 "General Journal Batches BS" extends "General Journal Batches"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Payment Method Code"; rec."Payment Method Code")
            {
                ApplicationArea = All;
            }
        }
    }


}