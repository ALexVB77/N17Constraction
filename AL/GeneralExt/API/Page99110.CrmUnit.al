page 99110 "Crm Unit"
{
    PageType = API;

    APIPublisher = 'bonava';
    APIGroup = 'crm';
    APIVersion = 'beta';
    EntityCaption = 'Unit', Locked = true;
    EntitySetCaption = 'Units', Locked = true;
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

                field(projectId; Rec.Guid2)
                {
                    Caption = 'Project Id', Locked = true;

                }

                field(reservingContactId; Rec.Guid3)
                {
                    Caption = 'Reserving Contact Id', Locked = true;

                }

                field(investmentObjectCode; Rec.Text2)
                {
                    Caption = 'Investment Object Code', Locked = true;

                }

                field(investmentObjectDescription; Rec.Text5)
                {
                    Caption = 'Investment Object Description', Locked = true;

                }

                field(investmentObjectType; Rec.Text3)
                {
                    Caption = 'Investment Object Type', Locked = true;

                }

                field(investmentObjectArea; Rec.Decimal1)
                {
                    Caption = 'Investment Object Area', Locked = true;

                }

                field(expectedRegDate; Rec.Date1)
                {
                    Caption = 'Expected Registration Date', Locked = true;

                }

                field(actualDate; Rec.Date2)
                {
                    Caption = 'Actual Date', Locked = true;

                }

                field(expectedDate; Rec.Date3)
                {
                    Caption = 'Expected Date', Locked = true;


                }

                part(buyers; "Crm Unit Buyer")
                {
                    Caption = 'Unit Buyer', Locked = true;
                    EntityName = 'buyer';
                    EntitySetName = 'buyers';
                    SubPageLink = "MessageId" = Field(SystemId);
                }

            }
        }
    }
    var
        BuyersJSON: Text;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SubMsgTemp: Record "Crm Sub Message Buffer" temporary;
        Msg: Record "Crm Message Buffer";
        Klaz: Record "Test rec";
        EntryNo: Integer;
    begin
        if not Klaz.FindLast() then
            EntryNo := 1
        else
            EntryNo := Klaz."Entry No." + 1;

        Error('%1', Rec.Date2);
        Klaz."Entry No." := EntryNo;
        Klaz.Name := Format(Rec.Guid1);
        Klaz.Insert(true);

        CurrPage.buyers.Page.GetBuffer(SubMsgTemp);
        //Error('cu: %1', SubMsgTemp.Count);
        if SubMsgTemp.FindSet() then begin
            repeat
                EntryNo += 1;
                Klaz."Entry No." := EntryNo;
                Klaz.Name := Format(SubMsgTemp.Guid3);
                Klaz.Insert(true);
            until SubMsgTemp.Next() = 0;
        end;

    end;
}
