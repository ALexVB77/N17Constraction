page 99110 "Unit API"
{
    PageType = API;

    APIPublisher = 'bonava';
    APIGroup = 'crm';
    APIVersion = 'beta';
    EntityCaption = 'Unit';
    EntitySetCaption = 'Units';
    EntityName = 'unit';
    EntitySetName = 'units';

    ODataKeyFields = SystemId;
    SourceTable = "Crm Message Buffer";
    SourceTableTemporary = true;
    InsertAllowed = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                    Editable = false;

                }

                field("objectType"; Rec.Text1)
                {
                    Caption = 'Object Type';

                }

                field(objectId; Rec.Guid1)
                {
                    Caption = 'Object Id';

                }

                field(projectId; Rec.Guid2)
                {
                    Caption = 'Project Id';

                }

                field(reservingContactId; Rec.Guid3)
                {
                    Caption = 'Reserving Contact Id';

                }

                field(investmentObjectCode; Rec.Text2)
                {
                    Caption = 'Investment Object Code';

                }

                field(investmentObjectDescription; Rec.Text5)
                {
                    Caption = 'Investment Object Description';

                }

                field(investmentObjectType; Rec.Text3)
                {
                    Caption = 'Investment Object Type';

                }

                field(investmentObjectArea; Rec.Decimal1)
                {
                    Caption = 'Investment Object Area';

                }

                field(expectedRegDate; Rec.Date1)
                {
                    Caption = 'Expected Registration Date';

                }

                field(actualDate; Rec.Date2)
                {
                    Caption = 'Actual Date';

                }

                field(expectedDate; Rec.Date3)
                {
                    Caption = 'Expected Date';

                }

                field(buyers; BuyersJSON)
                {
                    Caption = 'Expected Date';

                }


            }
        }
    }
    var
        BuyersJSON: Text;
}
