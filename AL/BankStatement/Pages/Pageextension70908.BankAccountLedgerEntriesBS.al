pageextension 70908 "Bank Account Ledger Entries BS" extends "Bank Account Ledger Entries"
{
    layout
    {
        addafter(Description)
        {
            field("Payment Purpose"; Rec."Payment Purpose")
            {
                ApplicationArea = All;
            }

        }
    }
}