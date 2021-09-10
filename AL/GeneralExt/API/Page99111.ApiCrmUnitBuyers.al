page 99111 "Unit Buyer"
{
    PageType = API;

    APIPublisher = 'bonava';
    APIGroup = 'crm';
    APIVersion = 'beta';
    EntityCaption = 'UnitBuyer', Locked = true;
    EntitySetCaption = 'UnitBuyers', Locked = true;
    EntityName = 'unitBuyer';
    EntitySetName = 'unitBuyers';

    ODataKeyFields = SystemId;
    SourceTable = "Crm Sub Message Buffer";
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

                field(buyerId; Rec.Guid1)
                {
                    Caption = 'Buyer Id', Locked = true;

                }

                field(contactId; Rec.Guid2)
                {
                    Caption = 'Contact Id', Locked = true;

                }

                field(contractId; Rec.Guid3)
                {
                    Caption = 'Contract Id', Locked = true;

                }

                field(ownershipPrc; Rec.Decimal1)
                {
                    Caption = 'Shared Ownership Percentage', Locked = true;

                }

                field(buyerIsActive; Rec.Boolean1)
                {
                    Caption = 'Buyer is Active';

                }

            }
        }
    }
    var
        BuyersJSON: Text;

    procedure GetBuffer(var SubMessageBuff: Record "Crm Sub Message Buffer")
    begin
        if not SubMessageBuff.IsTemporary then
            Error('SubMessage must be temporary');
        SubMessageBuff.Reset();
        ;
        SubMessageBuff.DeleteAll();
        Rec.Reset();
        repeat
            SubMessageBuff := Rec;
            SubMessageBuff.Insert();
        until Rec.Next() = 0;
    end;
}
