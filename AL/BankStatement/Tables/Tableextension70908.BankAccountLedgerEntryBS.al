tableextension 70908 "Bank Account Ledger Entry BS" extends "Bank Account Ledger Entry"
{
    fields
    {
        field(50001; "Payment Purpose"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Purpose';
        }
    }

}