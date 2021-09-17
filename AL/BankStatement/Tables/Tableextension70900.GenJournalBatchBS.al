tableextension 70900 "Gen. Journal Batch BS" extends "Gen. Journal Batch"
{
    fields
    {
        field(50001; "Payment Method Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment method code';
            TableRelation = "Payment Method";
        }
    }
}