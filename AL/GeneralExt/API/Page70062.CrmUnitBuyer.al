page 70062 "Crm Unit Buyer"
{
    PageType = API;

    APIPublisher = 'bc';
    APIGroup = 'crm';
    APIVersion = 'beta';
    EntityCaption = 'Buyer', Locked = true;
    EntitySetCaption = 'Buyers', Locked = true;
    EntityName = 'buyer';
    EntitySetName = 'buyers';

    ODataKeyFields = SystemId;
    SourceTable = "Crm Sub Message Buffer";
    //SourceTableTemporary = true;
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
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SubMsgTemp: Record "Crm Sub Message Buffer" temporary;
        SubMsg: Record "Crm Sub Message Buffer" temporary;
        Msg: Record "Crm Message Buffer";
        Klaz: Record "Test rec";
        EntryNo: Integer;
    begin
        /*
        if not Klaz.FindLast() then
            EntryNo := 1
        else
            EntryNo := Klaz."Entry No." + 1;

        Klaz."Entry No." := EntryNo;
        Klaz.Name := Format(Rec.Guid1);
        Klaz.Insert(true);
        */
    end;

    var
        BuyersJSON: Text;

    procedure GetBuffer(var SubMessageBuff: Record "Crm Sub Message Buffer")
    begin
        if not SubMessageBuff.IsTemporary then
            Error('SubMessage must be temporary');
        SubMessageBuff.Reset();
        SubMessageBuff.DeleteAll();
        Rec.Reset();
        Rec.FindSet();
        repeat
            SubMessageBuff := Rec;
            SubMessageBuff.Insert();
        until Rec.Next() = 0;
    end;
}
