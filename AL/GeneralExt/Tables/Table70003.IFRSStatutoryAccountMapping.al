table 70003 "IFRS Statutory Account Mapping"
{
    Caption = 'IFRS Statutory Account Mapping';
    DataCaptionFields = "Code", Description;
    LookupPageId = "IFRS Statutory Account Mapping";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Description)
        {
        }
    }

    trigger OnInsert()
    begin
        "Creation Date" := TODAY;
    end;

    trigger OnDelete()
    var
        GLSetup: Record "General Ledger Setup";
        MapVersion: Record "IFRS Stat. Acc. Map. Vers.";
    begin
        GLSetup.Get();
        if GLSetup."IFRS Stat. Acc. Map. Code" = Rec."Code" then
            Error(Text002, TableCaption, GLSetup.TableCaption, GLSetup.FieldCaption("IFRS Stat. Acc. Map. Code"));
        MapVersion.SetRange("IFRS Stat. Acc. Mapping Code", Code);
        if not MapVersion.IsEmpty then
            MapVersion.DeleteAll(true);
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        Text001: Label 'You cannot rename %1.';
        Text002: Label 'You cannot delete %1 because it is used in %1 %2.';
}