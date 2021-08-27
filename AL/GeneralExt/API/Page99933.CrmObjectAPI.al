page 99933 "Crm Object Message API"
{
    PageType = API;
    Caption = 'importObject';
    APIPublisher = 'bonava';
    APIGroup = 'crmIntegration';
    APIVersion = 'v0.1';
    EntityName = 'crmObject';
    EntitySetName = 'crmObjects';
    SourceTable = "Crm Object Message";
    DelayedInsert = true;
    ODataKeyFields = Id;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.Id)
                {
                    ApplicationArea = All;

                }

                field(name; Rec.Name)
                {
                    ApplicationArea = All;
                }

                field(isActive; Rec."Is Active")
                {
                    ApplicationArea = All;
                }


            }
        }
    }
}
