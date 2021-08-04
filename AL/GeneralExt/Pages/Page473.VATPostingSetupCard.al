pageextension 80473 "VAT Posting Setup Card GE" extends "VAT Posting Setup Card"
{
    layout
    {
        addlast(General)
        {
            field("VAT Allocation"; Rec."VAT Allocation")
            {
                ApplicationArea = All;
            }
        }
    }
}
