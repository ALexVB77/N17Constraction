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
    ODataKeyFields = Id;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Id)
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

                field(objectId; SomeGuid)
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    var
        SomeGuid: Guid;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Insert(True);
    end;
}
