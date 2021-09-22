table 70040 "Credit-Memo Reason"
{
    Caption = 'Credit-Memo Reason';
    LookupPageId = "Credit-Memo Reason";

    fields
    {
        field(1; Reason; Text[100])
        {
            Caption = 'Reason';
        }
    }

    keys
    {
        key(Key1; Reason)
        {
            Clustered = true;
        }
    }

}
