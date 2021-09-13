page 99112 "Crm Contact"
{
    PageType = API;

    APIPublisher = 'bonava';
    APIGroup = 'crm';
    APIVersion = 'beta';
    EntityCaption = 'Contact', Locked = true;
    EntitySetCaption = 'Contacts', Locked = true;
    EntityName = 'contact';
    EntitySetName = 'contacts';

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

                field(lastName; Rec.Text5)
                {
                    Caption = 'Last Name', Locked = true;

                }

                field(firstName; Rec.Text6)
                {
                    Caption = 'Fist Name', Locked = true;

                }

                field(middleName; Rec.Text7)
                {
                    Caption = 'Middle Name', Locked = true;

                }

                field(postalCity; Rec.Text2)
                {
                    Caption = 'Postal City', Locked = true;

                }

                field(countryCode; Rec.Text3)
                {
                    Caption = 'Country Code', Locked = true;

                }

                field(postalCode; Rec.Text4)
                {
                    Caption = 'Post Code;', Locked = true;

                }

                field(address; Rec.Text10)
                {
                    Caption = 'Address', Locked = true;

                }

                field(phone; Rec.Text8)
                {
                    Caption = 'Phone', Locked = true;

                }

                field(email; Rec.Text9)
                {
                    Caption = 'Email', Locked = true;

                }


            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        //to-do
    end;
}
