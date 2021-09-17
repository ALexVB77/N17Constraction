table 70035 "Invoice Detail"
{
    Caption = 'Invoice Detail';
    Description = 'NC 50085 PA';

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionMembers = Inv,Credit;
            OptionCaption = 'Inv,Credit';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Description"; Text[250])
        {
            Caption = 'Description';
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(6; "Amount with VAT"; Decimal)
        {
            Caption = 'Amount with VAT';
        }
        field(50000; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Enabled = true;
            Clustered = true;
        }
    }
}