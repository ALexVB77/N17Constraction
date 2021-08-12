table 50005 "Request Approval Entry Archive"
{
    Caption = 'Request Approval Entry Archive';
    ReplicateData = true;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(2; "Document Type"; Enum "Approval Document Type")
        {
            Caption = 'Document Type';
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(4; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
        }
        field(5; "Approval Code"; Code[20])
        {
            Caption = 'Approval Code';
        }
        field(6; "Sender ID"; Code[50])
        {
            Caption = 'Sender ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(8; "Approver ID"; Code[50])
        {
            Caption = 'Approver ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(9; Status; Enum "Approval Status")
        {
            Caption = 'Status';

            trigger OnValidate()
            begin
                if (xRec.Status = Status::Created) and (Status = Status::Open) then
                    "Date-Time Sent for Approval" := CreateDateTime(Today, Time);
            end;
        }
        field(10; "Date-Time Sent for Approval"; DateTime)
        {
            Caption = 'Date-Time Sent for Approval';
        }
        field(11; "Last Date-Time Modified"; DateTime)
        {
            Caption = 'Last Date-Time Modified';
        }
        field(12; "Last Modified By User ID"; Code[50])
        {
            Caption = 'Last Modified By User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(13; Comment; Boolean)
        {
            CalcFormula = Exist("Request Appr. Com. Line Arch." WHERE("Table ID" = FIELD("Table ID"),
                                                               "Record ID to Approve" = FIELD("Record ID to Approve")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; "Record ID to Approve"; RecordID)
        {
            Caption = 'Record ID to Approve';
            DataClassification = SystemMetadata;
        }
        field(29; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5047; "Version No."; Integer)
        {
            Caption = 'Version No.';
        }
        field(5048; "Doc. No. Occurrence"; Integer)
        {
            Caption = 'Doc. No. Occurrence';
        }
        field(50000; "Status App Act"; Enum "Purchase Act Approval Status")
        {
            Description = 'NC 51373 AB';
            Caption = 'Act Approval Status';
        }
        field(50001; "Act Type"; enum "Purchase Act Type")
        {
            Caption = 'Act Type';
            Description = 'NC 51373 AB';
        }
        field(50002; "Reject"; Boolean)
        {
            Caption = 'Reject';
            Description = 'NC 51374 AB';
        }
        field(50003; "Status App"; Enum "Purchase Approval Status")
        {
            Caption = 'Approval Status';
            Description = 'NC 51374 AB';
        }
        field(50004; "IW Documents"; Boolean)
        {
            Caption = 'IW Documents';
            Description = 'NC 51380 AB';
        }
        field(50005; "Preliminary Approval"; Boolean)
        {
            Caption = 'Preliminary Approval';
            Description = 'NC 51380 AB';
        }
        field(50100; "Delegated From Approver ID"; code[50])
        {
            Caption = 'Delegated From Approver ID';
            DataClassification = EndUserIdentifiableInformation;
            Description = 'NC 51380 AB';
            TableRelation = User."User Name";
        }


    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Record ID to Approve", "Sequence No.")
        {
        }
        key(Key3; "Table ID", "Document Type", "Document No.", "Doc. No. Occurrence", "Version No.", "Sequence No.", "Record ID to Approve")
        {
        }
        key(Key4; "Approver ID", Status, "Date-Time Sent for Approval")
        {
        }
        key(Key5; "Sender ID")
        {
        }
        key(Key7; "Table ID", "Record ID to Approve", Status, "Sequence No.")
        {
        }
        key(Key8; "Table ID", "Document Type", "Document No.", "Doc. No. Occurrence", "Version No.", "Date-Time Sent for Approval")
        {
        }
        key(Key50000; "Delegated From Approver ID", Status, "Date-Time Sent for Approval")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PageManagement: Codeunit "Page Management";
        RecNotExistTxt: Label 'The record does not exist.';

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    procedure ShowRecord()
    var
        RecRef: RecordRef;
    begin
        if not RecRef.Get("Record ID to Approve") then
            exit;
        RecRef.SetRecFilter;
        PageManagement.PageRun(RecRef);
    end;

    procedure RecordCaption() Result: Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
        RecRef: RecordRef;
        PageNo: Integer;
        IsHandled: Boolean;
    begin
        if not RecRef.Get("Record ID to Approve") then
            exit;
        PageNo := PageManagement.GetPageID(RecRef);
        if PageNo = 0 then
            exit;
        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Page, PageNo);
        exit(StrSubstNo('%1 %2', AllObjWithCaption."Object Caption", "Document No."));
    end;
}

