pageextension 70907 "Data Exch Field Map. Part BS" extends "Data Exch Field Mapping Part"
{
    layout
    {
        addafter("Transformation Rule")
        {
            field("Use Value From Header"; Rec."Use Value From Header")
            {
                ApplicationArea = All;
            }
        }
    }


}