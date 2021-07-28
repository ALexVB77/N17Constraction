table 70201 "Vendor Excel Header"
{
    Caption = 'Vendor Invoice Header';
    LookupPageID = "Vendor Excel List";
    DrillDownPageID = "Vendor Excel List";

    fields
    {
        field(1; "No."; Code[50])
        {
            Caption = 'No.';
        }
        field(2; Date; Text[50])
        {
            Caption = 'Date';
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(4; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
            Caption = 'Vendor No.';
        }
        field(5; "Vend VAT Reg No."; Code[20])
        {
            Caption = 'Vend VAT Reg No.';
        }
        field(6; "Agreement No."; Code[20])
        {
            TableRelation = "Vendor Agreement"."No." WHERE("Vendor No." = FIELD("Vendor No."), Active = CONST(true));
            Caption = 'Agreement No.';
        }
        field(7; "Act Type"; enum "Purchase Act Type")
        {
            Caption = 'Act Type';
        }
        field(8; "Act No."; Code[20])
        {
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order), "Act Type" = filter(Act | "KC-2" | Advance));
            Editable = false;
            Caption = 'Act No.';
        }
    }

    keys
    {
        key(Key1; "No.", "Vendor No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        VELine: record "Vendor Excel Line";
    begin
        VELine.RESET;
        VELine.SETRANGE("Document No.", "No.");
        VELine.SETRANGE("Vendor No.", "Vendor No.");
        VELine.DELETEALL;
    end;

    var
        Text001: Label 'Purchase Invoice %1 created';
}


