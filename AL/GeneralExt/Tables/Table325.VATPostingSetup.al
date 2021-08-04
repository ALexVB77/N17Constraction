tableextension 80325 "VAT Posting Setup GE" extends "VAT Posting Setup"
{
    fields
    {
        field(50000; "VAT Allocation"; Boolean)
        {
            Caption = 'VAT Allocation';
            DataClassification = CustomerContent;
        }
    }
}
