table 50000 "Document Attachment Archive"
{
    Caption = 'Document Attachment Archive';
    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            Editable = false;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(4; "Attached Date"; DateTime)
        {
            Caption = 'Attached Date';
        }
        field(5; "File Name"; Text[250])
        {
            Caption = 'Attachment';
            NotBlank = true;
        }
        field(6; "File Type"; Option)
        {
            Caption = 'File Type';
            OptionCaption = ' ,Image,PDF,Word,Excel,PowerPoint,Email,XML,Other';
            OptionMembers = " ",Image,PDF,Word,Excel,PowerPoint,Email,XML,Other;
        }
        field(7; "File Extension"; Text[30])
        {
            Caption = 'File Extension';
        }
        field(8; "Document Reference ID"; Media)
        {
            Caption = 'Document Reference ID';
        }
        field(9; "Attached By"; Guid)
        {
            Caption = 'Attached By';
            Editable = false;
            TableRelation = User."User Security ID" WHERE("License Type" = CONST("Full User"));
        }
        field(10; User; Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE("User Security ID" = FIELD("Attached By"),
                                                         "License Type" = CONST("Full User")));
            Caption = 'User';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Document Flow Purchase"; Boolean)
        {
            Caption = 'Flow to Purch. Trx';
        }
        field(12; "Document Flow Sales"; Boolean)
        {
            Caption = 'Flow to Sales Trx';
        }
        field(13; "Document Type"; Enum "Attachment Document Type")
        {
            Caption = 'Document Type';
        }
        field(14; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5047; "Version No."; Integer)
        {
            Caption = 'Version No.';
        }
        field(5048; "Doc. No. Occurrence"; Integer)
        {
            Caption = 'Doc. No. Occurrence';
        }

    }

    keys
    {
        key(Key1; "Table ID", "No.", "Document Type", "Line No.", ID, "Doc. No. Occurrence", "Version No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "No.", "File Name", "File Extension", "File Type")
        {
        }
    }

    [Scope('OnPrem')]
    procedure Export(ShowFileDialog: Boolean): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DocumentStream: OutStream;
        FullFileName: Text;
    begin
        if ID = 0 then
            exit;
        // Ensure document has value in DB
        if not "Document Reference ID".HasValue then
            exit;

        FullFileName := "File Name" + '.' + "File Extension";
        TempBlob.CreateOutStream(DocumentStream);
        "Document Reference ID".ExportStream(DocumentStream);
        exit(FileManagement.BLOBExport(TempBlob, FullFileName, ShowFileDialog));
    end;
}

