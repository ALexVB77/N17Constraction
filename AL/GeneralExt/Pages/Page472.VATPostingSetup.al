pageextension 80472 "VAT Posting Setup GE" extends "VAT Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("VAT Allocation"; Rec."VAT Allocation")
            {
                ApplicationArea = all;
            }
        }
    }
}
