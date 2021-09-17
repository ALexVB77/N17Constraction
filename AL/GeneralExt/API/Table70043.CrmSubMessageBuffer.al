table 70043 "Crm Sub Message Buffer"
{
    Caption = 'Crm Sub Message Buffer', Locked = true;
    DataPerCompany = false;

    fields
    {
        field(1; SubMessageId; Guid)
        {
            DataClassification = ToBeClassified;

        }

        field(2; MessageId; Guid)
        {
            TableRelation = "Crm Message Buffer".SystemId;
            DataClassification = ToBeClassified;

        }

        field(10; Text1; Text[50])
        {
            DataClassification = ToBeClassified;

        }

        field(11; Text2; Text[50])
        {
            DataClassification = ToBeClassified;

        }

        field(12; Text3; Text[50])
        {
            DataClassification = ToBeClassified;

        }

        field(13; Text4; Text[50])
        {
            DataClassification = ToBeClassified;

        }

        field(14; Text5; Text[100])
        {
            DataClassification = ToBeClassified;

        }


        field(15; Text6; Text[100])
        {
            DataClassification = ToBeClassified;

        }

        field(16; Text7; Text[100])
        {
            DataClassification = ToBeClassified;

        }


        field(17; Text8; Text[250])
        {
            DataClassification = ToBeClassified;

        }

        field(18; Text9; Text[250])
        {
            DataClassification = ToBeClassified;

        }

        field(19; Text10; Text[512])
        {
            DataClassification = ToBeClassified;

        }

        field(20; Text11; Text[2048])
        {
            DataClassification = ToBeClassified;

        }

        field(30; Decimal1; Decimal)
        {
            DataClassification = ToBeClassified;

        }

        field(40; Boolean1; Boolean)
        {
            DataClassification = ToBeClassified;

        }

        field(41; Boolean2; Boolean)
        {
            DataClassification = ToBeClassified;

        }

        field(50; Guid1; Guid)
        {
            DataClassification = ToBeClassified;

        }

        field(51; Guid2; Guid)
        {
            DataClassification = ToBeClassified;

        }

        field(52; Guid3; Guid)
        {
            DataClassification = ToBeClassified;

        }

        field(60; Date1; Date)
        {
            DataClassification = ToBeClassified;

        }

        field(61; Date2; Date)
        {
            DataClassification = ToBeClassified;

        }

        field(62; Date3; Date)
        {
            DataClassification = ToBeClassified;

        }

    }

    keys
    {
        key(PK; SubMessageId, MessageId)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        if IsNullGuid(MessageId) then
            MessageId := CreateGuid();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
