tableextension 80018 "Customer (Ext)" extends Customer
{
    fields
    {
        field(50700; "CRM GUID"; GUID)
        {
            Description = 'NCS-441';

        }

        field(80010; "Version Id"; Text[40])
        {
            Caption = 'Version Id';

        }

    }

    keys
    {
        key(key70000; "CRM GUID") { }

    }
}
