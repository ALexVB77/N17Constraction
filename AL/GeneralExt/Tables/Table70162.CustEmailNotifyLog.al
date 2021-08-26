table 70162 "Cust. E-Mail Notify Log"
{
    Caption = 'Cust. E-Mail Notify Log';
    LookupPageID = "Cust. E-Mail Notify Log";


    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';

        }

        field(2; "Customer No."; Code[20])
        {
            TableRelation = Customer;


        }

        field(3; "Agreement No."; Code[20])
        {
            TableRelation = "Customer Agreement"."No.";
            Caption = 'Agreement No.';

        }

        field(4; Body; BLOB)
        {
            Caption = 'Email Body';

        }

        field(5; "Date Time"; DateTime)
        {
            Caption = 'Date and Time';

        }

        field(6; "E-Mail"; Text[80])
        {
            Caption = 'Email';

        }

    }


    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;

        }
        key(Key2; "Customer No.", "Agreement No.")
        {

        }
    }


    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Date Time" := CurrentDateTime();
    end;

    procedure ExportMailBody(): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        OutStrm: OutStream;
        InStrm: InStream;
        FullFileName: Text;
        FilenameGuid: Guid;
        NoMailBodyErr: Label 'No mail body';
    begin
        Rec.CalcFields(Body);
        if not Rec.Body.HasValue() then
            Error(NoMailBodyErr);
        Rec.Body.CreateInStream(InStrm);
        FullFileName := Format(CreateGuid()) + '.html';
        TempBlob.CreateOutStream(OutStrm, TextEncoding::UTF8);
        CopyStream(OutStrm, InStrm);
        exit(FileManagement.BLOBExport(TempBlob, FullFileName, false));

    end;

}
