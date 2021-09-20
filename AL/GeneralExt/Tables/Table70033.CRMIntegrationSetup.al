table 70033 "CRM Integration Setup"
{
    Caption = 'CRM Integration Setup';
    LookupPageId = "CRM Integration Setup";
    DrillDownPageId = "CRM Integration Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';

        }

        field(50000; "Customer Posting Group"; Code[10])
        {
            TableRelation = "Customer Posting Group";
            Caption = 'Customer Posting Group';

        }

        field(50010; "Gen. Bus. Posting Group"; Code[10])
        {
            TableRelation = "Gen. Business Posting Group";
            Caption = 'Gen. Bus. Posting Group';

        }

        field(50020; "VAT Bus. Posting Group"; Code[10])
        {
            TableRelation = "VAT Business Posting Group";
            Caption = 'VAT Bus. Posting Group';

        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;

        }
    }

    fieldgroups
    {
    }

}
