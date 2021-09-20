table 70036 "CRM Company"
{
    DataPerCompany = false;
    Caption = 'CRM Company';

    fields
    {
        field(1; "Project Guid"; GUID)
        {
            Caption = 'Project Guid';
            NotBlank = true;

        }

        field(2; "Project Name"; Text[30])
        {
            Caption = 'Project Name';
            TableRelation = "Building project";

        }

        field(3; "Company Name"; Text[30])
        {
            Caption = 'Company name';
        }


    }


    keys
    {
        key(Key1; "Project Guid")
        {
            Clustered = true;

        }
    }


    fieldgroups
    {
    }

}

