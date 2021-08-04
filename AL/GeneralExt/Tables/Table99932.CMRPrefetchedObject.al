table 99932 "CRM Prefetched Object"
{
    Caption = 'CRM Prefetched Object';
    LookupPageId = "CRM Prefetched Objects";
    DrillDownPageId = "CRM Prefetched Objects";
    DataPerCompany = false;

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';

        }

        field(5; ParentId; Guid)
        {
            Caption = 'ParentId';

        }

        field(10; "Type"; enum "CRM Object Type")
        {
            Caption = 'Type';

        }

        field(11; "Xml"; Blob)
        {
            Caption = 'Xml';

        }

        field(12; "Version Id"; Text[40])
        {
            Caption = 'Version Id';

        }

        field(20; "Company name"; Text[60])
        {
            Caption = 'Company name';

        }

        field(30; "Prefetch Datetime"; DateTime)
        {
            Caption = 'Prefetch Datetime';

        }

        field(40; "WRQ Id"; Guid)
        {
            Caption = 'WRQ Id';
            TableRelation = "Web Request Queue";

        }

        field(41; "WRQ Source Company Name"; Text[60])
        {
            Caption = 'WRQ Source Company Name';

        }


    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }

        key(Key2; Type)
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
        NotAttachedXmlErr: Label 'Xml file is not attached';
    begin
        if IsNullGuid(Id) then
            exit;
        CalcFields(Xml);
        if not Xml.HasValue then
            Error(NotAttachedXmlErr);
        FullFileName := Format(Id) + '.txt';
        TempBlob.CreateOutStream(OutStrm);
        Xml.CreateInStream(InStrm);
        CopyStream(OutStrm, InStrm);
        exit(FileManagement.BLOBExport(TempBlob, FullFileName, ShowFileDialog));
    end;


}
