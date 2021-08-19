table 50006 "Request Appr. Com. Line Arch."
{
    Caption = 'Request Approval Comment Line Arch.';
    DrillDownPageID = "Approval Comments";
    LookupPageID = "Approval Comments";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
        }
        field(5; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(6; "Date and Time"; DateTime)
        {
            Caption = 'Date and Time';
            Editable = false;
        }
        field(7; Comment; Text[80])
        {
            Caption = 'Comment';
        }
        field(8; "Record ID to Approve"; RecordID)
        {
            Caption = 'Record ID to Approve';
            DataClassification = SystemMetadata;
        }
        field(50000; "Linked Approval Entry No."; Integer)
        {
            Caption = 'Linked Approval Entry No.';
            Description = 'NC 51374 AB';
        }
        field(50001; "Status App Act"; Enum "Purchase Act Approval Status")
        {
            CalcFormula = lookup("Request Approval Entry Archive"."Status App Act" WHERE("Entry No." = FIELD("Linked Approval Entry No.")));
            Caption = 'Act Approval Status';
            Description = 'NC 51374 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50002; "Approval Status"; Enum "Approval Status")
        {
            CalcFormula = lookup("Request Approval Entry Archive"."Status" WHERE("Entry No." = FIELD("Linked Approval Entry No.")));
            Caption = 'Approval Status';
            Description = 'NC 51374 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50003; "Status App"; Enum "Purchase Approval Status")
        {
            CalcFormula = lookup("Request Approval Entry Archive"."Status App" WHERE("Entry No." = FIELD("Linked Approval Entry No.")));
            Caption = 'Payment Inv. Approval Status';
            Description = 'NC 51374 AB';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key50000; "Linked Approval Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;
}

