page 99933 "Crm Object Message API"
{
    PageType = API;
    Caption = 'importObject', Locked = true;
    APIPublisher = 'bonava';
    APIGroup = 'crm';
    APIVersion = 'beta';
    EntityName = 'crmObject';
    EntitySetName = 'crmObjects';
    SourceTable = "Crm Object Message";
    DelayedInsert = true;
    InsertAllowed = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; SystemId)
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
