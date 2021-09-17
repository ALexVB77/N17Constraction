table 50004 "Act Lines"
{
    Caption = 'Act Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Act No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Act No.';

        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';

        }

        field(3; "Stage Code"; Code[30])
        {
            TableRelation = "Act Stage";
            Caption = 'Stage';
            trigger OnValidate()
            begin
                IF grActStage.GET("Stage Code") THEN
                    "Stage Description" := grActStage."Stage Description"
                ELSE
                    "Stage Description" := '';
            end;


        }

        field(4; "Stage Description"; Text[250])
        {
            Caption = 'Description';

        }

        field(5; "Start Date"; Date)
        {
            Caption = 'Start date';

        }

        field(6; "End Date"; Date)
        {
            Caption = 'End Date';

        }

        field(7; "Exist Comments"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Comment Line" WHERE("Table Name" = CONST(16), "No." = FIELD("Act No."), "Line No." = FIELD("Line No.")));
            Caption = 'Comments exist';

        }

        field(8; "Exist Attachments"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Document Attachment" WHERE("Document Type" = CONST(ActLine), "No." = FIELD("Act No."), "Line No." = FIELD("Line No.")));
            Caption = 'Attachment exists';

        }

        field(9; Close; Boolean)
        {
            Caption = 'Completed';
            trigger OnValidate()
            begin
                ObjectsAct.GET("Act No.");
                if ObjectsAct.Status <> ObjectsAct.Status::Work then
                    ERROR(TEXT0003);

                if Close then begin
                    IF NOT CONFIRM(TEXT0001) then begin
                        Close := FALSE;
                    end else begin
                        "End Date" := TODAY;
                        "User ID" := USERID;
                    end;
                end else begin
                    IF NOT CONFIRM(TEXT0002) then begin
                        Close := TRUE;
                    end else begin
                        "End Date" := 0D;
                        "User ID" := '';
                    end;

                end;
            end;
        }

        field(10; "User ID"; Code[20])
        {
            Caption = 'User';
        }
    }


    keys
    {
        key(Key1; "Act No.", "Line No.")
        {
            Clustered = true;

        }
    }


    fieldgroups
    {
    }


    var
        TEXT0001: Label 'Completed Act stage ?';
        TEXT0002: Label 'Cancel completion stage act?';
        grActStage: record "Act Stage";
        ObjectsAct: record "Objects Act";
        TEXT0003: Label 'Status of the act must be Work!';



}


