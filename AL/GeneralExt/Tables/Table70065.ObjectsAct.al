table 70065 "Objects Act"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No.';

        }

        field(2; "Act Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Act Date';

        }

        field(3; "Agreement No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Customer Agreement"."No." WHERE("Agreement Type" = CONST("Investment Agreement"));
            Caption = 'Agreement No.';

        }

        field(4; "Object No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Investment Object";
            Caption = 'Object No.';

        }

        field(5; "Customer 1 No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer 1 No.';

        }

        field(6; "Customer 2 No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer 2 No.';

        }

        field(7; "Contact 1 No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Contact;
            Caption = 'Contact 1 No.';

        }

        field(8; "Contact 2 No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Contact;
            Caption = 'Client 2 No.';

        }

        field(9; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';

        }

        field(10; "Sign Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Date Asigned';

        }

        field(11; Status; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Status';
            OptionCaption = 'New,Procesed,Asigned,Canceled';
            OptionMembers = New,Work,Sign,Cancell;

        }

        field(12; Sales; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
            Caption = 'Responsible';

        }

        field(13; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No. Series';

        }

        field(70038; "Exist Comments"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Comment Line" WHERE("Table Name" = CONST(15), "No." = FIELD("No.")));
            Caption = 'Comments Exist';

        }

        field(70039; "Exist Attachmets"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Document Attachment" WHERE("Document Type" = CONST(Act), "No." = FIELD("No.")));
            Caption = 'Attachment Exists';
        }
    }


    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;

        }
    }


    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Act Date" := TODAY;
        SalesSetup.GET;
        IF "No." = '' THEN BEGIN
            SalesSetup.TESTFIELD("Customer Nos.");
            NoSeriesMgt.InitSeries(SalesSetup."Building Act Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        END;
        grActStage.SETCURRENTKEY(Ordering);
        grActStage.SETRANGE(Default, TRUE);
        IF grActStage.FIND('-') THEN BEGIN
            LastNo := 10000;
            REPEAT
                grActLines.INIT;
                grActLines."Act No." := "No.";
                grActLines."Line No." := LastNo;
                grActLines."Stage Code" := grActStage."Stage Code";
                grActLines."Stage Description" := grActStage."Stage Description";
                grActLines.INSERT;
                LastNo := LastNo + 10000;
            UNTIL grActStage.NEXT = 0;
        END;

        //BC to-do
        /*
        IF lrAttachments.FIND('+') THEN LastNo1 := lrAttachments."No." + 1 ELSE LastNo1 := 1;
        lrAttachmentSetup.SETRANGE(ObjectType, lrAttachmentSetup.ObjectType::IAgr);
        lrAttachmentSetup.SETRANGE(Template, TRUE);
        IF lrAttachmentSetup.FIND('-') THEN BEGIN
            REPEAT
                lrAttachments.INIT;
                lrAttachmentSetup.CALCFIELDS(Attachment);
                lrAttachments.TRANSFERFIELDS(lrAttachmentSetup);
                lrAttachments."No." := LastNo1;
                lrAttachments.Template := FALSE;
                lrAttachments."Document Type" := lrAttachments."Document Type"::Act;
                lrAttachments."Document No." := "No.";
                lrAttachments.INSERT;
                LastNo1 := LastNo1 + 1;
            UNTIL lrAttachmentSetup.NEXT = 0;
        END;
        */
    end;

    trigger OnDelete()
    begin
        grActLines.SETRANGE("Act No.", "No.");
        grActLines.DELETEALL;
    end;

    var
        NoSeriesMgt: codeunit NoSeriesManagement;
        SalesSetup: record "Sales & Receivables Setup";
        grActStage: record "Act Stage";
        grActLines: record "Act Lines";
        LastNo: integer;
        grActLine: record "Act Lines";
        LastNo1: integer;
}
