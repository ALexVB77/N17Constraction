page 70064 "Crm Contract"
{
    PageType = API;

    APIPublisher = 'bc';
    APIGroup = 'crm';
    APIVersion = 'beta';
    EntityCaption = 'Contract', Locked = true;
    EntitySetCaption = 'Contracts', Locked = true;
    EntityName = 'contract';
    EntitySetName = 'contracts';

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
                    Caption = 'Id', Locked = true;
                    Editable = false;

                }

                field("objectType"; Rec.Text1)
                {
                    Caption = 'Object Type', Locked = true;

                }

                field(objectId; Rec.Guid1)
                {
                    Caption = 'Object Id', Locked = true;

                }

                field(unitId; Rec.Guid2)
                {
                    Caption = 'Unit Id', Locked = true;

                }

                field(number; Rec.Text2)
                {
                    Caption = 'Number', Locked = true;

                }

                field("type"; Rec.Text3)
                {
                    Caption = 'Type', Locked = true;

                }

                field(status; Rec.Text4)
                {
                    Caption = 'Status', Locked = true;

                }

                field(cancelStatus; Rec.Text5)
                {
                    Caption = 'Cancel Status', Locked = true;

                }

                field(isActive; Rec.Boolean1)
                {
                    Caption = 'Is Active', Locked = true;

                }


                field(externalNo; Rec.Text6)
                {
                    Caption = 'External No.', Locked = true;

                }

                field(amount; Rec.Decimal1)
                {
                    Caption = 'Amount', Locked = true;

                }

                field(finishingIncl; Rec.Boolean2)
                {
                    Caption = 'Finishing Included', Locked = true;

                }

                field(buyers; Rec.Text10)
                {
                    Caption = 'Buyers', Locked = true;

                }

            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        //to-do
    end;
}
