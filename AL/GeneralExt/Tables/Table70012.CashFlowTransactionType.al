table 70012 "Cash Flow Transaction Type"
{
    Caption = 'Cash Flow Transaction Type';
    Description = 'NC 50085 PA';
    DataPerCompany = false;
    LookupPageId = "Cash Flow Transaction Type";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[20])
        {
            Caption = 'Description';
        }
        field(3; Priority; Integer)
        {
            Caption = 'Priority';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
            Enabled = true;
        }
        key(Key2; Priority)
        {
            Enabled = true;
        }
    }


}