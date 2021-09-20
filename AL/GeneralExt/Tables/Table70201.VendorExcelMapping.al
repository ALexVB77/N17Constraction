table 70201 "Vendor Excel Mapping"
{
    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(2; "VAT Reg Cell"; Code[20])
        {
            Caption = 'VAT Reg Cell';
        }
        field(3; "Document No Cell"; Code[20])
        {
            Caption = 'Document No Cell';
        }
        field(4; "Document Date Cell"; Code[20])
        {
            Caption = 'Document Date Cell';
        }
        field(5; "ItemDescription Cell"; Code[20])
        {
            Caption = 'ItemDescription Cell';
        }
        field(6; "ItemQuantity Cell"; Code[20])
        {
            Caption = 'ItemQuantity Cell';
        }
        field(7; "ItemUoM Cell"; Code[20])
        {
            Caption = 'ItemUoM Cell';
        }
        field(8; "VAT Percent Cell"; Code[20])
        {
            Caption = 'VAT Percent Cell';
        }
        field(9; "Amount Cell"; Code[20])
        {
            Caption = 'Amount Cell';
        }
        field(10; "Tax Cell"; Code[20])
        {
            Caption = 'Tax Cell';
        }

        field(11; "Price Cell"; Code[20])
        {
            Caption = 'Price Cell';
        }
        field(12; RowStart; Code[20])
        {
            Caption = 'RowStart';
        }
        field(13; "ItemVendNo Cell"; Code[20])
        {
            Caption = 'ItemVendNo Cell';
        }
        field(50000; "Default Location Code"; code[20])
        {
            Caption = 'Default Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
    }

    keys
    {
        key(Key1; "Vendor No.")
        {
            Clustered = true;
        }
    }
}


