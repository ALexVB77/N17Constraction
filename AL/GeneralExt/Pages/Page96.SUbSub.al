pageextension 80096 "Sales Cr. Memo Subform (Ext)" extends "Sales Cr. Memo Subform"
{
    layout
    {
        addafter("Tax Group Code")
        {
            field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
            {
                ApplicationArea = All;
            }
        }
    }


}
