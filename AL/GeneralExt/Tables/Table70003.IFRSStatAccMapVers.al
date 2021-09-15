table 70003 "IFRS Stat. Acc. Map. Vers."
{
    Caption = 'IFRS Stat. Acc. Map. Vers.';
    DataCaptionFields = "Code", Comment;
    LookupPageId = "IFRS Stat. Acc. Map. Versions";

    fields
    {
        field(1; "IFRS Stat. Acc. Mapping Code"; Code[20])
        {
            Caption = 'IFRS Stat. Acc. Mapping Code';
            NotBlank = true;
            TableRelation = "IFRS Statutory Account Mapping";
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3; "Comment"; Text[50])
        {
            Caption = 'Comment';
        }
        field(4; "Version ID"; Guid)
        {
            Caption = 'Version ID';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "IFRS Stat. Acc. Mapping Code", "Code")
        {
            Clustered = true;
        }
        key(Key2; "Version ID")
        {
        }
    }

    trigger OnInsert()
    begin
        "Version ID" := CreateGuid();
    end;

    trigger OnDelete()
    var
        GLSetup: Record "General Ledger Setup";
        IFRSStatAccMapVersLine: Record "IFRS Stat. Acc. Map. Vers.Line";
    begin
        GLSetup.Get();
        if (GLSetup."IFRS Stat. Acc. Map. Code" = Rec."IFRS Stat. Acc. Mapping Code") and
            (GLSetup."IFRS Stat. Acc. Map. Vers.Code" = Rec."Code")
        then
            Error(Text002, TableCaption, GLSetup.TableCaption, GLSetup.FieldCaption("IFRS Stat. Acc. Map. Vers.Code"));

        IFRSStatAccMapVersLine.SetRange("Version ID", "Version ID");
        if not IFRSStatAccMapVersLine.IsEmpty then
            IFRSStatAccMapVersLine.DeleteAll(true);
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        Text001: Label 'You cannot rename %1.';
        Text002: Label 'You cannot delete %1 because it is used in %1 %2.';
}