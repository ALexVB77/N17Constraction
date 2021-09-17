table 70032 "CRM Log"
{
    Caption = 'CRM Log';
    LookupPageId = "CRM Log";
    DrillDownPageId = "CRM Log";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            //AutoIncrement = true;

        }

        field(10; Datetime; Datetime)
        {
            Caption = 'Datetime';

        }

        field(11; "Object Id"; Guid)
        {
            Caption = 'Object Id';

        }

        field(12; "Object Type"; Enum "CRM Object Type")
        {
            Caption = 'Object Type';

        }

        field(13; "Object Xml"; Blob)
        {
            Caption = 'Object Xml';

        }

        field(14; "Object Version Id"; Text[40])
        {
            Caption = 'Object Version Id';

        }

        field(20; Action; Enum "CRM Import Action")
        {
            Caption = 'Action';
        }

        field(21; Status; Enum "CRM Log Status")
        {
            Caption = 'Status';

        }

        field(22; "Details Text 1"; Text[2048])
        {
            Caption = 'Details Text 1';

        }

        field(23; "Details Text 2"; Text[2048])
        {
            Caption = 'Details Text 2';

        }

        field(30; "WRQ Id"; Guid)
        {
            Caption = 'WRQ Id';
            TableRelation = "Web Request Queue";

        }

        field(31; "WRQ Source Company Name"; Text[60])
        {
            Caption = 'WRQ Source Company Name';

        }



    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;

        }

        key(Key2; "Datetime")
        {
        }

        key(Key3; "Object Type", "Object Id")
        {
        }

    }

    trigger OnInsert()
    begin

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

    procedure ExportObjectXml(ShowFileDialog: Boolean): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        OutStrm: OutStream;
        InStrm: InStream;
        FullFileName: Text;
        FilenameGuid: Guid;
    begin
        if "Entry No." = 0 then
            exit;
        CalcFields("Object Xml");
        if not "Object Xml".HasValue then
            exit;
        if IsNullGuid("Object Id") then
            FilenameGuid := CreateGuid()
        else
            FilenameGuid := "Object Id";
        FullFileName := Format(FilenameGuid) + '.txt';
        TempBlob.CreateOutStream(OutStrm);
        "Object Xml".CreateInStream(InStrm);
        CopyStream(OutStrm, InStrm);
        exit(FileManagement.BLOBExport(TempBlob, FullFileName, ShowFileDialog));
    end;

}
